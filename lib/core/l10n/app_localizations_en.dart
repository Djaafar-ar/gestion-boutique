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

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonAdd => 'Add';

  @override
  String get unknownUser => 'Unknown';

  @override
  String get nameLabel => 'Name';

  @override
  String get phoneOptionalLabel => 'Phone (optional)';

  @override
  String get setupWelcomeTitle => 'Welcome!';

  @override
  String get setupWelcomeBody => 'Let\'s set up your shop in 3 steps.';

  @override
  String get setupExistingBody =>
      'Create the owner account to continue. Your products and sales are kept.';

  @override
  String get setupStepShop => 'Your shop';

  @override
  String get setupStepOwner => 'The owner';

  @override
  String get setupStepPin => 'PIN code';

  @override
  String get ownerNameLabel => 'Your name';

  @override
  String get ownerNameHint => 'e.g. Karim Benali';

  @override
  String get pinLabel => 'PIN (4 digits)';

  @override
  String get pinConfirmLabel => 'Confirm the PIN';

  @override
  String get pinInvalid => 'The PIN must be 4 digits';

  @override
  String get pinMismatch => 'The two PINs do not match';

  @override
  String get pinHelp =>
      'You will type this code to open the app. Do not share it.';

  @override
  String get nextStep => 'Next';

  @override
  String get previousStep => 'Back';

  @override
  String get finishSetup => 'Finish';

  @override
  String get loginTitle => 'Who are you?';

  @override
  String get loginEnterPin => 'Enter your PIN';

  @override
  String loginWrongPin(int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: '$left tries left.',
      one: '1 try left.',
    );
    return 'Wrong PIN. $_temp0';
  }

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleWorker => 'Worker';

  @override
  String get teamSection => 'Team';

  @override
  String get workersTitle => 'Workers';

  @override
  String get workersSub => 'Add, edit, disable';

  @override
  String get addWorker => 'Add a worker';

  @override
  String get editAccount => 'Edit account';

  @override
  String get workerNameHint => 'e.g. Amine Kaci';

  @override
  String get newPinLabel => 'New PIN (4 digits)';

  @override
  String get pinKeepHint => 'Leave empty to keep the current PIN';

  @override
  String get activeLabel => 'Account active';

  @override
  String get activeHelp =>
      'A disabled account can no longer log in. Its history is kept.';

  @override
  String get inactiveBadge => 'DISABLED';

  @override
  String get accountSaved => 'Account saved';

  @override
  String get noWorkersBody => 'Add your workers: each one gets their own PIN.';

  @override
  String get myProfile => 'My profile';

  @override
  String get myStatsTitle => 'My sales';

  @override
  String get periodWeek => 'This week';

  @override
  String get periodMonth => 'This month';

  @override
  String get statRevenue => 'Revenue';

  @override
  String get statSales => 'Sales';

  @override
  String get statItems => 'Items sold';

  @override
  String get statLosses => 'Losses recorded';

  @override
  String get changePin => 'Change my PIN';

  @override
  String get currentPinLabel => 'Current PIN';

  @override
  String get currentPinWrong => 'The current PIN is wrong';

  @override
  String get pinChanged => 'PIN changed';

  @override
  String get switchUser => 'Switch user';

  @override
  String get switchUserSub => 'Back to the PIN screen';

  @override
  String get buyPriceLabel => 'Buying price (optional)';

  @override
  String get categoryLabel => 'Category';

  @override
  String get noCategory => 'No category';

  @override
  String get newCategory => 'New category…';

  @override
  String get categoryNameHint => 'e.g. Boissons';

  @override
  String get lowStockLabel => 'Low-stock alert at';

  @override
  String get lowStockHelp => '0 = no alert. Alerts come in step 5.';

  @override
  String get quantityInvalid => 'Enter a whole number';

  @override
  String get historySection => 'Change history';

  @override
  String get historyNoChanges => 'No changes yet.';

  @override
  String get fieldBuyPrice => 'Buying price';

  @override
  String get fieldLowStock => 'Low-stock level';

  @override
  String get fieldArchived => 'Archived';

  @override
  String soldBy(String name) {
    return 'Sold by $name';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get continueLabel => 'Continue';

  @override
  String get pinLengthLabel => 'PIN length';

  @override
  String pinDigits(int count) {
    return '$count digits';
  }

  @override
  String pinLabelN(int count) {
    return 'PIN ($count digits)';
  }

  @override
  String newPinLabelN(int count) {
    return 'New PIN ($count digits)';
  }

  @override
  String pinInvalidN(int count) {
    return 'The PIN must have $count digits';
  }

  @override
  String get pinInvalidAny => 'Invalid PIN';

  @override
  String loginWait(String time) {
    return 'Too many wrong PINs. Try again in $time.';
  }

  @override
  String get loginWaitPaused =>
      'The countdown only runs while the app is open.';

  @override
  String get loginLockedWorker =>
      'This account is locked after too many wrong PINs. Ask the owner to unlock it.';

  @override
  String get loginLockedOwner =>
      'This account is locked after too many wrong PINs. Use your recovery code.';

  @override
  String get forgotPin => 'Forgot your PIN?';

  @override
  String get recoveryTitle => 'Recover the account';

  @override
  String get recoveryIntro =>
      'Type the recovery code you wrote down when the account was created, then choose a new PIN.';

  @override
  String get recoveryCodeLabel => 'Recovery code';

  @override
  String get recoveryCodeHint => 'e.g. K7QM-3WZD-HP9X';

  @override
  String get recoveryCodeWrong =>
      'Wrong recovery code. The attempt is recorded.';

  @override
  String get recoveryShowTitle => 'Your recovery code';

  @override
  String get recoveryShowBody =>
      'Write this code on paper and keep it somewhere safe. It lets you change the owner PIN if it is forgotten or locked. It will never be shown again.';

  @override
  String get recoveryOldCodeUsed =>
      'The old code was used and no longer works. Here is the new one.';

  @override
  String get recoveryNoted => 'I wrote this code down';

  @override
  String get recoveryTile => 'Recovery code';

  @override
  String get recoveryMissing => 'Not created yet: create it now';

  @override
  String get recoveryExists =>
      'Created. Tap to make a new one (the old one will stop working).';

  @override
  String get recoveryMissingBanner =>
      'Create your recovery code: without it, a forgotten or locked owner PIN cannot be changed.';

  @override
  String get confirmWithPin => 'Enter your current PIN to continue';

  @override
  String get lockedBadge => 'LOCKED';

  @override
  String get lockedWorkerCard =>
      'This account is locked after too many wrong PINs.';

  @override
  String get unlockAccount => 'Unlock the account';

  @override
  String get accountUnlocked => 'Account unlocked';

  @override
  String get resetPinLabel => 'New PIN (to reset it)';

  @override
  String get ownerPinFromProfile => 'Change your own PIN from your profile.';

  @override
  String get failedLoginsTitle => 'Failed login attempts';

  @override
  String get failedLoginsSub => 'Wrong codes typed, by account';

  @override
  String failedLoginsWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wrong codes were typed since your last login.',
      one: '1 wrong code was typed since your last login.',
    );
    return '$_temp0';
  }

  @override
  String get failedLoginsEmpty => 'No failed attempts.';

  @override
  String get seeAll => 'See all';

  @override
  String get securitySection => 'Security';

  @override
  String get kindPin => 'PIN';

  @override
  String accountLabel(String name) {
    return 'Account: $name';
  }

  @override
  String stockLabel(int count) {
    return 'Stock: $count';
  }

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get lowStockBadge => 'Low stock';

  @override
  String expiresOn(String date) {
    return 'Exp. $date';
  }

  @override
  String get expiredBadge => 'Expired';

  @override
  String get expiresSoonBadge => 'Expires soon';

  @override
  String get noExpiry => 'No expiry date';

  @override
  String get addDelivery => 'Receive stock';

  @override
  String get recordLoss => 'Record a loss';

  @override
  String get lossesTitle => 'Losses';

  @override
  String get inStockLabel => 'In stock';

  @override
  String get batchesTitle => 'Batches';

  @override
  String get batchesEmpty => 'No stock yet. Add a stock delivery.';

  @override
  String batchRemaining(int remaining, int quantity) {
    return '$remaining of $quantity';
  }

  @override
  String receivedBy(String date, String name) {
    return 'Received $date by $name';
  }

  @override
  String receivedOn(String date) {
    return 'Received $date';
  }

  @override
  String get showEmptyBatches => 'Also show empty batches';

  @override
  String missingStock(int count) {
    return '$count sold with no stock recorded: add the forgotten delivery.';
  }

  @override
  String get chooseProduct => 'Choose a product';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get quantityRequired => 'Enter a quantity (at least 1)';

  @override
  String get buyPriceUnitLabel => 'Buying price per item';

  @override
  String get expiryLabel => 'Expiry date (optional)';

  @override
  String get pickDate => 'Pick a date';

  @override
  String get noExpiryHelp => 'Leave empty for products that do not expire.';

  @override
  String get updateBuyPrice => 'Use it as the product\'s buying price';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String deliverySaved(int count, String name) {
    return '$count × $name added to stock';
  }

  @override
  String get saveDelivery => 'Add to stock';

  @override
  String get lossReasonLabel => 'Reason';

  @override
  String get reasonDamaged => 'Damaged';

  @override
  String get reasonExpired => 'Expired';

  @override
  String get reasonStaff => 'Eaten/used by staff';

  @override
  String get reasonStolen => 'Stolen';

  @override
  String get reasonOther => 'Other';

  @override
  String get lossBatchLabel => 'Which batch';

  @override
  String get lossBatchAuto => 'Automatic (the one expiring first)';

  @override
  String batchOption(String date, int remaining) {
    return 'Exp. $date · $remaining left';
  }

  @override
  String batchOptionNoDate(String date, int remaining) {
    return 'Received $date · $remaining left';
  }

  @override
  String lossValuePreview(String amount) {
    return 'Estimated money lost: $amount';
  }

  @override
  String lossSaved(String amount) {
    return 'Loss recorded: $amount';
  }

  @override
  String get saveLoss => 'Record the loss';

  @override
  String get lossesEmpty => 'No losses recorded.';

  @override
  String lossesTotal(String amount) {
    return 'Total lost: $amount';
  }

  @override
  String get lossFromReturn => 'Customer return';

  @override
  String moreThanStock(int count) {
    return 'Only $count left in stock. It will still be saved.';
  }

  @override
  String get discountLabel => 'Discount';

  @override
  String get addDiscount => 'Add a discount';

  @override
  String get discountAmount => 'Amount';

  @override
  String get discountPercent => 'Percentage';

  @override
  String get removeDiscount => 'Remove the discount';

  @override
  String get subtotalLabel => 'Subtotal';

  @override
  String discountTooHigh(int max) {
    return 'Discount too high: workers may give at most $max %.';
  }

  @override
  String get discountInvalid => 'Invalid discount';

  @override
  String get applyLabel => 'Apply';

  @override
  String get stockWarningTitle => 'Not enough stock';

  @override
  String get stockWarningBody => 'The sale will still be saved.';

  @override
  String get searchTicketHint => 'Ticket number';

  @override
  String get noSaleFound => 'No sale found.';

  @override
  String get returnButton => 'Customer return';

  @override
  String get refundedLabel => 'Already refunded';

  @override
  String returnedQty(int count) {
    return '$count returned';
  }

  @override
  String returnTitle(int number) {
    return 'Return for sale #$number';
  }

  @override
  String get returnIntro =>
      'Choose the items brought back and say whether they go back on the shelf or are damaged.';

  @override
  String get backOnShelf => 'Back on the shelf';

  @override
  String get returnReasonLabel => 'Reason for the return (optional)';

  @override
  String refundToGive(String amount) {
    return 'Give back to the customer: $amount';
  }

  @override
  String get confirmReturn => 'Confirm the return';

  @override
  String returnSaved(String amount) {
    return 'Return saved. Give $amount back to the customer.';
  }

  @override
  String get returnNothing => 'Choose at least one item.';

  @override
  String get rulesSection => 'Shop rules';

  @override
  String get maxDiscountLabel => 'Workers\' maximum discount (%)';

  @override
  String get expiryWarnLabel => 'Expiry warning: days before';

  @override
  String get percentInvalid => 'Between 0 and 100';

  @override
  String get daysInvalid => 'Between 0 and 60';
}
