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
  String get comingSoonTitle => 'قريبًا';

  @override
  String get comingSoonStats => 'الإحصائيات ستتوفر في مرحلة قادمة.';

  @override
  String get comingSoonAlerts => 'التنبيهات والإشعارات ستتوفر في مرحلة قادمة.';

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
  String saleSaved(int number) {
    return 'تم حفظ البيع رقم $number';
  }

  @override
  String saleSavedAndPrinted(int number) {
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
  String saleTitle(int number) {
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
  String get lowStockHelp => '0 = بدون تنبيه. التنبيهات في المرحلة 5.';

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
  String returnTitle(int number) {
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
}
