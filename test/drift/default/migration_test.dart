// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:billing_app/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // Phase 1 phones already hold real products, sales and settings: the
  // upgrade to version 2 must keep every one of them unchanged.
  test('migration from v1 to v2 keeps products, sales and settings', () async {
    const at = '2026-10-06T14:32:00.000';
    const product = v1.ProductsData(
        id: 'p1',
        createdAt: at,
        updatedAt: at,
        deviceId: 'phone-1',
        deleted: 0,
        name: 'Jus Rouiba 1L',
        barcode: '613',
        sellPrice: 18000,
        buyPrice: 14000,
        lowStockThreshold: 0,
        archived: 0);
    const sale = v1.SalesData(
        id: 's1',
        createdAt: at,
        updatedAt: at,
        deviceId: 'phone-1',
        deleted: 0,
        number: 1,
        subtotal: 18000,
        discount: 0,
        total: 18000,
        paidNow: 18000);
    const setting = v1.AppSettingsData(key: 'language', value: 'ar');

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(oldDb.products, product);
        batch.insert(oldDb.sales, sale);
        batch.insert(oldDb.appSettings, setting);
      },
      validateItems: (newDb) async {
        final products = await newDb.select(newDb.products).get();
        expect(products.map((p) => (p.id, p.name, p.sellPrice)),
            [('p1', 'Jus Rouiba 1L', 18000)]);
        final sales = await newDb.select(newDb.sales).get();
        expect(sales.map((s) => (s.id, s.number, s.total)), [('s1', 1, 18000)]);
        final settings = await newDb.select(newDb.appSettings).get();
        expect(settings.map((s) => (s.key, s.value)), [('language', 'ar')]);
        expect(await newDb.select(newDb.users).get(), isEmpty);
      },
    );
  });

  // Phase 2 phones already have an owner and workers: after the upgrade
  // they keep their PIN and get the safe defaults (4 digits, not locked,
  // no recovery code yet).
  test('migration from v2 to v3 keeps accounts and their PINs', () async {
    const at = '2026-10-06T14:32:00.000';
    const owner = v2.UsersData(
        id: 'u1',
        createdAt: at,
        updatedAt: at,
        deviceId: 'phone-1',
        deleted: 0,
        name: 'Karim',
        phone: '0555',
        role: 'owner',
        pinHash: 'hash',
        pinSalt: 'salt',
        active: 1);

    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(oldDb.users, owner),
      validateItems: (newDb) async {
        final user = await newDb.select(newDb.users).getSingle();
        expect(
            (user.name, user.pinHash, user.pinSalt), ('Karim', 'hash', 'salt'));
        expect(user.pinLength, 4);
        expect(user.lockedOut, 0); // 0 = false in the snapshot
        expect(user.recoveryHash, isNull);
        expect(await newDb.select(newDb.failedLogins).get(), isEmpty);
      },
    );
  });

  // Phase 2b phones hold deliveries (opening stock) and sales: the
  // upgrade to v4 keeps them and starts with no losses or returns.
  test('migration from v3 to v4 keeps deliveries and sales', () async {
    const at = '2026-10-06T14:32:00.000';
    const delivery = v3.DeliveriesData(
        id: 'd1',
        createdAt: at,
        updatedAt: at,
        deviceId: 'phone-1',
        deleted: 0,
        productId: 'p1',
        quantity: 7,
        buyPrice: 0,
        receivedAt: at);
    const sale = v3.SalesData(
        id: 's1',
        createdAt: at,
        updatedAt: at,
        deviceId: 'phone-1',
        deleted: 0,
        number: 1,
        subtotal: 100,
        discount: 0,
        total: 100,
        paidNow: 100);

    await verifier.testWithDataIntegrity(
      oldVersion: 3,
      newVersion: 4,
      createOld: v3.DatabaseAtV3.new,
      createNew: v4.DatabaseAtV4.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(oldDb.deliveries, delivery);
        batch.insert(oldDb.sales, sale);
      },
      validateItems: (newDb) async {
        final deliveries = await newDb.select(newDb.deliveries).get();
        expect(deliveries.map((d) => (d.id, d.quantity)), [('d1', 7)]);
        expect((await newDb.select(newDb.sales).get()).single.id, 's1');
        expect(await newDb.select(newDb.losses).get(), isEmpty);
        expect(await newDb.select(newDb.stockAllocations).get(), isEmpty);
      },
    );
  });
}
