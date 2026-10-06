import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';

import '../printing/receipt_builder.dart';

class EscPos {
  static const List<int> init = [0x1B, 0x40];
  static const List<int> alignCenter = [0x1B, 0x61, 0x01];
  static const List<int> alignLeft = [0x1B, 0x61, 0x00];
  static const List<int> alignRight = [0x1B, 0x61, 0x02];
  static const List<int> boldOn = [0x1B, 0x45, 0x01];
  static const List<int> boldOff = [0x1B, 0x45, 0x00];
  static const List<int> textNormal = [0x1D, 0x21, 0x00];
  static const List<int> textLarge = [0x1D, 0x21, 0x11];
  static const List<int> lineFeed = [0x0A];
}

class PrinterHelper {
  // Singleton
  static final PrinterHelper _instance = PrinterHelper._internal();
  factory PrinterHelper() => _instance;
  PrinterHelper._internal();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<bool> checkPermission() async {
    // Request Bluetooth and Location permissions
    // Android 12+ needs BLUETOOTH_SCAN, BLUETOOTH_CONNECT
    // Older Android needs BLUETOOTH, BLUETOOTH_ADMIN, ACCESS_FINE_LOCATION

    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<List<BluetoothInfo>> getBondedDevices() async {
    try {
      final List<BluetoothInfo> list =
          await PrintBluetoothThermal.pairedBluetooths;
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<bool> connect(String macAddress) async {
    try {
      final bool result =
          await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
      _isConnected = result;
      return result;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      final bool result = await PrintBluetoothThermal.disconnect;
      _isConnected =
          !result; // If disconnected successfully, isConnected is false
      return result;
    } catch (e) {
      return false;
    }
  }

  /// Prints raw text (used by the test print).
  Future<void> printText(String text) async {
    if (!_isConnected) return;
    final bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (connectionStatus) {
      await PrintBluetoothThermal.writeBytes(_textToBytes(text));
    }
  }

  /// Prints a sale receipt: the shop name large and centred, then the
  /// body lines prepared by [buildReceiptBody].
  Future<void> printReceipt(ReceiptData data) async {
    if (!_isConnected) return;

    List<int> bytes = [];
    bytes += EscPos.init;

    // Shop Name (Center, Bold, Large)
    bytes += EscPos.alignCenter;
    bytes += EscPos.boldOn;
    bytes += EscPos.textLarge;
    for (final line
        in wrapText(toPrinterAscii(data.shopName), receiptLargeWidth)) {
      bytes += _textToBytes(line);
      bytes += EscPos.lineFeed;
    }
    bytes += EscPos.textNormal;
    bytes += EscPos.boldOff;

    // Body lines are already padded to the paper width.
    bytes += EscPos.alignLeft;
    for (final line in buildReceiptBody(data)) {
      bytes += _textToBytes(line);
      bytes += EscPos.lineFeed;
    }

    // Blank lines so the paper can be torn off below the footer.
    bytes += EscPos.lineFeed;
    bytes += EscPos.lineFeed;
    bytes += EscPos.lineFeed;

    final ok = await PrintBluetoothThermal.writeBytes(bytes);
    if (!ok) throw Exception('Printer did not accept the data');
  }

  List<int> _textToBytes(String text) {
    // Anything outside plain ASCII has already been replaced.
    return toPrinterAscii(text).codeUnits;
  }
}
