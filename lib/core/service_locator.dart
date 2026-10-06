import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/auth/data/login_guard.dart';
import '../../features/auth/data/login_service.dart';
import '../../features/billing/data/receipt_printer.dart';
import '../../features/billing/data/repositories/sale_repository_impl.dart';
import '../../features/billing/domain/repositories/sale_repository.dart';
import '../../features/billing/presentation/bloc/billing_bloc.dart';
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
import '../../features/stock/data/stock_ledger.dart';
import '../../features/stock/domain/repositories/stock_repository.dart';
import '../../features/settings/domain/repositories/printer_repository.dart';
import '../../features/settings/presentation/bloc/printer_bloc.dart';
import '../../features/settings/presentation/cubit/app_preferences_cubit.dart';
import '../../features/users/data/repositories/user_repository_impl.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import 'database/app_database.dart';
import 'database/hive_importer.dart';
import 'session/session_cubit.dart';
import 'settings/settings_store.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core - Database & phone settings
  final db = AppDatabase();
  sl.registerSingleton<AppDatabase>(db);
  final settings = SettingsStore(db);
  await settings.load();
  sl.registerSingleton<SettingsStore>(settings);

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
    () => SaleRepositoryImpl(sl(), sl(), sl(), sl()),
  );
  sl.registerLazySingleton(() => ReceiptPrinter(sl()));

  // Features - Stock (deliveries, batches, losses)
  sl.registerLazySingleton(() => StockLedger(sl()));
  sl.registerLazySingleton<StockRepository>(
    () => StockRepositoryImpl(sl(), sl(), sl(), sl(), sl()),
  );

  // Features - Settings / Printer
  sl.registerLazySingleton<PrinterRepository>(
    () => PrinterRepositoryImpl(sl()),
  );
}
