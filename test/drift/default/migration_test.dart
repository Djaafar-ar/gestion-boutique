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
import 'generated/schema_v5.dart' as v5;
import 'generated/schema_v6.dart' as v6;
import 'generated/schema_v7.dart' as v7;
import 'generated/schema_v8.dart' as v8;
import 'generated/schema_v9.dart' as v9;
import 'generated/schema_v10.dart' as v10;

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

  // Phase 4 adds suppliers and customer credit: old sales stay cash sales
  // and old deliveries have no supplier.
  test('migration from v4 to v5 keeps deliveries and sales', () async {
    const at = '2026-10-06T14:32:00.000';
    const delivery = v4.DeliveriesData(
        id: 'd1',
        createdAt: at,
        updatedAt: at,
        deviceId: 'phone-1',
        deleted: 0,
        productId: 'p1',
        quantity: 7,
        buyPrice: 4000,
        receivedAt: at);
    const sale = v4.SalesData(
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
      oldVersion: 4,
      newVersion: 5,
      createOld: v4.DatabaseAtV4.new,
      createNew: v5.DatabaseAtV5.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(oldDb.deliveries, delivery);
        batch.insert(oldDb.sales, sale);
      },
      validateItems: (newDb) async {
        final deliveries = await newDb.select(newDb.deliveries).get();
        expect(deliveries.map((d) => (d.id, d.supplierId)), [('d1', null)]);
        final sales = await newDb.select(newDb.sales).get();
        expect(sales.map((s) => (s.id, s.customerId, s.paidNow)),
            [('s1', null, 100)]);
        expect(await newDb.select(newDb.suppliers).get(), isEmpty);
        expect(await newDb.select(newDb.customers).get(), isEmpty);
      },
    );
  });

  // Phase 5 adds alerts: the shop data stays, and there are no alerts
  // until the app first looks for them.
  test('migration from v5 to v6 keeps customers and starts with no alerts',
      () async {
    const at = '2026-10-06T14:32:00.000';
    const customer = v5.CustomersData(
        id: 'c1',
        createdAt: at,
        updatedAt: at,
        deviceId: 'phone-1',
        deleted: 0,
        name: 'Mohamed',
        phone: '0555',
        creditLimit: 100000,
        active: 1);

    await verifier.testWithDataIntegrity(
      oldVersion: 5,
      newVersion: 6,
      createOld: v5.DatabaseAtV5.new,
      createNew: v6.DatabaseAtV6.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(oldDb.customers, customer),
      validateItems: (newDb) async {
        final customers = await newDb.select(newDb.customers).get();
        expect(customers.map((c) => (c.id, c.creditLimit)), [('c1', 100000)]);
        expect(await newDb.select(newDb.alerts).get(), isEmpty);
        expect(await newDb.select(newDb.alertReads).get(), isEmpty);
      },
    );
  });

  // Returns without a receipt: the tables are rebuilt so a return may
  // have no ticket. Returns made before must keep their ticket.
  test('migration from v6 to v7 keeps returns and their tickets', () async {
    const at = '2026-10-06T14:32:00.000';
    const ret = v6.ReturnsData(
        id: 'r1',
        createdAt: at,
        updatedAt: at,
        deviceId: 'phone-1',
        deleted: 0,
        saleId: 's1',
        total: 6000,
        refundMode: 'cash');
    const item = v6.ReturnItemsData(
        id: 'ri1',
        createdAt: at,
        updatedAt: at,
        deviceId: 'phone-1',
        deleted: 0,
        returnId: 'r1',
        saleItemId: 'line1',
        productId: 'soda',
        quantity: 1,
        backToStock: 1,
        refund: 6000);

    await verifier.testWithDataIntegrity(
      oldVersion: 6,
      newVersion: 7,
      createOld: v6.DatabaseAtV6.new,
      createNew: v7.DatabaseAtV7.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(oldDb.returns, ret);
        batch.insert(oldDb.returnItems, item);
      },
      validateItems: (newDb) async {
        final returns = await newDb.select(newDb.returns).get();
        expect(returns.map((r) => (r.id, r.saleId, r.total, r.exchangeSaleId)),
            [('r1', 's1', 6000, null)]);
        final items = await newDb.select(newDb.returnItems).get();
        expect(items.map((i) => (i.saleItemId, i.backToStock, i.unitCost)),
            [('line1', 1, null)]);
      },
    );
  });

  // Wi-Fi sync: everything already in the shop goes into the change log,
  // so a phone joining later receives it; new changes are logged too.
  test('migration from v7 to v8 puts the shop in the change log', () async {
    const at = '2026-10-06T14:32:00.000';
    const product = v7.ProductsData(
        id: 'p1',
        createdAt: at,
        updatedAt: at,
        deviceId: 'phone-1',
        deleted: 0,
        name: 'Hamoud 33cl',
        barcode: '613',
        sellPrice: 6000,
        buyPrice: 4000,
        lowStockThreshold: 0,
        archived: 0);

    await verifier.testWithDataIntegrity(
      oldVersion: 7,
      newVersion: 8,
      createOld: v7.DatabaseAtV7.new,
      createNew: v8.DatabaseAtV8.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(oldDb.products, product),
      validateItems: (newDb) async {
        expect((await newDb.select(newDb.products).get()).single.name,
            'Hamoud 33cl');
        final log = await newDb.select(newDb.syncLog).get();
        expect(log.map((l) => (l.entity, l.rowId)), [('products', 'p1')]);
        expect(await newDb.select(newDb.devices).get(), isEmpty);
      },
    );
  });

  // The stock rule: existing shops start with workers NOT allowed to sell
  // without stock.
  test('migration from v8 to v9 keeps the shop, rule off', () async {
    const at = '2026-10-07T09:00:00.000';
    const shop = v8.ShopsData(
        id: 'shop1',
        createdAt: at,
        updatedAt: at,
        deviceId: 'phone-1',
        deleted: 0,
        name: 'Épicerie El Baraka',
        address1: '',
        address2: '',
        phone: '',
        footer: '',
        shopSecret: 'secret',
        expiryWarnDays: 3,
        maxWorkerDiscountPct: 10);

    await verifier.testWithDataIntegrity(
      oldVersion: 8,
      newVersion: 9,
      createOld: v8.DatabaseAtV8.new,
      createNew: v9.DatabaseAtV9.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(oldDb.shops, shop),
      validateItems: (newDb) async {
        final row = await newDb.select(newDb.shops).getSingle();
        expect((row.name, row.shopSecret, row.workersSellWithoutStock),
            ('Épicerie El Baraka', 'secret', 0));
      },
    );
  });

  // Phase 8: the shop keeps its data, has no sheet yet, and nothing is
  // waiting to be sent.
  test('migration from v9 to v10 keeps the shop, no sheet yet', () async {
    const at = '2026-10-07T09:00:00.000';
    const shop = v9.ShopsData(
        id: 'shop1',
        createdAt: at,
        updatedAt: at,
        deviceId: 'phone-1',
        deleted: 0,
        name: 'Épicerie El Baraka',
        address1: '',
        address2: '',
        phone: '',
        footer: '',
        shopSecret: 'secret',
        expiryWarnDays: 3,
        maxWorkerDiscountPct: 10,
        workersSellWithoutStock: 1);

    await verifier.testWithDataIntegrity(
      oldVersion: 9,
      newVersion: 10,
      createOld: v9.DatabaseAtV9.new,
      createNew: v10.DatabaseAtV10.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(oldDb.shops, shop),
      validateItems: (newDb) async {
        final row = await newDb.select(newDb.shops).getSingle();
        expect(
            (row.name, row.workersSellWithoutStock, row.sheetUrl,
                row.sheetWriteKey),
            ('Épicerie El Baraka', 1, null, null));
        expect(await newDb.select(newDb.sheetQueue).get(), isEmpty);
        expect(await newDb.select(newDb.liveSales).get(), isEmpty);
      },
    );
  });
}
