import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/alerts/data/alert_repository.dart';
import '../../features/alerts/data/phone_notifier.dart';
import '../../features/alerts/presentation/alerts_cubit.dart';
import '../../features/auth/data/login_guard.dart';
import '../../features/auth/data/owner_approval.dart';
import '../../features/auth/data/login_service.dart';
import '../../features/backup/data/backup_service.dart';
import '../../features/sheet/data/cloud_background.dart';
import '../../features/sheet/data/cloud_jobs.dart';
import '../../features/sheet/data/sheet_settings.dart';
import '../../features/sheet/presentation/sheet_cubit.dart';
import '../../features/billing/data/receipt_printer.dart';
import '../../features/billing/data/repositories/sale_repository_impl.dart';
import '../../features/billing/domain/repositories/sale_repository.dart';
import '../../features/billing/presentation/bloc/billing_bloc.dart';
import '../../features/customers/data/repositories/customer_repository_impl.dart';
import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/suppliers/data/repositories/supplier_repository_impl.dart';
import '../../features/suppliers/domain/repositories/supplier_repository.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/product_usecases.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';
import '../../features/shop/data/repositories/shop_repository_impl.dart';
import '../../features/shop/domain/repositories/shop_repository.dart';
import '../../features/shop/domain/usecases/shop_usecases.dart';
import '../../features/shop/presentation/bloc/shop_bloc.dart';
import '../../features/settings/data/repositories/printer_repository_impl.dart';
import '../../features/stock/data/repositories/stock_repository_impl.dart';
import '../../features/stats/data/stats_repository.dart';
import '../../features/stock/data/stock_ledger.dart';
import '../../features/stock/domain/repositories/stock_repository.dart';
import '../../features/settings/domain/repositories/printer_repository.dart';
import '../../features/settings/presentation/bloc/printer_bloc.dart';
import '../../features/settings/presentation/cubit/app_preferences_cubit.dart';
import '../../features/sync/data/hub_keep_alive.dart';
import '../../features/sync/data/hub_service.dart';
import '../../features/sync/data/merge_service.dart';
import '../../features/sync/data/sync_client.dart';
import '../../features/sync/data/sync_network.dart';
import '../../features/sync/data/sync_settings.dart';
import '../../features/sync/data/sync_store.dart';
import '../../features/sync/presentation/sync_cubit.dart';
import '../../features/users/data/repositories/user_repository_impl.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import 'database/app_database.dart';
import 'database/hive_importer.dart';
import 'l10n/app_localizations.dart';
import 'session/session_cubit.dart';
import 'settings/settings_store.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // A backup restored last time replaces the database before it opens.
  var restored = false;
  try {
    restored = await BackupService.applyPendingRestore();
  } catch (e, stack) {
    debugPrint('Restore failed: $e\n$stack');
  }

  // Core - Database & phone settings
  final db = AppDatabase();
  sl.registerSingleton<AppDatabase>(db);
  final settings = SettingsStore(db);
  await settings.load();
  sl.registerSingleton<SettingsStore>(settings);
  if (restored) await afterRestore(settings);

  // Bring over the data of the previous app version (only once).
  try {
    await HiveImporter(db: db, settings: settings, initHive: Hive.initFlutter)
        .importIfNeeded();
  } catch (e, stack) {
    // Never block the app; the import is tried again next launch.
    debugPrint('Hive import failed: $e\n$stack');
  }

  // Core - Who is logged in
  final users = UserRepositoryImpl(db, settings);
  sl.registerSingleton<UserRepository>(users);
  sl.registerSingleton(SessionCubit(hasOwner: await users.hasOwner()));
  sl.registerLazySingleton(() => LoginGuard(sl()));
  sl.registerLazySingleton(() => LoginService(sl(), sl()));

  // Features - Product
  // Bloc
  sl.registerFactory(
    () => ProductBloc(
      getProductsUseCase: sl(),
      addProductUseCase: sl(),
      updateProductUseCase: sl(),
      archiveProductUseCase: sl(),
      stockRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => ShopBloc(
      getShopUseCase: sl(),
      updateShopUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => PrinterBloc(
      repository: sl(),
    ),
  );

  sl.registerFactory(
    () => BillingBloc(
      getProductByBarcodeUseCase: sl(),
      saleRepository: sl(),
      receiptPrinter: sl(),
    ),
  );

  sl.registerFactory(() => AppPreferencesCubit(sl()));

  // Use cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => AddProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));
  sl.registerLazySingleton(() => ArchiveProductUseCase(sl()));
  sl.registerLazySingleton(() => GetProductByBarcodeUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl(), sl(), sl()),
  );

  // Features - Shop
  // Use cases
  sl.registerLazySingleton(() => GetShopUseCase(sl()));
  sl.registerLazySingleton(() => UpdateShopUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ShopRepository>(
    () => ShopRepositoryImpl(sl(), sl()),
  );

  // Features - Billing / Sales
  sl.registerLazySingleton<SaleRepository>(
    () => SaleRepositoryImpl(sl(), sl(), sl(), sl(),
        ownerApproval: ownerApprovalWith(sl())),
  );
  sl.registerLazySingleton(() => ReceiptPrinter(sl()));

  // Features - Stock (deliveries, batches, losses)
  sl.registerLazySingleton(() => StockLedger(sl()));
  sl.registerLazySingleton<StockRepository>(
    () => StockRepositoryImpl(sl(), sl(), sl(), sl(), sl()),
  );

  // Features - Customers (carnet) and suppliers
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<SupplierRepository>(
    () => SupplierRepositoryImpl(sl(), sl(), sl()),
  );

  // Features - Settings / Printer
  sl.registerLazySingleton<PrinterRepository>(
    () => PrinterRepositoryImpl(sl()),
  );

  // Features - Wi-Fi sync between the shop's phones
  final store = SyncStore(db);
  sl.registerSingleton(store);
  final hub = HubService(db, store, settings);
  sl.registerSingleton(hub);
  sl.registerLazySingleton(() => MergeService(sl(), sl()));
  sl.registerSingleton(SyncCubit(
    db: db,
    store: store,
    settings: settings,
    hub: hub,
    server: HubServer(hub),
    client: SyncClient(db, store, settings, const HttpSyncTransport(),
        finder: HubFinder()),
    keepAlive: ForegroundHubKeepAlive(),
    session: sl(),
    locale: () => notificationLocale(settings),
  ));

  // Features - Statistics
  sl.registerLazySingleton(() => StatsRepository(sl()));

  // Features - Alerts and phone notifications
  final notifier = LocalPhoneNotifier(settings);
  try {
    await notifier.init();
  } catch (e, stack) {
    // The Alertes tab works even if the phone refuses notifications.
    debugPrint('Notifications unavailable: $e\n$stack');
  }
  sl.registerSingleton<PhoneNotifier>(notifier);
  sl.registerLazySingleton(() => AlertRepository(sl(), sl()));
  sl.registerLazySingleton(() => AlertsCubit(
        db: sl(),
        repository: sl(),
        notifier: sl(),
        settings: sl(),
        session: sl(),
        locale: () => notificationLocale(settings),
      ));

  // Features - Google Sheet, live sales, evening report, backups
  sl.registerLazySingleton(() => BackupService(sl(), sl()));
  final jobs = CloudJobs.build(
    db: db,
    settings: settings,
    notifier: notifier,
    locale: () => notificationLocale(settings),
  );
  sl.registerSingleton(jobs);
  final scheduler = WorkmanagerCloudScheduler();
  sl.registerSingleton<CloudScheduler>(scheduler);
  sl.registerSingleton(SheetCubit(
    db: db,
    settings: settings,
    jobs: jobs,
    store: store,
    scheduler: scheduler,
  ));
}

/// After a backup was restored: the worker phones must send everything
/// again (new sync epoch), and "Ventes en direct" starts from today.
Future<void> afterRestore(SettingsStore settings) async {
  await settings.setSyncEpoch(null);
  await settings.set(SheetSettings.liveSalesRowName, null);
  await settings.set(SheetSettings.liveReturnsRowName, null);
}

/// The language of phone notifications: the one chosen in the app, or
/// the phone's language when "follow the phone" is chosen.
Locale notificationLocale(SettingsStore settings) {
  final language = settings.get(SettingsKeys.language);
  if (supportedLanguageCodes.contains(language)) return Locale(language!);
  return resolveAppLocale(
      PlatformDispatcher.instance.locale, AppLocalizations.supportedLocales);
}
