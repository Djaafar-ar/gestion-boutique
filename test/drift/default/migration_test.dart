// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:billing_app/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

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
}
