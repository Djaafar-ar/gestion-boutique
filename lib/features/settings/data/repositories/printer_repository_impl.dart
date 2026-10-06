import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../../../core/printing/receipt_builder.dart';
import '../../../../core/settings/settings_store.dart';
import '../../../../core/utils/printer_helper.dart';
import '../../domain/repositories/printer_repository.dart';

class PrinterRepositoryImpl implements PrinterRepository {
  final SettingsStore settings;
  final PrinterHelper _printerHelper = PrinterHelper();

  PrinterRepositoryImpl(this.settings);

  @override
  Future<List<BluetoothInfo>> scanDevices() async {
    if (await _printerHelper.checkPermission()) {
      return await _printerHelper.getBondedDevices();
    }
    throw Exception('Bluetooth permission denied');
  }

  @override
  Future<bool> connect(String macAddress) async {
    return await _printerHelper.connect(macAddress);
  }

  @override
  Future<bool> disconnect() async {
    return await _printerHelper.disconnect();
  }

  @override
  String? getSavedPrinterMac() => settings.get(SettingsKeys.printerMac);

  @override
  String? getSavedPrinterName() => settings.get(SettingsKeys.printerName);

  @override
  Future<void> savePrinterData(String mac, String name) async {
    await settings.set(SettingsKeys.printerMac, mac);
    await settings.set(SettingsKeys.printerName, name);
  }

  @override
  Future<void> clearPrinterData() async {
    await settings.set(SettingsKeys.printerMac, null);
    await settings.set(SettingsKeys.printerName, null);
  }

  @override
  Future<void> testPrint(String shopName) async {
    final dashes = '-' * receiptWidth;
    await _printerHelper
        .printText('Test impression\n\n$shopName\n\n$dashes\n\n\n');
  }
}
