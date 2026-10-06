import '../../../core/printing/receipt_builder.dart';
import '../../../core/settings/settings_store.dart';
import '../../../core/utils/printer_helper.dart';
import '../../shop/domain/entities/shop.dart';
import '../domain/entities/sale.dart';

enum PrintOutcome { printed, noSavedPrinter, connectFailed, failed }

class PrintResult {
  final PrintOutcome outcome;
  final String? error;
  const PrintResult(this.outcome, [this.error]);

  bool get ok => outcome == PrintOutcome.printed;
}

/// Prints a saved sale, connecting to the saved printer first if needed.
class ReceiptPrinter {
  final SettingsStore settings;
  final PrinterHelper printer;

  ReceiptPrinter(this.settings, [PrinterHelper? printer])
      : printer = printer ?? PrinterHelper();

  Future<PrintResult> printSale(Sale sale, Shop shop) async {
    if (!printer.isConnected) {
      final savedMac = settings.get(SettingsKeys.printerMac);
      if (savedMac == null) {
        return const PrintResult(PrintOutcome.noSavedPrinter);
      }
      if (!await printer.connect(savedMac)) {
        return const PrintResult(PrintOutcome.connectFailed);
      }
    }
    try {
      await printer.printReceipt(ReceiptData.fromSale(sale, shop));
      return const PrintResult(PrintOutcome.printed);
    } catch (e) {
      return PrintResult(PrintOutcome.failed, e.toString());
    }
  }
}
