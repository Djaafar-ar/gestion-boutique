// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Shop Manager';

  @override
  String get navSell => 'Sell';

  @override
  String get navStock => 'Stock';

  @override
  String get navStats => 'Stats';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navMore => 'More';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonRequired => 'Required';

  @override
  String errorWithDetail(String detail) {
    return 'Error: $detail';
  }

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSoonStats => 'Statistics are coming in a next step.';

  @override
  String get comingSoonAlerts =>
      'Alerts and notifications are coming in a next step.';

  @override
  String get priceRequired => 'Enter a price';

  @override
  String get priceInvalid => 'Invalid price (e.g. 1250 or 1250.50)';

  @override
  String get priceNegative => 'Price cannot be negative';

  @override
  String get cartTitle => 'Cart';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get totalLabel => 'TOTAL';

  @override
  String get cartEmptyTitle => 'Cart is empty';

  @override
  String get cartEmptyBody => 'Scan a barcode with the camera to add items.';

  @override
  String get goToCheckout => 'Go to checkout';

  @override
  String get cameraOffTitle => 'Camera is off';

  @override
  String get cameraOffBody => 'Turn on the camera to scan barcodes.';

  @override
  String get turnOnCamera => 'Turn on camera';

  @override
  String productNotFound(String barcode) {
    return 'Product not found: $barcode';
  }

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get columnProduct => 'Product';

  @override
  String get columnPrice => 'Price';

  @override
  String get columnTotal => 'Total';

  @override
  String get amountToPay => 'AMOUNT TO PAY';

  @override
  String get confirmWithoutPrint => 'Confirm without printing';

  @override
  String get confirmAndPrint => 'Confirm and print';

  @override
  String saleSaved(int number) {
    return 'Sale #$number saved';
  }

  @override
  String saleSavedAndPrinted(int number) {
    return 'Sale #$number saved and printed';
  }

  @override
  String get saleSaveFailed => 'The sale could not be saved.';

  @override
  String get printNoPrinter => 'No printer saved. Connect one in More.';

  @override
  String get printConnectFailed => 'Could not connect to the printer.';

  @override
  String get printFailed => 'Printing failed.';

  @override
  String get printReprintHint =>
      'The sale is saved: reprint it from the history.';

  @override
  String get historyTitle => 'Sales history';

  @override
  String get historyEmptyTitle => 'No sales yet';

  @override
  String get historyEmptyBody => 'Confirmed sales will appear here.';

  @override
  String saleTitle(int number) {
    return 'Sale #$number';
  }

  @override
  String salesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sales',
      one: '1 sale',
      zero: 'No sales',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get reprint => 'Reprint';

  @override
  String get receiptPrinted => 'Receipt printed';

  @override
  String get productsTitle => 'Products';

  @override
  String get productSearchHint => 'Name or barcode';

  @override
  String get productsEmptyTitle => 'No products';

  @override
  String get productsEmptyBody => 'Add your first product with the + button.';

  @override
  String get productsNoMatch => 'No product matches your search.';

  @override
  String get addProduct => 'Add product';

  @override
  String get editProduct => 'Edit product';

  @override
  String get barcodeLabel => 'Barcode';

  @override
  String get barcodeHint => 'Scan or type the barcode';

  @override
  String get barcodeRequired => 'Enter a barcode';

  @override
  String get scanHelp => 'Tap the icon to scan with the camera';

  @override
  String get productNameLabel => 'Product name (in French)';

  @override
  String get productNameHint => 'e.g. Jus Rouiba 1L';

  @override
  String get productNameRequired => 'Enter a name';

  @override
  String get sellPriceLabel => 'Selling price';

  @override
  String barcodeExists(String barcode) {
    return 'A product with barcode \"$barcode\" already exists.';
  }

  @override
  String get productAdded => 'Product added';

  @override
  String get productUpdated => 'Product updated';

  @override
  String get productArchived => 'Product archived';

  @override
  String get archiveProductTitle => 'Archive this product?';

  @override
  String archiveProductBody(String name) {
    return '\"$name\" will no longer be offered for sale. Sales history is kept.';
  }

  @override
  String get archive => 'Archive';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get scanBarcodeTitle => 'Scan a barcode';

  @override
  String get alignBarcode => 'Place the barcode inside the frame';

  @override
  String get moreTitle => 'More';

  @override
  String get shopNameFallback => 'My shop';

  @override
  String get sectionShop => 'Shop';

  @override
  String get shopDetails => 'Shop details';

  @override
  String get shopDetailsSub => 'Name, address, phone, receipt footer';

  @override
  String get sectionPreferences => 'Preferences';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Phone language';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'Same as phone';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get sectionPrinter => 'Printer';

  @override
  String get printerDevice => 'Bluetooth printer';

  @override
  String get printerNone => 'No printer connected';

  @override
  String get printerConnectedBadge => 'CONNECTED';

  @override
  String get printerConnected => 'Printer connected';

  @override
  String get printerHelp =>
      'New printer: tap the gear to pair it in the phone\'s Bluetooth settings, come back, then tap Refresh.';

  @override
  String get printerErrNoPaired => 'No paired devices found.';

  @override
  String get printerErrConnectAll => 'Could not connect to any paired device.';

  @override
  String get printerErrConnect => 'Could not connect to the printer.';

  @override
  String get printerErrPermission => 'Bluetooth permission denied.';

  @override
  String get testPrint => 'Print a test receipt';

  @override
  String get refresh => 'Refresh';

  @override
  String get bluetoothSettings => 'Bluetooth settings';

  @override
  String get shopInfoTitle => 'General information';

  @override
  String get shopInfoHint => 'These details appear on printed receipts.';

  @override
  String get shopNameLabel => 'Shop name';

  @override
  String get shopNameHint => 'e.g. Épicerie El Baraka';

  @override
  String get address1Label => 'Address';

  @override
  String get address1Hint => 'e.g. Rue 5, Bab Ezzouar';

  @override
  String get address2Label => 'Address line 2 (optional)';

  @override
  String get address2Hint => 'e.g. Alger 16000';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get phoneHint => 'e.g. 0555 12 34 56';

  @override
  String get footerLabel => 'Message at the bottom of the receipt';

  @override
  String get footerHint => 'e.g. Merci, à bientôt !';

  @override
  String maxChars(int count) {
    return '$count characters max';
  }

  @override
  String get shopSaved => 'Details saved';
}
