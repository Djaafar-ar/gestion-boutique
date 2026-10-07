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
  String saleSaved(String number) {
    return 'Sale #$number saved';
  }

  @override
  String saleSavedAndPrinted(String number) {
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
  String saleTitle(String number) {
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
  String get lowStockHelp =>
      'Alert in the Alerts tab at this level. 0 = only when stock goes below zero.';

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
  String returnTitle(String number) {
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

  @override
  String get creditSection => 'Credit and suppliers';

  @override
  String get customersTitle => 'Customers (credit book)';

  @override
  String get customersSub => 'Customer credit and payments';

  @override
  String get suppliersTitle => 'Suppliers';

  @override
  String get suppliersSub => 'Deliveries, payments, balance';

  @override
  String get pendingPaymentsTitle => 'Payments to validate';

  @override
  String pendingPaymentsSub(int count) {
    return '$count waiting';
  }

  @override
  String get newCustomer => 'New customer';

  @override
  String get editCustomer => 'Edit customer';

  @override
  String get customerNameHint => 'e.g. Mohamed Saidi';

  @override
  String get nameRequired => 'Enter a name';

  @override
  String get creditLimitLabel => 'Credit limit (optional)';

  @override
  String get creditLimitHelp => 'Empty = no limit';

  @override
  String get creditLimitOwnerOnly => 'Only the owner sets the credit limit.';

  @override
  String get totalOwedByCustomers => 'Owed by customers';

  @override
  String get debtLabel => 'Debt';

  @override
  String get noDebt => 'Nothing owed';

  @override
  String advanceLabel(String amount) {
    return 'Advance: $amount';
  }

  @override
  String get overLimitBadge => 'Over limit';

  @override
  String creditLimitShort(String amount) {
    return 'Limit: $amount';
  }

  @override
  String get noCustomers => 'No customers yet. Add one with the + button.';

  @override
  String get searchCustomer => 'Name or phone';

  @override
  String get receivePayment => 'Receive a payment';

  @override
  String get paymentAmountLabel => 'Amount';

  @override
  String get amountInvalid => 'Enter a valid amount';

  @override
  String paymentTooHigh(String amount) {
    return 'More than the debt ($amount)';
  }

  @override
  String get paymentSaved => 'Payment saved';

  @override
  String get customerHistory => 'Account history';

  @override
  String entryCreditSale(String number) {
    return 'Credit sale #$number';
  }

  @override
  String get entryPayment => 'Payment received';

  @override
  String entryRefund(String number) {
    return 'Return of ticket #$number';
  }

  @override
  String entrySaleDetail(String total, String paid) {
    return 'Total $total · paid $paid';
  }

  @override
  String recordedBy(String name) {
    return 'by $name';
  }

  @override
  String get noHistory => 'Nothing yet.';

  @override
  String archiveTitle(String name) {
    return 'Archive $name?';
  }

  @override
  String get archiveBody =>
      'It will no longer be offered in lists. Its history is kept.';

  @override
  String get archivedDone => 'Archived';

  @override
  String get paymentMode => 'Payment';

  @override
  String get payCash => 'Cash';

  @override
  String get payCredit => 'Credit';

  @override
  String get chooseCustomer => 'Choose a customer';

  @override
  String currentDebt(String amount) {
    return 'Current debt: $amount';
  }

  @override
  String get paidNowLabel => 'Paid now';

  @override
  String get leftOnCredit => 'Left on credit';

  @override
  String get newDebtLabel => 'Customer\'s new debt';

  @override
  String overLimitWarning(String limit) {
    return 'Above the credit limit ($limit)';
  }

  @override
  String get customerRequired => 'Choose a customer for a credit sale.';

  @override
  String get creditLimitTitle => 'Credit limit exceeded';

  @override
  String creditLimitAsk(String name, String debt, String limit) {
    return '$name will owe $debt, above their limit of $limit. Allow anyway?';
  }

  @override
  String creditLimitWorker(String limit) {
    return 'Credit limit exceeded ($limit). Ask the owner.';
  }

  @override
  String get allowAnyway => 'Allow';

  @override
  String saleSavedCredit(String number, String amount, String name) {
    return 'Sale #$number saved · $amount on $name\'s account';
  }

  @override
  String get customerLabel => 'Customer';

  @override
  String get paidLabel => 'Paid';

  @override
  String get onCreditLabel => 'On credit';

  @override
  String get creditChip => 'Credit';

  @override
  String get refundModeLabel => 'Refund';

  @override
  String get refundToCredit => 'Take off the debt';

  @override
  String get refundCash => 'Give back cash';

  @override
  String refundToAccount(String name, String amount) {
    return 'To take off $name\'s account: $amount';
  }

  @override
  String returnSavedCredit(String amount) {
    return 'Return saved. $amount taken off the customer\'s account.';
  }

  @override
  String get newSupplier => 'New supplier';

  @override
  String get editSupplier => 'Edit supplier';

  @override
  String get supplierNameHint => 'e.g. Hamoud Boualem';

  @override
  String get noSuppliers => 'No suppliers yet. Add one with the + button.';

  @override
  String get totalOwedToSuppliers => 'Owed to suppliers';

  @override
  String supplierOwes(String amount) {
    return 'Left to pay: $amount';
  }

  @override
  String supplierAdvance(String amount) {
    return 'Paid in advance: $amount';
  }

  @override
  String pendingAmount(String amount) {
    return 'Pending: $amount';
  }

  @override
  String get deliveredLabel => 'Delivered';

  @override
  String get paidValidatedLabel => 'Paid (validated)';

  @override
  String get leftToPayLabel => 'Left to pay';

  @override
  String get recordSupplierPayment => 'Record a payment';

  @override
  String get workerPaymentNotice =>
      'The owner must validate this payment before it counts.';

  @override
  String get paymentPendingSaved => 'Payment sent to the owner for validation';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusValidated => 'Validated';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get paymentsSection => 'Payments';

  @override
  String get deliveriesSection => 'Deliveries';

  @override
  String get noPayments => 'No payments.';

  @override
  String get noDeliveries =>
      'No deliveries. Choose this supplier when receiving stock.';

  @override
  String paidBy(String name) {
    return 'Paid by $name';
  }

  @override
  String validatedBy(String name) {
    return 'validated by $name';
  }

  @override
  String rejectedBy(String name) {
    return 'rejected by $name';
  }

  @override
  String get validate => 'Validate';

  @override
  String get reject => 'Reject';

  @override
  String get rejectPaymentTitle => 'Reject this payment?';

  @override
  String rejectPaymentBody(String amount, String name) {
    return 'The payment of $amount to $name will not count.';
  }

  @override
  String get paymentValidated => 'Payment validated';

  @override
  String get paymentRejected => 'Payment rejected';

  @override
  String get noPendingPayments => 'No payments waiting.';

  @override
  String get supplierOptional => 'Supplier (optional)';

  @override
  String get noSupplier => 'No supplier';

  @override
  String get searchSupplier => 'Search a supplier';

  @override
  String get savedLabel => 'Saved';

  @override
  String get alertsTitle => 'Alerts';

  @override
  String get alertsEmpty => 'No alerts. All good!';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get markRead => 'Mark as read';

  @override
  String alertsUnread(int count) {
    return '$count unread';
  }

  @override
  String get alertsReadSection => 'Already read';

  @override
  String alertLowStockTitle(String product) {
    return 'Low stock: $product';
  }

  @override
  String alertLowStockBody(int quantity, int threshold) {
    return '$quantity left (alert at $threshold).';
  }

  @override
  String alertOutOfStockTitle(String product) {
    return 'Out of stock: $product';
  }

  @override
  String get alertOutOfStockBody => 'Nothing left in stock.';

  @override
  String alertNegativeStockTitle(String product) {
    return 'Negative stock: $product';
  }

  @override
  String alertNegativeStockBody(int count) {
    return '$count sold with no stock recorded: add the forgotten delivery.';
  }

  @override
  String alertExpiringTitle(String product) {
    return 'Expiring soon: $product';
  }

  @override
  String alertExpiringBody(int remaining, String date) {
    return '$remaining item(s) expire on $date.';
  }

  @override
  String alertExpiredTitle(String product) {
    return 'Expired: $product';
  }

  @override
  String alertExpiredBody(int remaining, String date) {
    return '$remaining item(s) expired on $date. Record a loss.';
  }

  @override
  String get alertPaymentTitle => 'Payment to validate';

  @override
  String alertPaymentBody(String by, String amount, String supplier) {
    return '$by paid $amount to $supplier.';
  }

  @override
  String get alertDeliveryTitle => 'Stock received';

  @override
  String alertDeliveryBody(String by, int quantity, String product) {
    return '$by received $quantity × $product.';
  }

  @override
  String alertCreditTitle(String customer) {
    return 'Credit limit exceeded: $customer';
  }

  @override
  String alertCreditBody(String debt, String limit) {
    return 'Owes $debt (limit $limit).';
  }

  @override
  String get alertPinTitle => 'Wrong PINs';

  @override
  String alertPinBody(int count, String name) {
    return '$count wrong code(s) on $name\'s account.';
  }

  @override
  String get alertReturnTitle => 'Customer return';

  @override
  String alertReturnBody(String by, String number, String amount) {
    return '$by took back items from ticket #$number: $amount.';
  }

  @override
  String alertsSummaryTitle(int count) {
    return '$count new alerts';
  }

  @override
  String get alertsSummaryBody => 'Open the Alerts tab to see them.';

  @override
  String get notificationsTitle => 'Phone notifications';

  @override
  String get notificationsSub => 'Choose which alerts ring';

  @override
  String get notificationsIntro =>
      'Alerts always stay in the Alerts tab. Here you choose which ones also appear as notifications on this phone.';

  @override
  String get workersSeeNote => 'Workers only see low stock and expiry dates.';

  @override
  String get typeLowStock => 'Low and out of stock';

  @override
  String get typeExpiringSoon => 'Expiring soon';

  @override
  String get typeExpired => 'Expired';

  @override
  String get typeNewDelivery => 'Stock received by workers';

  @override
  String get typeOverCreditLimit => 'Customers over their limit';

  @override
  String get typeReturnMade => 'Returns made by workers';

  @override
  String get notificationsBlocked => 'Notifications are blocked on this phone.';

  @override
  String get openPhoneSettings => 'Open settings';

  @override
  String get sendTestNotification => 'Send a test notification';

  @override
  String get testNotificationTitle => 'Test notification';

  @override
  String get testNotificationBody => 'Notifications work.';

  @override
  String get notificationChannel => 'Shop alerts';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get periodCustom => 'Pick…';

  @override
  String get everyone => 'Everyone';

  @override
  String get statProfit => 'Profit';

  @override
  String get statAverageTicket => 'Average ticket';

  @override
  String get statDiscounts => 'Discounts given';

  @override
  String get statReturns => 'Returns';

  @override
  String returnsCountSub(int count) {
    return '$count return(s)';
  }

  @override
  String get statLossesValue => 'Losses';

  @override
  String get revenuePerDay => 'Revenue per day';

  @override
  String get revenuePerMonth => 'Revenue per month';

  @override
  String get salesPerWorker => 'Sales per person';

  @override
  String workerLine(int count, String discounts, String collected) {
    return '$count sale(s) · discounts $discounts · from customers $collected';
  }

  @override
  String get costLabel => 'Buying price of items sold';

  @override
  String get grossProfitLabel => 'Gross profit';

  @override
  String get stockLossesLabel => 'Stock losses';

  @override
  String get netProfitLabel => 'Net profit';

  @override
  String get cashSection => 'Cash drawer';

  @override
  String get paidAtCounterLabel => 'Taken at the counter';

  @override
  String get customerPaymentsLabel => 'Paid by customers (credit book)';

  @override
  String get cashRefundsLabel => 'Cash given back (returns)';

  @override
  String get cashInHandLabel => 'Cash in hand';

  @override
  String supplierPaidLabel(String amount) {
    return 'Paid to suppliers: $amount';
  }

  @override
  String get creditStatsSection => 'Credit';

  @override
  String get cashSalesLabel => 'Paid in cash';

  @override
  String get topDebtors => 'Biggest debtors';

  @override
  String get lossesByReason => 'Losses by reason';

  @override
  String get topProducts => 'Best sellers';

  @override
  String productSoldQty(int quantity) {
    return '$quantity sold';
  }

  @override
  String get noSalesPeriod => 'No sales in this period.';

  @override
  String get myStatsNote => 'You only see your own figures.';

  @override
  String get noReceiptReturn => 'Return without receipt';

  @override
  String get noReceiptExchange => 'Exchange without receipt';

  @override
  String get exchangeButton => 'Exchange';

  @override
  String exchangeTitle(String number) {
    return 'Exchange of ticket #$number';
  }

  @override
  String get exchangeSwitch => 'The customer takes other items (exchange)';

  @override
  String get returnedItemsSection => 'Items brought back';

  @override
  String get takenItemsSection => 'Items the customer takes';

  @override
  String get addReturnedProduct => 'Add a product brought back';

  @override
  String get addTakenProduct => 'Add an item taken';

  @override
  String get noReceiptPriceNote =>
      'Without a receipt, the refund uses today\'s sell price.';

  @override
  String get returnValueLabel => 'Value of items brought back';

  @override
  String get takenValueLabel => 'Value of items taken';

  @override
  String customerPays(String amount) {
    return 'The customer pays: $amount';
  }

  @override
  String giveBack(String amount) {
    return 'Give back to the customer: $amount';
  }

  @override
  String get nothingToSettle => 'Nothing to pay or give back.';

  @override
  String debtReduced(String amount) {
    return '$amount taken off the customer\'s debt';
  }

  @override
  String get confirmExchange => 'Confirm the exchange';

  @override
  String get exchangeNothingTaken => 'Add the items the customer takes.';

  @override
  String exchangeSaved(String number) {
    return 'Exchange saved: ticket #$number.';
  }

  @override
  String get ownerApprovalTitle => 'Owner approval';

  @override
  String ownerApprovalBody(String name) {
    return 'A return without a receipt must be approved by $name. $name, type your PIN:';
  }

  @override
  String get ownerApprovalRefused => 'The owner must approve this return.';

  @override
  String get exchangeCreditLabel => 'Credit (items brought back)';

  @override
  String get fromExchangeNote => 'Exchange ticket';

  @override
  String alertReturnNoReceiptBody(String by, String amount) {
    return '$by took back items without a receipt: $amount.';
  }

  @override
  String get alertExchangeTitle => 'Exchange';

  @override
  String alertExchangeBody(String by, String amount, String taken) {
    return '$by made an exchange: brought back $amount, taken $taken.';
  }

  @override
  String get syncTitle => 'Wi-Fi sync';

  @override
  String get syncSub => 'Link the shop\'s phones';

  @override
  String get syncStandaloneTitle => 'This phone is not linked to any other.';

  @override
  String get syncStandaloneBody =>
      'On the owner\'s phone, switch on the hub: the workers\' phones link to it over the shop\'s Wi-Fi, without internet.';

  @override
  String get becomeHub => 'Make this the main phone';

  @override
  String get hubActive => 'Hub on';

  @override
  String get hubStopped => 'Hub off';

  @override
  String hubAddress(String address) {
    return 'Address: $address';
  }

  @override
  String get hubNoWifi => 'No Wi-Fi: connect this phone to the shop\'s Wi-Fi.';

  @override
  String get hubKeepOpen =>
      'Keep the app open or in the background on this phone (do not close it) so the others can sync.';

  @override
  String get pairTitle => 'Link a phone';

  @override
  String get pairBody =>
      'On the worker\'s phone, choose \"Join a shop\" and scan this code. Do not show it to anyone else: it gives access to the shop.';

  @override
  String get showPairingCode => 'Show the code';

  @override
  String get linkedPhones => 'Linked phones';

  @override
  String get noLinkedPhones => 'No other phone yet.';

  @override
  String devicePhoneLabel(String code, String name) {
    return 'Phone $code · $name';
  }

  @override
  String get thisPhone => 'This phone';

  @override
  String lastSyncAt(String time) {
    return 'Last sync: $time';
  }

  @override
  String get neverSynced => 'Never synced';

  @override
  String get removePhone => 'Remove this phone';

  @override
  String removePhoneBody(String name) {
    return '$name will no longer be able to sync. What it already sent is kept.';
  }

  @override
  String get phoneRemoved => 'Phone removed';

  @override
  String linkedTo(String shop, String code) {
    return 'Linked to $shop · phone $code';
  }

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncing => 'Syncing…';

  @override
  String syncDone(int sent, int received) {
    return 'Synced: $sent sent, $received received';
  }

  @override
  String get syncAuto =>
      'Syncs on its own every 2 minutes and after each sale.';

  @override
  String get syncErrUnreachable =>
      'Hub not found. Is the owner\'s phone on, on the same Wi-Fi, with the app open?';

  @override
  String get syncErrSignature =>
      'Shop code refused. Link this phone again with the owner\'s code.';

  @override
  String get syncErrVersion =>
      'Different versions: install the same version of the app on both phones.';

  @override
  String get syncErrRemoved =>
      'This phone was removed from the shop by the owner.';

  @override
  String get syncErrOther => 'The sync failed. Try again.';

  @override
  String pendingChanges(int count) {
    return '$count change(s) to send';
  }

  @override
  String get joinShop => 'Join an existing shop';

  @override
  String get joinTitle => 'Join a shop';

  @override
  String get joinIntro =>
      'On the owner\'s phone: More → Wi-Fi sync → switch on the hub and show the code. Then scan it here. Both phones must be on the same Wi-Fi.';

  @override
  String get scanPairingCode => 'Scan the owner\'s code';

  @override
  String get notPairingCode => 'This is not a shop code.';

  @override
  String get deviceNameLabel => 'Name of this phone';

  @override
  String get deviceNameHint => 'e.g. Till 2';

  @override
  String joinButton(String shop) {
    return 'Join $shop';
  }

  @override
  String get joining => 'Downloading the shop…';

  @override
  String joined(String code) {
    return 'Phone linked (phone $code). Log in with your PIN.';
  }

  @override
  String get leaveShop => 'Join another shop';

  @override
  String get leaveShopSub => 'For a worker\'s phone: erases this phone';

  @override
  String get leaveShopBody =>
      'All data on this phone (products, sales, accounts…) will be erased. Then it can join the owner\'s shop. Only do this on a worker\'s phone.';

  @override
  String get leaveShopConfirm => 'Erase this phone';

  @override
  String alertDuplicateBarcodeTitle(String barcode) {
    return 'Duplicate barcode: $barcode';
  }

  @override
  String alertDuplicateBarcodeBody(String names) {
    return 'Products: $names. Merge them or change a barcode.';
  }

  @override
  String alertDuplicateCustomerTitle(String phone) {
    return 'Duplicate customer: $phone';
  }

  @override
  String alertDuplicateCustomerBody(String names) {
    return 'Customers: $names. Merge them from the customer page.';
  }

  @override
  String get typeDuplicates => 'Duplicates (products, customers)';

  @override
  String get mergeInto => 'Merge with…';

  @override
  String mergeTitle(String name) {
    return 'Merge into $name?';
  }

  @override
  String mergeCustomerBody(String from, String into) {
    return 'The sales, payments and debt of $from move to $into, then $from is archived.';
  }

  @override
  String mergeProductBody(String from, String into) {
    return 'The sales, stock and losses of $from move to $into, then $from is archived.';
  }

  @override
  String get merge => 'Merge';

  @override
  String get merged => 'Merged';

  @override
  String get hubServiceTitle => 'Shop hub on';

  @override
  String get hubServiceText => 'The other phones can sync.';

  @override
  String get stockShortBlocked =>
      'Not enough stock. Add the stock delivery first.';

  @override
  String stockShortDetail(String product, int count) {
    return '$product: $count left in stock.';
  }

  @override
  String get workersSellWithoutStock => 'Workers can sell without stock';

  @override
  String get workersSellWithoutStockHelp =>
      'Off: a worker cannot sell more than the recorded stock. The owner always can.';

  @override
  String get sheetTitle => 'Google Sheet';

  @override
  String get sheetSub => 'Live sales, evening report, Drive backup';

  @override
  String get sheetIntro =>
      'A copy of the shop in your Google Sheet: follow the sales from afar and keep a backup in your Google Drive. Editing the sheet never changes the app.';

  @override
  String get sheetNotConfigured => 'Not set up yet';

  @override
  String get sheetNotConfiguredOwner =>
      'Create the sheet and its script (see the guide), then scan the setup code below.';

  @override
  String get sheetNotConfiguredWorker =>
      'The owner sets up Google Sheet on their phone. This phone gets the setup through the Wi-Fi sync.';

  @override
  String get sheetConnected => 'Connected to Google Sheet';

  @override
  String get sheetAllSent => 'Everything is sent.';

  @override
  String sheetPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records waiting (they go as soon as there is internet)',
      one: '1 record waiting (it goes as soon as there is internet)',
    );
    return '$_temp0';
  }

  @override
  String sheetLastSend(String time) {
    return 'Last sent: $time';
  }

  @override
  String get sheetNeverSent => 'Nothing sent yet.';

  @override
  String get sheetSendNow => 'Send now';

  @override
  String sheetSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records sent',
      one: '1 record sent',
      zero: 'Nothing to send',
    );
    return '$_temp0';
  }

  @override
  String get sheetErrOffline =>
      'No internet: everything waits on the phone and goes later.';

  @override
  String get sheetErrAccess =>
      'The script refuses access: in Apps Script, check \"Execute as: Me\" and \"Who has access: Anyone\".';

  @override
  String get sheetErrSignature =>
      'Key refused: the keys were changed in the sheet. Scan the new setup code.';

  @override
  String get sheetErrServer => 'Google script error. Try again later.';

  @override
  String get sheetSetupSection => 'Setup';

  @override
  String get sheetScan => 'Scan the setup code';

  @override
  String get sheetScanSub =>
      'In the sheet: menu Boutique → Afficher le code de configuration';

  @override
  String get sheetPaste => 'Paste the code';

  @override
  String get sheetPasteSub =>
      'Without a camera (emulator): copy the code under the QR in the sheet and paste it here.';

  @override
  String get sheetPasteHint => 'Paste the code here';

  @override
  String get sheetNotConfigCode =>
      'This is not a Google Sheet setup code of the shop.';

  @override
  String get sheetChecking => 'Checking with Google…';

  @override
  String sheetConfigured(String name) {
    return 'Connected to \"$name\". Everything already in the shop is being sent to the sheet.';
  }

  @override
  String get sheetDisconnect => 'Disconnect Google Sheet';

  @override
  String get sheetDisconnectConfirm =>
      'The phones will stop sending to the sheet (worker phones after the next Wi-Fi sync). The sheet keeps what it already has.';

  @override
  String get sheetPrivacy =>
      'Only the owner\'s phone can read the figures (read key). Worker phones can only add rows (write key). Do not share the sheet.';

  @override
  String get liveSalesTitle => 'Live sales';

  @override
  String get liveSalesSub => 'Today\'s sales of every phone';

  @override
  String get liveNotifyLabel => 'Notification for every sale';

  @override
  String get liveNotifySub => 'Ticket number, seller and total';

  @override
  String get liveSalesChannel => 'Live sales';

  @override
  String liveSaleTitle(String ticket) {
    return 'New sale no. $ticket';
  }

  @override
  String liveSaleBody(String seller, String total) {
    return '$seller · $total';
  }

  @override
  String liveSalesManyTitle(int count) {
    return '$count new sales';
  }

  @override
  String liveSalesManyBody(String total) {
    return 'Total: $total';
  }

  @override
  String get liveToday => 'Today (after returns)';

  @override
  String liveSalesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sales',
      one: '1 sale',
      zero: 'no sales',
    );
    return '$_temp0';
  }

  @override
  String liveCheckedAt(String time) {
    return 'Checked at $time';
  }

  @override
  String get liveNote =>
      'Updated every 30 seconds while this screen is open. With the app closed, Android checks about every 15 minutes, so notifications then come in small groups.';

  @override
  String get liveEmpty => 'No sales today yet.';

  @override
  String liveSaleTicket(String ticket) {
    return 'Sale no. $ticket';
  }

  @override
  String liveReturn(String ticket) {
    return 'Return $ticket';
  }

  @override
  String get dailyReportLabel => 'Evening report';

  @override
  String get dailyReportSub =>
      'Every evening: the day\'s sales, revenue, profit, cash and returns';

  @override
  String get dailyReportTime => 'Report time';

  @override
  String get dailyReportOpen => 'See the report';

  @override
  String get dailyReportChannel => 'Evening report';

  @override
  String dailyReportTitle(String date) {
    return 'Report of $date';
  }

  @override
  String dailyReportBody(
      int sales, String revenue, String profit, String cash, String returns) {
    return '$sales sales · Revenue $revenue · Profit $profit · Cash $cash · Returns $returns';
  }

  @override
  String get dailyReportNone =>
      'No report yet. It comes every evening at the chosen time.';

  @override
  String get dailyReportToday => 'Work out today';

  @override
  String get reportSales => 'Sales';

  @override
  String get reportRevenue => 'Revenue';

  @override
  String get reportProfit => 'Profit';

  @override
  String get reportCash => 'Cash in the drawer';

  @override
  String get reportReturns => 'Returns';

  @override
  String get reportFromSheet =>
      'From the Google Sheet (every phone that had internet).';

  @override
  String get reportFromPhone => 'From this phone (sales received by Wi-Fi).';

  @override
  String get driveSection => 'Google Drive backup';

  @override
  String get driveNever => 'No backup in Google Drive yet.';

  @override
  String driveLast(String time) {
    return 'Last Drive backup: $time';
  }

  @override
  String get driveInfo =>
      'Once a day, when the phone has internet (Wi-Fi preferred), a backup goes to the \"Sauvegardes Boutique\" folder of your Google Drive. The last 30 are kept.';

  @override
  String get driveBackupNow => 'Back up now';

  @override
  String get driveDone => 'Backup saved in Google Drive.';

  @override
  String get backupWarning =>
      'No backup left the phone for more than 7 days. If the phone is lost, the data is lost.';

  @override
  String get backupTitle => 'Backup and restore';

  @override
  String get backupSub => 'Keep a copy off the phone';

  @override
  String get backupIntro =>
      'A backup is a .zip file with all the shop data. Keep one off the phone: Google Drive, WhatsApp, USB stick…';

  @override
  String get backupNeverOff => 'No backup has left the phone yet.';

  @override
  String backupLastOff(String time) {
    return 'Last backup off the phone: $time';
  }

  @override
  String get backupShare => 'Make and send a backup';

  @override
  String get backupShareSub => 'Drive, WhatsApp, e-mail, Bluetooth…';

  @override
  String get backupShareSubject => 'Shop backup';

  @override
  String get backupDriveTile => 'Automatic Google Drive backup';

  @override
  String get backupDriveOn => 'On: once a day';

  @override
  String get backupDriveOff => 'Set up Google Sheet to turn it on';

  @override
  String get backupPrivate =>
      'A backup holds the whole shop (sales, customers, buying prices). Only send it to yourself, never to a group.';

  @override
  String get restoreTitle => 'Restore a backup';

  @override
  String get restoreSub => 'Replaces this phone\'s data';

  @override
  String get restoreFromBackup => 'Restore a backup (new phone)';

  @override
  String get restoreIntro =>
      'Choose a backup file of this shop (in Downloads, or in Google Drive → Sauvegardes Boutique).';

  @override
  String get restoreIntroNew =>
      'New phone: choose the last backup of your shop (Google Drive → Sauvegardes Boutique). You will type the owner PIN.';

  @override
  String get restorePick => 'Choose the backup file';

  @override
  String restoreMadeOn(String time) {
    return 'Backup of $time';
  }

  @override
  String get restoreWarning =>
      'This phone\'s current data will be replaced by the backup\'s. A backup of the current data is made first, just in case.';

  @override
  String get restoreButton => 'Restore';

  @override
  String get restorePinTitle => 'Owner PIN';

  @override
  String get restoreReadyTitle => 'Restore ready';

  @override
  String get restoreReadyBody =>
      'The app will close. Open it again: it starts with the backup data. Then scan the Google Sheet code again if you use it.';

  @override
  String get restoreClose => 'Close the app';

  @override
  String get restoreErrNotBackup =>
      'This file is not a backup of this app (or it is damaged).';

  @override
  String get restoreErrNewer =>
      'This backup comes from a newer version of the app. Update this phone first.';

  @override
  String get restoreErrOtherShop => 'This backup belongs to another shop.';

  @override
  String get restoreErrPin => 'Wrong owner PIN.';

  @override
  String get restoreErrWorker =>
      'A worker phone gets its data from the main phone: restore on the main phone.';
}
