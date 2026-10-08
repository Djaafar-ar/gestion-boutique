// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'إدارة المحل';

  @override
  String get navSell => 'بيع';

  @override
  String get navStock => 'المخزون';

  @override
  String get navStats => 'إحصائيات';

  @override
  String get navAlerts => 'تنبيهات';

  @override
  String get navMore => 'المزيد';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonRequired => 'حقل إلزامي';

  @override
  String errorWithDetail(String detail) {
    return 'خطأ: $detail';
  }

  @override
  String get priceRequired => 'أدخل السعر';

  @override
  String get priceInvalid => 'سعر غير صالح (مثال: 1250 أو 1250,50)';

  @override
  String get priceNegative => 'لا يمكن أن يكون السعر سالبًا';

  @override
  String get cartTitle => 'السلة';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مادة',
      many: '$count مادة',
      few: '$count مواد',
      two: 'مادتان',
      one: 'مادة واحدة',
      zero: 'لا توجد مواد',
    );
    return '$_temp0';
  }

  @override
  String get totalLabel => 'المجموع';

  @override
  String get cartEmptyTitle => 'السلة فارغة';

  @override
  String get cartEmptyBody => 'امسح رمزًا شريطيًا بالكاميرا لإضافة المواد.';

  @override
  String get goToCheckout => 'الانتقال إلى الدفع';

  @override
  String get cameraOffTitle => 'الكاميرا مطفأة';

  @override
  String get cameraOffBody => 'شغّل الكاميرا لمسح الرموز الشريطية.';

  @override
  String get turnOnCamera => 'تشغيل الكاميرا';

  @override
  String productNotFound(String barcode) {
    return 'المنتج غير موجود: $barcode';
  }

  @override
  String get checkoutTitle => 'الدفع';

  @override
  String get columnProduct => 'المنتج';

  @override
  String get columnPrice => 'السعر';

  @override
  String get columnTotal => 'المجموع';

  @override
  String get amountToPay => 'المبلغ المطلوب';

  @override
  String get confirmWithoutPrint => 'تأكيد بدون طباعة';

  @override
  String get confirmAndPrint => 'تأكيد وطباعة';

  @override
  String saleSaved(String number) {
    return 'تم حفظ البيع رقم $number';
  }

  @override
  String saleSavedAndPrinted(String number) {
    return 'تم حفظ وطباعة البيع رقم $number';
  }

  @override
  String get saleSaveFailed => 'تعذّر حفظ البيع.';

  @override
  String get printNoPrinter =>
      'لا توجد طابعة محفوظة. قم بتوصيل واحدة من المزيد.';

  @override
  String get printConnectFailed => 'تعذّر الاتصال بالطابعة.';

  @override
  String get printFailed => 'فشلت الطباعة.';

  @override
  String get printReprintHint => 'البيع محفوظ: أعد طباعته من السجل.';

  @override
  String get historyTitle => 'سجل المبيعات';

  @override
  String get historyEmptyTitle => 'لا توجد مبيعات';

  @override
  String get historyEmptyBody => 'ستظهر هنا المبيعات المؤكدة.';

  @override
  String saleTitle(String number) {
    return 'البيع رقم $number';
  }

  @override
  String salesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بيع',
      many: '$count بيعًا',
      few: '$count مبيعات',
      two: 'بيعان',
      one: 'بيع واحد',
      zero: 'لا مبيعات',
    );
    return '$_temp0';
  }

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get reprint => 'إعادة الطباعة';

  @override
  String get receiptPrinted => 'تمت طباعة التذكرة';

  @override
  String get productsTitle => 'المنتجات';

  @override
  String get productSearchHint => 'الاسم أو الرمز الشريطي';

  @override
  String get productsEmptyTitle => 'لا توجد منتجات';

  @override
  String get productsEmptyBody => 'أضف أول منتج بالزر +.';

  @override
  String get productsNoMatch => 'لا يوجد منتج يطابق البحث.';

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get editProduct => 'تعديل المنتج';

  @override
  String get barcodeLabel => 'الرمز الشريطي';

  @override
  String get barcodeHint => 'امسح أو اكتب الرمز الشريطي';

  @override
  String get barcodeRequired => 'أدخل الرمز الشريطي';

  @override
  String get scanHelp => 'المس الأيقونة للمسح بالكاميرا';

  @override
  String get productNameLabel => 'اسم المنتج (بالفرنسية)';

  @override
  String get productNameHint => 'مثال: Jus Rouiba 1L';

  @override
  String get productNameRequired => 'أدخل الاسم';

  @override
  String get sellPriceLabel => 'سعر البيع';

  @override
  String barcodeExists(String barcode) {
    return 'يوجد منتج بالرمز الشريطي «$barcode» مسبقًا.';
  }

  @override
  String get productAdded => 'تمت إضافة المنتج';

  @override
  String get productUpdated => 'تم تعديل المنتج';

  @override
  String get productArchived => 'تمت أرشفة المنتج';

  @override
  String get archiveProductTitle => 'أرشفة هذا المنتج؟';

  @override
  String archiveProductBody(String name) {
    return 'لن يُعرض «$name» للبيع بعد الآن. يبقى سجل المبيعات محفوظًا.';
  }

  @override
  String get archive => 'أرشفة';

  @override
  String get saveChanges => 'حفظ التعديلات';

  @override
  String get scanBarcodeTitle => 'مسح رمز شريطي';

  @override
  String get alignBarcode => 'ضع الرمز الشريطي داخل الإطار';

  @override
  String get moreTitle => 'المزيد';

  @override
  String get shopNameFallback => 'محلي';

  @override
  String get sectionShop => 'المحل';

  @override
  String get shopDetails => 'معلومات المحل';

  @override
  String get shopDetailsSub => 'الاسم، العنوان، الهاتف، أسفل التذكرة';

  @override
  String get sectionPreferences => 'التفضيلات';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'لغة الهاتف';

  @override
  String get theme => 'المظهر';

  @override
  String get themeSystem => 'مثل الهاتف';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get sectionPrinter => 'الطابعة';

  @override
  String get printerDevice => 'طابعة بلوتوث';

  @override
  String get printerNone => 'لا توجد طابعة متصلة';

  @override
  String get printerConnectedBadge => 'متصلة';

  @override
  String get printerConnected => 'تم الاتصال بالطابعة';

  @override
  String get printerHelp =>
      'طابعة جديدة: المس الترس لإقرانها في إعدادات بلوتوث الهاتف، ثم ارجع والمس تحديث.';

  @override
  String get printerErrNoPaired => 'لم يتم العثور على أجهزة مقترنة.';

  @override
  String get printerErrConnectAll => 'تعذّر الاتصال بأي جهاز مقترن.';

  @override
  String get printerErrConnect => 'تعذّر الاتصال بالطابعة.';

  @override
  String get printerErrPermission => 'تم رفض إذن البلوتوث.';

  @override
  String get testPrint => 'طباعة تذكرة تجريبية';

  @override
  String get refresh => 'تحديث';

  @override
  String get bluetoothSettings => 'إعدادات البلوتوث';

  @override
  String get shopInfoTitle => 'معلومات عامة';

  @override
  String get shopInfoHint => 'تظهر هذه المعلومات على التذاكر المطبوعة.';

  @override
  String get shopNameLabel => 'اسم المحل';

  @override
  String get shopNameHint => 'مثال: Épicerie El Baraka';

  @override
  String get address1Label => 'العنوان';

  @override
  String get address1Hint => 'مثال: Rue 5, Bab Ezzouar';

  @override
  String get address2Label => 'العنوان، تتمة (اختياري)';

  @override
  String get address2Hint => 'مثال: Alger 16000';

  @override
  String get phoneLabel => 'الهاتف';

  @override
  String get phoneHint => 'مثال: 0555 12 34 56';

  @override
  String get footerLabel => 'رسالة أسفل التذكرة';

  @override
  String get footerHint => 'مثال: Merci, à bientôt !';

  @override
  String maxChars(int count) {
    return '$count حرفًا كحد أقصى';
  }

  @override
  String get shopSaved => 'تم حفظ المعلومات';

  @override
  String get commonYes => 'نعم';

  @override
  String get commonNo => 'لا';

  @override
  String get commonAdd => 'إضافة';

  @override
  String get unknownUser => 'غير معروف';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get phoneOptionalLabel => 'الهاتف (اختياري)';

  @override
  String get setupWelcomeTitle => 'مرحبًا!';

  @override
  String get setupWelcomeBody => 'لنُعِدّ محلك في 3 خطوات.';

  @override
  String get setupExistingBody =>
      'أنشئ حساب المالك للمتابعة. منتجاتك ومبيعاتك محفوظة.';

  @override
  String get setupStepShop => 'محلك';

  @override
  String get setupStepOwner => 'المالك';

  @override
  String get setupStepPin => 'الرمز السري';

  @override
  String get ownerNameLabel => 'اسمك';

  @override
  String get ownerNameHint => 'مثال: كريم بن علي';

  @override
  String get pinLabel => 'الرمز السري (4 أرقام)';

  @override
  String get pinConfirmLabel => 'أكّد الرمز السري';

  @override
  String get pinInvalid => 'يجب أن يتكون الرمز من 4 أرقام';

  @override
  String get pinMismatch => 'الرمزان غير متطابقين';

  @override
  String get pinHelp => 'ستكتب هذا الرمز لفتح التطبيق. لا تشاركه.';

  @override
  String get nextStep => 'التالي';

  @override
  String get previousStep => 'رجوع';

  @override
  String get finishSetup => 'إنهاء';

  @override
  String get loginTitle => 'من أنت؟';

  @override
  String get loginEnterPin => 'أدخل رمزك السري';

  @override
  String loginWrongPin(int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'بقيت $left محاولة.',
      few: 'بقيت $left محاولات.',
      two: 'بقيت محاولتان.',
      one: 'بقيت محاولة واحدة.',
    );
    return 'رمز خاطئ. $_temp0';
  }

  @override
  String get roleOwner => 'المالك';

  @override
  String get roleWorker => 'عامل';

  @override
  String get teamSection => 'الفريق';

  @override
  String get workersTitle => 'العمال';

  @override
  String get workersSub => 'إضافة، تعديل، تعطيل';

  @override
  String get addWorker => 'إضافة عامل';

  @override
  String get editAccount => 'تعديل الحساب';

  @override
  String get workerNameHint => 'مثال: أمين قاسي';

  @override
  String get newPinLabel => 'رمز سري جديد (4 أرقام)';

  @override
  String get pinKeepHint => 'اتركه فارغًا للإبقاء على الرمز الحالي';

  @override
  String get activeLabel => 'الحساب مفعّل';

  @override
  String get activeHelp =>
      'لا يمكن للحساب المعطّل تسجيل الدخول. يبقى سجله محفوظًا.';

  @override
  String get inactiveBadge => 'معطّل';

  @override
  String get accountSaved => 'تم حفظ الحساب';

  @override
  String get noWorkersBody => 'أضف عمالك: لكل واحد رمزه السري.';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get myStatsTitle => 'مبيعاتي';

  @override
  String get periodWeek => 'هذا الأسبوع';

  @override
  String get periodMonth => 'هذا الشهر';

  @override
  String get statRevenue => 'رقم الأعمال';

  @override
  String get statSales => 'المبيعات';

  @override
  String get statItems => 'المواد المباعة';

  @override
  String get statLosses => 'الخسائر المسجلة';

  @override
  String get changePin => 'تغيير رمزي السري';

  @override
  String get currentPinLabel => 'الرمز السري الحالي';

  @override
  String get currentPinWrong => 'الرمز السري الحالي خاطئ';

  @override
  String get pinChanged => 'تم تغيير الرمز السري';

  @override
  String get switchUser => 'تبديل المستخدم';

  @override
  String get switchUserSub => 'العودة إلى شاشة الرمز السري';

  @override
  String get buyPriceLabel => 'سعر الشراء (اختياري)';

  @override
  String get categoryLabel => 'الفئة';

  @override
  String get noCategory => 'بدون فئة';

  @override
  String get newCategory => 'فئة جديدة…';

  @override
  String get categoryNameHint => 'مثال: Boissons';

  @override
  String get lowStockLabel => 'تنبيه المخزون المنخفض عند';

  @override
  String get lowStockHelp =>
      'تنبيه في تبويب التنبيهات عند هذا المستوى. 0 = فقط عندما يصبح المخزون سالباً.';

  @override
  String get quantityInvalid => 'أدخل عددًا صحيحًا';

  @override
  String get historySection => 'سجل التعديلات';

  @override
  String get historyNoChanges => 'لا توجد تعديلات بعد.';

  @override
  String get fieldBuyPrice => 'سعر الشراء';

  @override
  String get fieldLowStock => 'حد المخزون المنخفض';

  @override
  String get fieldArchived => 'مؤرشف';

  @override
  String soldBy(String name) {
    return 'باعه $name';
  }

  @override
  String get commonOk => 'حسنًا';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get pinLengthLabel => 'طول الرمز السري';

  @override
  String pinDigits(int count) {
    return '$count أرقام';
  }

  @override
  String pinLabelN(int count) {
    return 'الرمز السري ($count أرقام)';
  }

  @override
  String newPinLabelN(int count) {
    return 'رمز سري جديد ($count أرقام)';
  }

  @override
  String pinInvalidN(int count) {
    return 'يجب أن يتكون الرمز من $count أرقام';
  }

  @override
  String get pinInvalidAny => 'رمز سري غير صالح';

  @override
  String loginWait(String time) {
    return 'رموز خاطئة كثيرة. أعد المحاولة بعد $time.';
  }

  @override
  String get loginWaitPaused =>
      'العدّ التنازلي يعمل فقط عندما يكون التطبيق مفتوحًا.';

  @override
  String get loginLockedWorker =>
      'هذا الحساب مقفل بعد رموز خاطئة كثيرة. اطلب من المالك فتحه.';

  @override
  String get loginLockedOwner =>
      'هذا الحساب مقفل بعد رموز خاطئة كثيرة. استعمل رمز الاسترجاع.';

  @override
  String get forgotPin => 'نسيت الرمز السري؟';

  @override
  String get recoveryTitle => 'استرجاع الحساب';

  @override
  String get recoveryIntro =>
      'اكتب رمز الاسترجاع الذي دونته عند إنشاء الحساب، ثم اختر رمزًا سريًا جديدًا.';

  @override
  String get recoveryCodeLabel => 'رمز الاسترجاع';

  @override
  String get recoveryCodeHint => 'مثال: K7QM-3WZD-HP9X';

  @override
  String get recoveryCodeWrong => 'رمز الاسترجاع خاطئ. تم تسجيل المحاولة.';

  @override
  String get recoveryShowTitle => 'رمز الاسترجاع الخاص بك';

  @override
  String get recoveryShowBody =>
      'اكتب هذا الرمز على ورقة واحفظه في مكان آمن. يسمح بتغيير الرمز السري للمالك إذا نُسي أو أُقفل. لن يُعرض مرة أخرى.';

  @override
  String get recoveryOldCodeUsed =>
      'تم استعمال الرمز القديم ولم يعد صالحًا. إليك الرمز الجديد.';

  @override
  String get recoveryNoted => 'دونت هذا الرمز';

  @override
  String get recoveryTile => 'رمز الاسترجاع';

  @override
  String get recoveryMissing => 'لم يُنشأ بعد: أنشئه الآن';

  @override
  String get recoveryExists =>
      'تم إنشاؤه. المس لإنشاء رمز جديد (لن يعمل القديم).';

  @override
  String get recoveryMissingBanner =>
      'أنشئ رمز الاسترجاع: بدونه لا يمكن تغيير رمز المالك المنسي أو المقفل.';

  @override
  String get confirmWithPin => 'أدخل رمزك السري الحالي للمتابعة';

  @override
  String get lockedBadge => 'مقفل';

  @override
  String get lockedWorkerCard => 'هذا الحساب مقفل بعد رموز سرية خاطئة كثيرة.';

  @override
  String get unlockAccount => 'فتح الحساب';

  @override
  String get accountUnlocked => 'تم فتح الحساب';

  @override
  String get resetPinLabel => 'رمز سري جديد (لإعادة تعيينه)';

  @override
  String get ownerPinFromProfile => 'غيّر رمزك السري من ملفك الشخصي.';

  @override
  String get failedLoginsTitle => 'محاولات دخول فاشلة';

  @override
  String get failedLoginsSub => 'الرموز الخاطئة حسب الحساب';

  @override
  String failedLoginsWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تمت كتابة $count رمزًا خاطئًا منذ آخر دخول لك.',
      few: 'تمت كتابة $count رموز خاطئة منذ آخر دخول لك.',
      two: 'تمت كتابة رمزين خاطئين منذ آخر دخول لك.',
      one: 'تمت كتابة رمز خاطئ واحد منذ آخر دخول لك.',
    );
    return '$_temp0';
  }

  @override
  String get failedLoginsEmpty => 'لا توجد محاولات فاشلة.';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get securitySection => 'الأمان';

  @override
  String get kindPin => 'الرمز السري';

  @override
  String accountLabel(String name) {
    return 'الحساب: $name';
  }

  @override
  String stockLabel(int count) {
    return 'المخزون: $count';
  }

  @override
  String get outOfStock => 'نفد';

  @override
  String get lowStockBadge => 'مخزون منخفض';

  @override
  String expiresOn(String date) {
    return 'ينتهي $date';
  }

  @override
  String get expiredBadge => 'منتهي الصلاحية';

  @override
  String get expiresSoonBadge => 'قارب على الانتهاء';

  @override
  String get noExpiry => 'بدون تاريخ انتهاء';

  @override
  String get addDelivery => 'استلام سلعة';

  @override
  String get recordLoss => 'تسجيل خسارة';

  @override
  String get lossesTitle => 'الخسائر';

  @override
  String get inStockLabel => 'في المخزون';

  @override
  String get batchesTitle => 'الدفعات';

  @override
  String get batchesEmpty => 'لا يوجد مخزون بعد. أضف استلام سلعة.';

  @override
  String batchRemaining(int remaining, int quantity) {
    return '$remaining من $quantity';
  }

  @override
  String receivedBy(String date, String name) {
    return 'استُلم في $date من طرف $name';
  }

  @override
  String receivedOn(String date) {
    return 'استُلم في $date';
  }

  @override
  String get showEmptyBatches => 'عرض الدفعات المنتهية أيضًا';

  @override
  String missingStock(int count) {
    return '$count بيعت دون مخزون مسجل: أضف الاستلام المنسي.';
  }

  @override
  String get chooseProduct => 'اختر منتجًا';

  @override
  String get quantityLabel => 'الكمية';

  @override
  String get quantityRequired => 'أدخل كمية (1 على الأقل)';

  @override
  String get buyPriceUnitLabel => 'سعر الشراء للوحدة';

  @override
  String get expiryLabel => 'تاريخ انتهاء الصلاحية (اختياري)';

  @override
  String get pickDate => 'اختر تاريخًا';

  @override
  String get noExpiryHelp => 'اتركه فارغًا للمنتجات التي لا تنتهي صلاحيتها.';

  @override
  String get updateBuyPrice => 'استعمله كسعر شراء المنتج';

  @override
  String get noteOptional => 'ملاحظة (اختياري)';

  @override
  String deliverySaved(int count, String name) {
    return 'تمت إضافة $count × $name إلى المخزون';
  }

  @override
  String get saveDelivery => 'إضافة إلى المخزون';

  @override
  String get lossReasonLabel => 'السبب';

  @override
  String get reasonDamaged => 'تالف';

  @override
  String get reasonExpired => 'منتهي الصلاحية';

  @override
  String get reasonStaff => 'استهلكه العمال';

  @override
  String get reasonStolen => 'مسروق';

  @override
  String get reasonOther => 'أخرى';

  @override
  String get lossBatchLabel => 'الدفعة المعنية';

  @override
  String get lossBatchAuto => 'تلقائي (الأقرب انتهاءً)';

  @override
  String batchOption(String date, int remaining) {
    return 'ينتهي $date · متبقي $remaining';
  }

  @override
  String batchOptionNoDate(String date, int remaining) {
    return 'استُلم $date · متبقي $remaining';
  }

  @override
  String lossValuePreview(String amount) {
    return 'القيمة المفقودة تقريبًا: $amount';
  }

  @override
  String lossSaved(String amount) {
    return 'تم تسجيل الخسارة: $amount';
  }

  @override
  String get saveLoss => 'تسجيل الخسارة';

  @override
  String get lossesEmpty => 'لا توجد خسائر مسجلة.';

  @override
  String lossesTotal(String amount) {
    return 'إجمالي الخسارة: $amount';
  }

  @override
  String get lossFromReturn => 'إرجاع زبون';

  @override
  String moreThanStock(int count) {
    return 'لم يتبق سوى $count في المخزون. سيُسجل رغم ذلك.';
  }

  @override
  String get discountLabel => 'تخفيض';

  @override
  String get addDiscount => 'إضافة تخفيض';

  @override
  String get discountAmount => 'مبلغ';

  @override
  String get discountPercent => 'نسبة';

  @override
  String get removeDiscount => 'إزالة التخفيض';

  @override
  String get subtotalLabel => 'المجموع الفرعي';

  @override
  String discountTooHigh(int max) {
    return 'التخفيض مرتفع: الحد الأقصى للعمال $max %.';
  }

  @override
  String get discountInvalid => 'تخفيض غير صالح';

  @override
  String get applyLabel => 'تطبيق';

  @override
  String get stockWarningTitle => 'مخزون غير كافٍ';

  @override
  String get stockWarningBody => 'سيتم تسجيل البيع رغم ذلك.';

  @override
  String get searchTicketHint => 'رقم التذكرة';

  @override
  String get noSaleFound => 'لم يتم العثور على أي بيع.';

  @override
  String get returnButton => 'إرجاع زبون';

  @override
  String get refundedLabel => 'تم استرجاعه';

  @override
  String returnedQty(int count) {
    return '$count مُرجع';
  }

  @override
  String returnTitle(String number) {
    return 'إرجاع البيع رقم $number';
  }

  @override
  String get returnIntro =>
      'اختر المواد المُرجعة وحدد هل تعود إلى الرف أم أنها تالفة.';

  @override
  String get backOnShelf => 'أُعيد إلى الرف';

  @override
  String get returnReasonLabel => 'سبب الإرجاع (اختياري)';

  @override
  String refundToGive(String amount) {
    return 'المبلغ المسترجع للزبون: $amount';
  }

  @override
  String get confirmReturn => 'تأكيد الإرجاع';

  @override
  String returnSaved(String amount) {
    return 'تم تسجيل الإرجاع. أرجع $amount للزبون.';
  }

  @override
  String get returnNothing => 'اختر مادة واحدة على الأقل.';

  @override
  String get rulesSection => 'قواعد المحل';

  @override
  String get maxDiscountLabel => 'أقصى تخفيض للعمال (%)';

  @override
  String get expiryWarnLabel => 'تنبيه انتهاء الصلاحية: أيام قبل';

  @override
  String get percentInvalid => 'بين 0 و 100';

  @override
  String get daysInvalid => 'بين 0 و 60';

  @override
  String get creditSection => 'الكرني والموردون';

  @override
  String get customersTitle => 'الزبائن (الكرني)';

  @override
  String get customersSub => 'ديون الزبائن ومدفوعاتهم';

  @override
  String get suppliersTitle => 'الموردون';

  @override
  String get suppliersSub => 'التوريدات، المدفوعات، الباقي';

  @override
  String get pendingPaymentsTitle => 'مدفوعات للمصادقة';

  @override
  String pendingPaymentsSub(int count) {
    return '$count في الانتظار';
  }

  @override
  String get newCustomer => 'زبون جديد';

  @override
  String get editCustomer => 'تعديل الزبون';

  @override
  String get customerNameHint => 'مثال: محمد سعيدي';

  @override
  String get nameRequired => 'أدخل اسماً';

  @override
  String get creditLimitLabel => 'حد الدين (اختياري)';

  @override
  String get creditLimitHelp => 'فارغ = بلا حد';

  @override
  String get creditLimitOwnerOnly => 'المالك وحده يحدد حد الدين.';

  @override
  String get totalOwedByCustomers => 'مجموع ديون الزبائن';

  @override
  String get debtLabel => 'الدين';

  @override
  String get noDebt => 'لا شيء مستحق';

  @override
  String advanceLabel(String amount) {
    return 'تسبيق: $amount';
  }

  @override
  String get overLimitBadge => 'تجاوز الحد';

  @override
  String creditLimitShort(String amount) {
    return 'الحد: $amount';
  }

  @override
  String get noCustomers => 'لا يوجد زبائن. أضف واحداً بالزر +.';

  @override
  String get searchCustomer => 'الاسم أو الهاتف';

  @override
  String get receivePayment => 'تسجيل دفعة';

  @override
  String get paymentAmountLabel => 'المبلغ';

  @override
  String get amountInvalid => 'أدخل مبلغاً صحيحاً';

  @override
  String paymentTooHigh(String amount) {
    return 'أكثر من الدين ($amount)';
  }

  @override
  String get paymentSaved => 'تم تسجيل الدفعة';

  @override
  String get customerHistory => 'سجل الحساب';

  @override
  String entryCreditSale(String number) {
    return 'بيع بالدين رقم $number';
  }

  @override
  String get entryPayment => 'دفعة مستلمة';

  @override
  String entryRefund(String number) {
    return 'إرجاع التذكرة رقم $number';
  }

  @override
  String entrySaleDetail(String total, String paid) {
    return 'المجموع $total · المدفوع $paid';
  }

  @override
  String recordedBy(String name) {
    return 'بواسطة $name';
  }

  @override
  String get noHistory => 'لا توجد عمليات بعد.';

  @override
  String archiveTitle(String name) {
    return 'أرشفة $name؟';
  }

  @override
  String get archiveBody => 'لن يظهر في القوائم بعد الآن. يُحتفظ بسجله.';

  @override
  String get archivedDone => 'تمت الأرشفة';

  @override
  String get paymentMode => 'الدفع';

  @override
  String get payCash => 'نقداً';

  @override
  String get payCredit => 'بالدين';

  @override
  String get chooseCustomer => 'اختر زبوناً';

  @override
  String currentDebt(String amount) {
    return 'الدين الحالي: $amount';
  }

  @override
  String get paidNowLabel => 'المدفوع الآن';

  @override
  String get leftOnCredit => 'الباقي بالدين';

  @override
  String get newDebtLabel => 'دين الزبون الجديد';

  @override
  String overLimitWarning(String limit) {
    return 'يتجاوز حد الدين ($limit)';
  }

  @override
  String get customerRequired => 'اختر زبوناً للبيع بالدين.';

  @override
  String get creditLimitTitle => 'تجاوز حد الدين';

  @override
  String creditLimitAsk(String name, String debt, String limit) {
    return 'سيصبح على $name $debt، أكثر من حده $limit. السماح رغم ذلك؟';
  }

  @override
  String creditLimitWorker(String limit) {
    return 'تم تجاوز حد الدين ($limit). اسأل المالك.';
  }

  @override
  String get allowAnyway => 'السماح';

  @override
  String saleSavedCredit(String number, String amount, String name) {
    return 'تم حفظ البيع رقم $number · $amount على حساب $name';
  }

  @override
  String get customerLabel => 'الزبون';

  @override
  String get paidLabel => 'المدفوع';

  @override
  String get onCreditLabel => 'بالدين';

  @override
  String get creditChip => 'دين';

  @override
  String get refundModeLabel => 'طريقة الاسترداد';

  @override
  String get refundToCredit => 'خصم من الدين';

  @override
  String get refundCash => 'إرجاع نقداً';

  @override
  String refundToAccount(String name, String amount) {
    return 'يُخصم من حساب $name: $amount';
  }

  @override
  String returnSavedCredit(String amount) {
    return 'تم حفظ الإرجاع. خُصم $amount من حساب الزبون.';
  }

  @override
  String get newSupplier => 'مورد جديد';

  @override
  String get editSupplier => 'تعديل المورد';

  @override
  String get supplierNameHint => 'مثال: حمود بوعلام';

  @override
  String get noSuppliers => 'لا يوجد موردون. أضف واحداً بالزر +.';

  @override
  String get totalOwedToSuppliers => 'المستحق للموردين';

  @override
  String supplierOwes(String amount) {
    return 'الباقي للدفع: $amount';
  }

  @override
  String supplierAdvance(String amount) {
    return 'مدفوع مسبقاً: $amount';
  }

  @override
  String pendingAmount(String amount) {
    return 'في الانتظار: $amount';
  }

  @override
  String get deliveredLabel => 'المورَّد';

  @override
  String get paidValidatedLabel => 'المدفوع (مصادق عليه)';

  @override
  String get leftToPayLabel => 'الباقي للدفع';

  @override
  String get recordSupplierPayment => 'تسجيل دفعة';

  @override
  String get workerPaymentNotice =>
      'يجب أن يصادق المالك على هذه الدفعة قبل احتسابها.';

  @override
  String get paymentPendingSaved => 'أُرسلت الدفعة إلى المالك للمصادقة';

  @override
  String get statusPending => 'في الانتظار';

  @override
  String get statusValidated => 'مصادق عليه';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get paymentsSection => 'المدفوعات';

  @override
  String get deliveriesSection => 'التوريدات';

  @override
  String get noPayments => 'لا مدفوعات.';

  @override
  String get noDeliveries => 'لا توريدات. اختر هذا المورد عند استلام المخزون.';

  @override
  String paidBy(String name) {
    return 'دفعها $name';
  }

  @override
  String validatedBy(String name) {
    return 'صادق عليها $name';
  }

  @override
  String rejectedBy(String name) {
    return 'رفضها $name';
  }

  @override
  String get validate => 'مصادقة';

  @override
  String get reject => 'رفض';

  @override
  String get rejectPaymentTitle => 'رفض هذه الدفعة؟';

  @override
  String rejectPaymentBody(String amount, String name) {
    return 'لن تُحتسب دفعة $amount إلى $name.';
  }

  @override
  String get paymentValidated => 'تمت المصادقة على الدفعة';

  @override
  String get paymentRejected => 'تم رفض الدفعة';

  @override
  String get noPendingPayments => 'لا مدفوعات في الانتظار.';

  @override
  String get supplierOptional => 'المورد (اختياري)';

  @override
  String get noSupplier => 'بدون مورد';

  @override
  String get searchSupplier => 'ابحث عن مورد';

  @override
  String get savedLabel => 'تم الحفظ';

  @override
  String get alertsTitle => 'التنبيهات';

  @override
  String get alertsEmpty => 'لا توجد تنبيهات. كل شيء على ما يرام!';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get markRead => 'تحديد كمقروء';

  @override
  String alertsUnread(int count) {
    return '$count غير مقروءة';
  }

  @override
  String get alertsReadSection => 'مقروءة';

  @override
  String alertLowStockTitle(String product) {
    return 'مخزون منخفض: $product';
  }

  @override
  String alertLowStockBody(int quantity, int threshold) {
    return 'تبقى $quantity (التنبيه عند $threshold).';
  }

  @override
  String alertOutOfStockTitle(String product) {
    return 'نفاد المخزون: $product';
  }

  @override
  String get alertOutOfStockBody => 'لم يبق شيء في المخزون.';

  @override
  String alertNegativeStockTitle(String product) {
    return 'مخزون سالب: $product';
  }

  @override
  String alertNegativeStockBody(int count) {
    return '$count بيعت دون مخزون مسجل: أضف الاستلام المنسي.';
  }

  @override
  String alertExpiringTitle(String product) {
    return 'ينتهي قريباً: $product';
  }

  @override
  String alertExpiringBody(int remaining, String date) {
    return '$remaining قطعة تنتهي صلاحيتها في $date.';
  }

  @override
  String alertExpiredTitle(String product) {
    return 'منتهي الصلاحية: $product';
  }

  @override
  String alertExpiredBody(int remaining, String date) {
    return '$remaining قطعة انتهت صلاحيتها في $date. سجّل خسارة.';
  }

  @override
  String get alertPaymentTitle => 'دفعة للمصادقة';

  @override
  String alertPaymentBody(String by, String amount, String supplier) {
    return 'دفع $by مبلغ $amount إلى $supplier.';
  }

  @override
  String get alertDeliveryTitle => 'استلام مخزون';

  @override
  String alertDeliveryBody(String by, int quantity, String product) {
    return 'استلم $by $quantity × $product.';
  }

  @override
  String alertCreditTitle(String customer) {
    return 'تجاوز حد الدين: $customer';
  }

  @override
  String alertCreditBody(String debt, String limit) {
    return 'عليه $debt (الحد $limit).';
  }

  @override
  String get alertPinTitle => 'رموز PIN خاطئة';

  @override
  String alertPinBody(int count, String name) {
    return '$count رمز خاطئ على حساب $name.';
  }

  @override
  String get alertReturnTitle => 'إرجاع زبون';

  @override
  String alertReturnBody(String by, String number, String amount) {
    return 'قام $by بإرجاع من التذكرة رقم $number: $amount.';
  }

  @override
  String alertsSummaryTitle(int count) {
    return '$count تنبيهات جديدة';
  }

  @override
  String get alertsSummaryBody => 'افتح تبويب التنبيهات لرؤيتها.';

  @override
  String get notificationsTitle => 'إشعارات الهاتف';

  @override
  String get notificationsSub => 'اختيار التنبيهات التي ترن';

  @override
  String get notificationsIntro =>
      'تبقى التنبيهات دائماً في تبويب التنبيهات. هنا تختار أيها يظهر أيضاً كإشعار على هذا الهاتف.';

  @override
  String get workersSeeNote =>
      'يرى العمال فقط المخزون المنخفض وتواريخ انتهاء الصلاحية.';

  @override
  String get typeLowStock => 'المخزون المنخفض والنفاد';

  @override
  String get typeExpiringSoon => 'قريبة الانتهاء';

  @override
  String get typeExpired => 'منتهية الصلاحية';

  @override
  String get typeNewDelivery => 'استلامات المخزون من العمال';

  @override
  String get typeOverCreditLimit => 'زبائن تجاوزوا حدهم';

  @override
  String get typeReturnMade => 'إرجاعات قام بها العمال';

  @override
  String get notificationsBlocked => 'الإشعارات محظورة على هذا الهاتف.';

  @override
  String get openPhoneSettings => 'فتح الإعدادات';

  @override
  String get sendTestNotification => 'إرسال إشعار تجريبي';

  @override
  String get testNotificationTitle => 'إشعار تجريبي';

  @override
  String get testNotificationBody => 'الإشعارات تعمل.';

  @override
  String get notificationChannel => 'تنبيهات المتجر';

  @override
  String get statsTitle => 'الإحصائيات';

  @override
  String get periodCustom => 'اختيار…';

  @override
  String get everyone => 'الجميع';

  @override
  String get statProfit => 'الربح';

  @override
  String get statAverageTicket => 'متوسط التذكرة';

  @override
  String get statDiscounts => 'التخفيضات الممنوحة';

  @override
  String get statReturns => 'الإرجاعات';

  @override
  String returnsCountSub(int count) {
    return '$count إرجاع';
  }

  @override
  String get statLossesValue => 'الخسائر';

  @override
  String get revenuePerDay => 'رقم الأعمال يومياً';

  @override
  String get revenuePerMonth => 'رقم الأعمال شهرياً';

  @override
  String get salesPerWorker => 'المبيعات حسب الشخص';

  @override
  String workerLine(int count, String discounts, String collected) {
    return '$count بيع · تخفيضات $discounts · من الزبائن $collected';
  }

  @override
  String get costLabel => 'سعر شراء السلع المباعة';

  @override
  String get grossProfitLabel => 'الربح الإجمالي';

  @override
  String get stockLossesLabel => 'خسائر المخزون';

  @override
  String get netProfitLabel => 'الربح الصافي';

  @override
  String get cashSection => 'الصندوق';

  @override
  String get paidAtCounterLabel => 'المحصَّل عند البيع';

  @override
  String get customerPaymentsLabel => 'مدفوعات الزبائن (الكرني)';

  @override
  String get cashRefundsLabel => 'المُرجع نقداً (الإرجاعات)';

  @override
  String get cashInHandLabel => 'المال في الصندوق';

  @override
  String supplierPaidLabel(String amount) {
    return 'المدفوع للموردين: $amount';
  }

  @override
  String get creditStatsSection => 'الدين';

  @override
  String get cashSalesLabel => 'مدفوع نقداً';

  @override
  String get topDebtors => 'أكبر المدينين';

  @override
  String get lossesByReason => 'الخسائر حسب السبب';

  @override
  String get topProducts => 'الأكثر مبيعاً';

  @override
  String productSoldQty(int quantity) {
    return '$quantity مباعة';
  }

  @override
  String get noSalesPeriod => 'لا مبيعات في هذه الفترة.';

  @override
  String get myStatsNote => 'ترى أرقامك فقط.';

  @override
  String get noReceiptReturn => 'إرجاع بدون تذكرة';

  @override
  String get noReceiptExchange => 'استبدال بدون تذكرة';

  @override
  String get exchangeButton => 'استبدال';

  @override
  String exchangeTitle(String number) {
    return 'استبدال التذكرة رقم $number';
  }

  @override
  String get exchangeSwitch => 'يأخذ الزبون سلعاً أخرى (استبدال)';

  @override
  String get returnedItemsSection => 'السلع المُرجعة';

  @override
  String get takenItemsSection => 'السلع التي يأخذها الزبون';

  @override
  String get addReturnedProduct => 'إضافة سلعة مُرجعة';

  @override
  String get addTakenProduct => 'إضافة سلعة مأخوذة';

  @override
  String get noReceiptPriceNote =>
      'بدون تذكرة، يكون الاسترداد بسعر البيع الحالي.';

  @override
  String get returnValueLabel => 'قيمة السلع المُرجعة';

  @override
  String get takenValueLabel => 'قيمة السلع المأخوذة';

  @override
  String customerPays(String amount) {
    return 'يدفع الزبون: $amount';
  }

  @override
  String giveBack(String amount) {
    return 'يُرد للزبون: $amount';
  }

  @override
  String get nothingToSettle => 'لا شيء للدفع أو للإرجاع.';

  @override
  String debtReduced(String amount) {
    return 'خُصم $amount من دين الزبون';
  }

  @override
  String get confirmExchange => 'تأكيد الاستبدال';

  @override
  String get exchangeNothingTaken => 'أضف السلع التي يأخذها الزبون.';

  @override
  String exchangeSaved(String number) {
    return 'تم حفظ الاستبدال: التذكرة رقم $number.';
  }

  @override
  String get ownerApprovalTitle => 'موافقة المالك';

  @override
  String ownerApprovalBody(String name) {
    return 'يجب أن يوافق $name على الإرجاع بدون تذكرة. $name، أدخل رمز PIN:';
  }

  @override
  String get ownerApprovalRefused => 'يجب أن يوافق المالك على هذا الإرجاع.';

  @override
  String get exchangeCreditLabel => 'رصيد (السلع المُرجعة)';

  @override
  String get fromExchangeNote => 'تذكرة استبدال';

  @override
  String alertReturnNoReceiptBody(String by, String amount) {
    return 'استرجع $by سلعاً بدون تذكرة: $amount.';
  }

  @override
  String get alertExchangeTitle => 'استبدال';

  @override
  String alertExchangeBody(String by, String amount, String taken) {
    return 'قام $by باستبدال: مُرجع $amount، مأخوذ $taken.';
  }

  @override
  String get syncTitle => 'المزامنة عبر Wi-Fi';

  @override
  String get syncSub => 'ربط هواتف المتجر';

  @override
  String get syncStandaloneTitle => 'هذا الهاتف غير مرتبط بأي هاتف آخر.';

  @override
  String get syncStandaloneBody =>
      'على هاتف المالك، شغّل المحور: ترتبط به هواتف العمال عبر شبكة Wi-Fi المتجر، دون إنترنت.';

  @override
  String get becomeHub => 'اجعل هذا الهاتف هو الرئيسي';

  @override
  String get hubActive => 'المحور يعمل';

  @override
  String get hubStopped => 'المحور متوقف';

  @override
  String hubAddress(String address) {
    return 'العنوان: $address';
  }

  @override
  String get hubNoWifi => 'لا يوجد Wi-Fi: اربط هذا الهاتف بشبكة Wi-Fi المتجر.';

  @override
  String get hubKeepOpen =>
      'أبقِ التطبيق مفتوحاً أو في الخلفية على هذا الهاتف (لا تغلقه) لكي تتمكن الهواتف الأخرى من المزامنة.';

  @override
  String get pairTitle => 'ربط هاتف';

  @override
  String get pairBody =>
      'على هاتف العامل، اختر «الانضمام إلى متجر» وامسح هذا الرمز. لا تُظهره لأي شخص آخر: فهو يمنح الوصول إلى المتجر.';

  @override
  String get showPairingCode => 'إظهار الرمز';

  @override
  String get linkedPhones => 'الهواتف المرتبطة';

  @override
  String get noLinkedPhones => 'لا يوجد هاتف آخر بعد.';

  @override
  String devicePhoneLabel(String code, String name) {
    return 'الهاتف $code · $name';
  }

  @override
  String get thisPhone => 'هذا الهاتف';

  @override
  String lastSyncAt(String time) {
    return 'آخر مزامنة: $time';
  }

  @override
  String get neverSynced => 'لم تتم المزامنة بعد';

  @override
  String get removePhone => 'إزالة هذا الهاتف';

  @override
  String removePhoneBody(String name) {
    return 'لن يتمكن $name من المزامنة بعد الآن. يُحتفظ بما أرسله سابقاً.';
  }

  @override
  String get phoneRemoved => 'تمت إزالة الهاتف';

  @override
  String linkedTo(String shop, String code) {
    return 'مرتبط بـ $shop · الهاتف $code';
  }

  @override
  String get syncNow => 'زامن الآن';

  @override
  String get syncing => 'جارٍ المزامنة…';

  @override
  String syncDone(int sent, int received) {
    return 'تمت المزامنة: $sent مُرسل، $received مُستلم';
  }

  @override
  String get syncAuto => 'مزامنة تلقائية كل دقيقتين وبعد كل بيع.';

  @override
  String get syncErrUnreachable =>
      'المحور غير موجود. هل هاتف المالك يعمل، على نفس شبكة Wi-Fi، والتطبيق مفتوح؟';

  @override
  String get syncErrSignature =>
      'رُفض رمز المتجر. اربط هذا الهاتف مجدداً برمز المالك.';

  @override
  String get syncErrVersion =>
      'إصدارات مختلفة: ثبّت نفس إصدار التطبيق على الهاتفين.';

  @override
  String get syncErrRemoved => 'أزال المالك هذا الهاتف من المتجر.';

  @override
  String get syncErrOther => 'فشلت المزامنة. أعد المحاولة.';

  @override
  String pendingChanges(int count) {
    return '$count تغيير للإرسال';
  }

  @override
  String get joinShop => 'الانضمام إلى متجر موجود';

  @override
  String get joinTitle => 'الانضمام إلى متجر';

  @override
  String get joinIntro =>
      'على هاتف المالك: المزيد ← المزامنة عبر Wi-Fi ← شغّل المحور وأظهر الرمز. ثم امسحه هنا. يجب أن يكون الهاتفان على نفس شبكة Wi-Fi.';

  @override
  String get scanPairingCode => 'امسح رمز المالك';

  @override
  String get notPairingCode => 'هذا ليس رمز متجر.';

  @override
  String get deviceNameLabel => 'اسم هذا الهاتف';

  @override
  String get deviceNameHint => 'مثال: الصندوق 2';

  @override
  String joinButton(String shop) {
    return 'الانضمام إلى $shop';
  }

  @override
  String get joining => 'جارٍ تنزيل المتجر…';

  @override
  String joined(String code) {
    return 'تم ربط الهاتف (الهاتف $code). سجّل الدخول برمز PIN.';
  }

  @override
  String get leaveShop => 'الانضمام إلى متجر آخر';

  @override
  String get leaveShopSub => 'لهاتف عامل: يمسح هذا الهاتف';

  @override
  String get leaveShopBody =>
      'سيتم مسح كل بيانات هذا الهاتف (المنتجات، المبيعات، الحسابات…). بعدها يمكنه الانضمام إلى متجر المالك. افعل ذلك فقط على هاتف عامل.';

  @override
  String get leaveShopConfirm => 'مسح هذا الهاتف';

  @override
  String alertDuplicateBarcodeTitle(String barcode) {
    return 'رمز شريطي مكرر: $barcode';
  }

  @override
  String alertDuplicateBarcodeBody(String names) {
    return 'المنتجات: $names. ادمجها أو غيّر رمزاً شريطياً.';
  }

  @override
  String alertDuplicateCustomerTitle(String phone) {
    return 'زبون مكرر: $phone';
  }

  @override
  String alertDuplicateCustomerBody(String names) {
    return 'الزبائن: $names. ادمجهم من صفحة الزبون.';
  }

  @override
  String get typeDuplicates => 'تكرارات (منتجات، زبائن)';

  @override
  String get mergeInto => 'دمج مع…';

  @override
  String mergeTitle(String name) {
    return 'الدمج في $name؟';
  }

  @override
  String mergeCustomerBody(String from, String into) {
    return 'تنتقل مبيعات ومدفوعات ودين $from إلى $into، ثم يُؤرشف $from.';
  }

  @override
  String mergeProductBody(String from, String into) {
    return 'تنتقل مبيعات ومخزون وخسائر $from إلى $into، ثم يُؤرشف $from.';
  }

  @override
  String get merge => 'دمج';

  @override
  String get merged => 'تم الدمج';

  @override
  String get hubServiceTitle => 'محور المتجر يعمل';

  @override
  String get hubServiceText => 'يمكن للهواتف الأخرى المزامنة.';

  @override
  String get stockShortBlocked => 'المخزون غير كافٍ. أضف استلام المخزون أولاً.';

  @override
  String stockShortDetail(String product, int count) {
    return '$product: تبقى $count في المخزون.';
  }

  @override
  String get workersSellWithoutStock => 'يمكن للعمال البيع دون مخزون';

  @override
  String get workersSellWithoutStockHelp =>
      'عند التعطيل: لا يمكن للعامل بيع أكثر من المخزون المسجّل. يمكن للمالك البيع دائماً.';

  @override
  String get sheetTitle => 'Google Sheet';

  @override
  String get sheetSub => 'المبيعات المباشرة، تقرير المساء، نسخة Drive';

  @override
  String get sheetIntro =>
      'نسخة من المحل في Google Sheet الخاصة بك: لمتابعة المبيعات عن بعد والاحتفاظ بنسخة احتياطية في Google Drive. تعديل الورقة لا يغيّر التطبيق أبداً.';

  @override
  String get sheetNotConfigured => 'لم يتم الإعداد بعد';

  @override
  String get sheetNotConfiguredOwner =>
      'أنشئ الورقة والسكريبت (انظر الدليل)، ثم امسح رمز الإعداد أدناه.';

  @override
  String get sheetNotConfiguredWorker =>
      'يقوم صاحب المحل بإعداد Google Sheet على هاتفه. يستلم هذا الهاتف الإعداد عبر مزامنة الواي فاي.';

  @override
  String get sheetConnected => 'متصل بـ Google Sheet';

  @override
  String get sheetAllSent => 'تم إرسال كل شيء.';

  @override
  String sheetPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سجلات في الانتظار (تُرسل عند توفر الإنترنت)',
      one: 'سجل واحد في الانتظار (يُرسل عند توفر الإنترنت)',
    );
    return '$_temp0';
  }

  @override
  String sheetLastSend(String time) {
    return 'آخر إرسال: $time';
  }

  @override
  String get sheetNeverSent => 'لم يُرسل شيء بعد.';

  @override
  String get sheetSendNow => 'أرسل الآن';

  @override
  String sheetSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم إرسال $count سجلات',
      one: 'تم إرسال سجل واحد',
      zero: 'لا شيء للإرسال',
    );
    return '$_temp0';
  }

  @override
  String get sheetErrOffline =>
      'لا يوجد إنترنت: كل شيء ينتظر في الهاتف وسيُرسل لاحقاً.';

  @override
  String get sheetErrAccess =>
      'السكريبت يرفض الوصول: في Apps Script تحقق من «التنفيذ باسم: أنا» و«من لديه حق الوصول: أي شخص».';

  @override
  String get sheetErrSignature =>
      'المفتاح مرفوض: تم تغيير المفاتيح في الورقة. امسح رمز الإعداد الجديد.';

  @override
  String get sheetErrServer => 'خطأ في سكريبت Google. حاول لاحقاً.';

  @override
  String get sheetSetupSection => 'الإعداد';

  @override
  String get sheetScan => 'امسح رمز الإعداد';

  @override
  String get sheetScanSub =>
      'في الورقة: قائمة Boutique ← Afficher le code de configuration';

  @override
  String get sheetPaste => 'ألصق الرمز';

  @override
  String get sheetPasteSub =>
      'بدون كاميرا (المحاكي): انسخ الرمز تحت QR في الورقة وألصقه هنا.';

  @override
  String get sheetPasteHint => 'ألصق الرمز هنا';

  @override
  String get sheetNotConfigCode =>
      'هذا ليس رمز إعداد Google Sheet الخاص بالمحل.';

  @override
  String get sheetChecking => 'جارٍ التحقق مع Google…';

  @override
  String sheetConfigured(String name) {
    return 'تم الاتصال بـ «$name». كل ما هو موجود في المحل يُرسل إلى الورقة.';
  }

  @override
  String get sheetDisconnect => 'فصل Google Sheet';

  @override
  String get sheetDisconnectConfirm =>
      'ستتوقف الهواتف عن الإرسال إلى الورقة (هواتف العمال بعد المزامنة القادمة). تحتفظ الورقة بما لديها.';

  @override
  String get sheetPrivacy =>
      'هاتف صاحب المحل فقط يمكنه قراءة الأرقام (مفتاح القراءة). هواتف العمال تضيف أسطراً فقط (مفتاح الكتابة). لا تشارك الورقة.';

  @override
  String get liveSalesTitle => 'المبيعات المباشرة';

  @override
  String get liveSalesSub => 'مبيعات اليوم من كل الهواتف';

  @override
  String get liveNotifyLabel => 'إشعار لكل عملية بيع';

  @override
  String get liveNotifySub => 'رقم التذكرة والبائع والمجموع';

  @override
  String get liveSalesChannel => 'المبيعات المباشرة';

  @override
  String liveSaleTitle(String ticket) {
    return 'بيع جديد رقم $ticket';
  }

  @override
  String liveSaleBody(String seller, String total) {
    return '$seller · $total';
  }

  @override
  String liveSalesManyTitle(int count) {
    return '$count مبيعات جديدة';
  }

  @override
  String liveSalesManyBody(String total) {
    return 'المجموع: $total';
  }

  @override
  String get liveToday => 'اليوم (بعد المرتجعات)';

  @override
  String liveSalesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مبيعات',
      one: 'بيع واحد',
      zero: 'لا مبيعات',
    );
    return '$_temp0';
  }

  @override
  String liveCheckedAt(String time) {
    return 'تم التحقق على $time';
  }

  @override
  String get liveNote =>
      'يتم التحديث كل 30 ثانية ما دامت هذه الشاشة مفتوحة. عند إغلاق التطبيق يتحقق أندرويد كل 15 دقيقة تقريباً، فتصل الإشعارات على دفعات.';

  @override
  String get liveEmpty => 'لا توجد مبيعات اليوم بعد.';

  @override
  String liveSaleTicket(String ticket) {
    return 'بيع رقم $ticket';
  }

  @override
  String liveReturn(String ticket) {
    return 'إرجاع $ticket';
  }

  @override
  String get dailyReportLabel => 'تقرير المساء';

  @override
  String get dailyReportSub =>
      'كل مساء: مبيعات اليوم ورقم الأعمال والربح والنقود في الصندوق والمرتجعات';

  @override
  String get dailyReportTime => 'وقت التقرير';

  @override
  String get dailyReportOpen => 'عرض التقرير';

  @override
  String get dailyReportChannel => 'تقرير المساء';

  @override
  String dailyReportTitle(String date) {
    return 'تقرير $date';
  }

  @override
  String dailyReportBody(
      int sales, String revenue, String profit, String cash, String returns) {
    return '$sales مبيعات · رقم الأعمال $revenue · الربح $profit · الصندوق $cash · المرتجعات $returns';
  }

  @override
  String get dailyReportNone =>
      'لا يوجد تقرير بعد. يصل كل مساء في الوقت المختار.';

  @override
  String get dailyReportToday => 'احسب اليوم';

  @override
  String get reportSales => 'المبيعات';

  @override
  String get reportRevenue => 'رقم الأعمال';

  @override
  String get reportProfit => 'الربح';

  @override
  String get reportCash => 'النقود في الصندوق';

  @override
  String get reportReturns => 'المرتجعات';

  @override
  String get reportFromSheet =>
      'حسب Google Sheet (كل الهواتف التي كان لديها إنترنت).';

  @override
  String get reportFromPhone =>
      'حسب هذا الهاتف (المبيعات المستلمة عبر الواي فاي).';

  @override
  String get driveSection => 'النسخ الاحتياطي في Google Drive';

  @override
  String get driveNever => 'لا توجد نسخة احتياطية في Google Drive بعد.';

  @override
  String driveLast(String time) {
    return 'آخر نسخة في Drive: $time';
  }

  @override
  String get driveInfo =>
      'مرة في اليوم، عند توفر الإنترنت (يفضل الواي فاي)، تُرسل نسخة احتياطية إلى مجلد «Sauvegardes Boutique» في Google Drive. يتم الاحتفاظ بآخر 30 نسخة.';

  @override
  String get driveBackupNow => 'احفظ الآن';

  @override
  String get driveDone => 'تم حفظ النسخة في Google Drive.';

  @override
  String get backupWarning =>
      'لم تخرج أي نسخة احتياطية من الهاتف منذ أكثر من 7 أيام. إذا ضاع الهاتف ضاعت البيانات.';

  @override
  String get backupTitle => 'النسخ الاحتياطي والاستعادة';

  @override
  String get backupSub => 'الاحتفاظ بنسخة خارج الهاتف';

  @override
  String get backupIntro =>
      'النسخة الاحتياطية ملف .zip فيه كل بيانات المحل. احتفظ بواحدة خارج الهاتف: Google Drive، واتساب، مفتاح USB…';

  @override
  String get backupNeverOff => 'لم تخرج أي نسخة احتياطية من الهاتف بعد.';

  @override
  String backupLastOff(String time) {
    return 'آخر نسخة خارج الهاتف: $time';
  }

  @override
  String get backupShare => 'إنشاء نسخة وإرسالها';

  @override
  String get backupShareSub => 'Drive، واتساب، بريد، بلوتوث…';

  @override
  String get backupShareSubject => 'نسخة احتياطية للمحل';

  @override
  String get backupDriveTile => 'نسخ تلقائي إلى Google Drive';

  @override
  String get backupDriveOn => 'مفعّل: مرة في اليوم';

  @override
  String get backupDriveOff => 'قم بإعداد Google Sheet لتفعيله';

  @override
  String get backupPrivate =>
      'تحتوي النسخة على كل المحل (المبيعات، الزبائن، أسعار الشراء). أرسلها لنفسك فقط، وليس إلى مجموعة.';

  @override
  String get restoreTitle => 'استعادة نسخة احتياطية';

  @override
  String get restoreSub => 'تستبدل بيانات هذا الهاتف';

  @override
  String get restoreFromBackup => 'استعادة نسخة احتياطية (هاتف جديد)';

  @override
  String get restoreIntro =>
      'اختر ملف نسخة احتياطية لهذا المحل (في التنزيلات، أو في Google Drive ← Sauvegardes Boutique).';

  @override
  String get restoreIntroNew =>
      'هاتف جديد: اختر آخر نسخة احتياطية لمحلك (Google Drive ← Sauvegardes Boutique). ستكتب الرمز السري لصاحب المحل.';

  @override
  String get restorePick => 'اختر ملف النسخة الاحتياطية';

  @override
  String restoreMadeOn(String time) {
    return 'نسخة بتاريخ $time';
  }

  @override
  String get restoreWarning =>
      'سيتم استبدال بيانات هذا الهاتف ببيانات النسخة. تُحفظ نسخة من البيانات الحالية قبل ذلك احتياطاً.';

  @override
  String get restoreButton => 'استعادة';

  @override
  String get restorePinTitle => 'الرمز السري لصاحب المحل';

  @override
  String get restoreReadyTitle => 'الاستعادة جاهزة';

  @override
  String get restoreReadyBody =>
      'سيُغلق التطبيق. أعد فتحه: سيبدأ ببيانات النسخة. بعدها امسح رمز Google Sheet مرة أخرى إن كنت تستعمله.';

  @override
  String get restoreClose => 'أغلق التطبيق';

  @override
  String get restoreErrNotBackup =>
      'هذا الملف ليس نسخة احتياطية لهذا التطبيق (أو أنه تالف).';

  @override
  String get restoreErrNewer =>
      'هذه النسخة من إصدار أحدث للتطبيق. حدّث هذا الهاتف أولاً.';

  @override
  String get restoreErrOtherShop => 'هذه النسخة تخص محلاً آخر.';

  @override
  String get restoreErrPin => 'الرمز السري لصاحب المحل غير صحيح.';

  @override
  String get restoreErrWorker =>
      'هاتف العامل يستلم بياناته من الهاتف الرئيسي: قم بالاستعادة على الهاتف الرئيسي.';

  @override
  String scanUnknown(String code) {
    return 'رمز شريطي غير معروف: $code';
  }

  @override
  String get scanCreateProduct => 'إنشاء المنتج';

  @override
  String scanNotOnTicket(String name) {
    return '«$name» ليس في هذه التذكرة (أو تم إرجاعه).';
  }

  @override
  String get scanGoesTo => 'الماسح يضيف إلى:';

  @override
  String get scanToReturned => 'المواد المرجعة';

  @override
  String get scanToTaken => 'المواد المأخوذة';

  @override
  String get scannerTitle => 'ماسح الرموز الشريطية';

  @override
  String get scannerSub => 'ماسح بلوتوث: الاقتران والتجربة';

  @override
  String get scannerTestTitle => 'جرّب مسحاً';

  @override
  String get scannerTestWaiting =>
      'امسح رمزاً شريطياً الآن (أو في المحاكي اكتب أرقاماً ثم Enter).';

  @override
  String scannerTestGot(int count, String code) {
    return 'تم استلام المسح رقم $count: $code';
  }

  @override
  String scannerTestKnown(String name) {
    return 'المنتج: $name';
  }

  @override
  String get scannerTestUnknown => 'منتج غير معروف (الماسح يعمل رغم ذلك).';

  @override
  String get scannerHowTitle => 'ربط ماسح بلوتوث';

  @override
  String get scannerHowSteps =>
      '1. شغّل الماسح.\n2. في دليله الصغير، امسح رمز «Bluetooth HID» (وضع لوحة المفاتيح). هذا هو الوضع المنصوح به.\n3. على الهاتف: الإعدادات ← بلوتوث ← إقران جهاز جديد ← اختر الماسح.\n4. هذا كل شيء: يعمل في البيع واستلام المخزون والخسائر والمرتجعات والبحث وبطاقة المنتج الجديد، دون لمس أي خانة.';

  @override
  String get scannerEmulatorTip =>
      'في المحاكي: انقر داخل نافذة المحاكي، اكتب رمزاً شريطياً بلوحة مفاتيح الحاسوب، ثم Enter.';

  @override
  String get scannerSppTitle => 'ماسح في وضع SPP (تسلسلي)';

  @override
  String get scannerSppHelp =>
      'فقط إذا كان الماسح في وضع «SPP»: اقرنه أولاً في إعدادات البلوتوث ثم اختره هنا. يعيد الهاتف الاتصال به تلقائياً.';

  @override
  String get scannerShowPaired => 'عرض الأجهزة المقترنة';

  @override
  String scannerConnected(String name) {
    return 'الماسح متصل: $name';
  }

  @override
  String get scannerConnectFailed =>
      'تعذر الاتصال. تحقق أن الماسح مشغّل وفي وضع SPP.';

  @override
  String get scannerStateConnected => 'متصل';

  @override
  String get scannerStateConnecting => 'جارٍ الاتصال…';

  @override
  String get scannerStateRetrying => 'غير متصل: محاولة جديدة كل 15 ثانية';

  @override
  String get scannerForget => 'إلغاء';

  @override
  String get scannerFeedback => 'صوت واهتزاز عند كل مسح مقبول';

  @override
  String sheetAccount(String email) {
    return 'حساب Google: $email';
  }

  @override
  String get sheetAccountUnknown => 'غير معروف (حدّث السكريبت)';
}
