import 'dart:io';

import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/database/hive_importer.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory hiveDir;
  late AppDatabase db;
  late SettingsStore settings;

  HiveImporter importer() => HiveImporter(
        db: db,
        settings: settings,
        initHive: () async => Hive.init(hiveDir.path),
      );

  /// Writes data exactly like the previous app version did.
  Future<void> writeOldAppData() async {
    Hive.init(hiveDir.path);
    if (!Hive.isAdapterRegistered(LegacyProductAdapter.id)) {
      Hive.registerAdapter(LegacyProductAdapter());
      Hive.registerAdapter(LegacyShopAdapter());
    }
    final products = await Hive.openBox<LegacyProduct>('products');
    await products.put(
        'a',
        const LegacyProduct(
            id: 'a', name: 'Lait Candia 1L', barcode: '613', price: 120.5));
    await products.put(
        'b',
        const LegacyProduct(
            id: 'b', name: 'Café', barcode: '614', price: 250, stock: 7));
    final shop = await Hive.openBox<LegacyShop>('shop');
    await shop.put(
        'shop_details',
        const LegacyShop(
            name: 'Épicerie El Baraka',
            addressLine1: 'Rue 5',
            phoneNumber: '0555',
            upiId: 'old@upi',
            footerText: 'Merci'));
    final oldSettings = await Hive.openBox('settings');
    await oldSettings.put('printer_mac', 'AA:BB');
    await oldSettings.put('printer_name', 'MTP-II');
    await Hive.close();
  }

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('hive_import_test');
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsStore(db);
    await settings.load();
  });

  tearDown(() async {
    await Hive.close();
    await db.close();
    await hiveDir.delete(recursive: true);
  });

  test('old products, shop and printer are copied into the new database',
      () async {
    await writeOldAppData();

    final count = await importer().importIfNeeded();

    expect(count, 2);
    final products = await db.select(db.products).get();
    final milk = products.firstWhere((p) => p.id == 'a');
    expect(milk.name, 'Lait Candia 1L');
    expect(milk.barcode, '613');
    expect(milk.sellPrice, 12050); // 120,50 DA in centimes

    // The old stock number becomes an opening delivery.
    final deliveries = await db.select(db.deliveries).get();
    expect(deliveries, hasLength(1));
    expect(deliveries.single.productId, 'b');
    expect(deliveries.single.quantity, 7);

    final shop = await db.select(db.shops).getSingle();
    expect(shop.name, 'Épicerie El Baraka');
    expect(shop.address1, 'Rue 5');
    expect(shop.footer, 'Merci');
    expect(shop.shopSecret, hasLength(64));

    expect(settings.get(SettingsKeys.printerMac), 'AA:BB');
    expect(settings.get(SettingsKeys.printerName), 'MTP-II');
    expect(settings.get(SettingsKeys.hiveImported), 'true');
  });

  test('the import runs only once', () async {
    await writeOldAppData();
    await importer().importIfNeeded();

    final secondRun = await importer().importIfNeeded();

    expect(secondRun, 0);
    expect(await db.select(db.products).get(), hasLength(2));
    expect(await db.select(db.deliveries).get(), hasLength(1));
  });

  test('a brand new install has nothing to import', () async {
    final count = await importer().importIfNeeded();

    expect(count, 0);
    expect(await db.select(db.products).get(), isEmpty);
    expect(await db.select(db.shops).get(), isEmpty);
    expect(settings.get(SettingsKeys.hiveImported), 'true');
  });
}
