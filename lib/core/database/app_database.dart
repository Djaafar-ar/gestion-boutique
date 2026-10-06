import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'app_database.steps.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Shops,
  Categories,
  Products,
  Deliveries,
  Sales,
  SaleItems,
  StockAllocations,
  Losses,
  Returns,
  ReturnItems,
  Suppliers,
  SupplierPayments,
  Customers,
  CustomerPayments,
  Users,
  ChangeLogs,
  FailedLogins,
  Alerts,
  AlertReads,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  /// Opens the shop database file on the phone. Tests pass an in-memory
  /// [executor] instead.
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: fileName));

  static const fileName = 'shop_db';

  // How to change a table:
  // 1. edit tables.dart and raise this number,
  // 2. run: dart run drift_dev make-migrations
  // 3. add the new step below (the generated tests check it).
  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: stepByStep(
          // Phase 2: owner/workers and the change history.
          from1To2: (m, schema) async {
            await m.createTable(schema.users);
            await m.createTable(schema.changeLogs);
            await m.createIndex(schema.changeLogsEntity);
          },
          // Phase 2b: stronger PIN protection and owner recovery code.
          from2To3: (m, schema) async {
            await m.addColumn(schema.users, schema.users.pinLength);
            await m.addColumn(schema.users, schema.users.lockedOut);
            await m.addColumn(schema.users, schema.users.recoveryHash);
            await m.addColumn(schema.users, schema.users.recoverySalt);
            await m.createTable(schema.failedLogins);
            await m.createIndex(schema.failedLoginsSeen);
          },
          // Phase 3: stock per batch, losses and returns.
          from3To4: (m, schema) async {
            await m.createTable(schema.stockAllocations);
            await m.createIndex(schema.stockAllocationsProduct);
            await m.createIndex(schema.stockAllocationsSource);
            await m.createTable(schema.losses);
            await m.createIndex(schema.lossesProduct);
            await m.createTable(schema.returns);
            await m.createIndex(schema.returnsSale);
            await m.createTable(schema.returnItems);
            await m.createIndex(schema.returnItemsSaleItem);
          },
          // Phase 4: suppliers and their payments, customer credit.
          from4To5: (m, schema) async {
            await m.createTable(schema.suppliers);
            await m.createTable(schema.supplierPayments);
            await m.createIndex(schema.supplierPaymentsSupplier);
            await m.createIndex(schema.supplierPaymentsStatus);
            await m.createTable(schema.customers);
            await m.createTable(schema.customerPayments);
            await m.createIndex(schema.customerPaymentsCustomer);
            await m.createIndex(schema.salesCustomer);
            await m.createIndex(schema.deliveriesSupplier);
          },
          // Phase 5: alerts and who has read them.
          from5To6: (m, schema) async {
            await m.createTable(schema.alerts);
            await m.createIndex(schema.alertsActive);
            await m.createTable(schema.alertReads);
          },
          // Returns without a receipt and exchanges: a return may have no
          // ticket, and remembers the exchange ticket and who allowed it.
          from6To7: (m, schema) async {
            await m.alterTable(TableMigration(schema.returns, newColumns: [
              schema.returns.exchangeSaleId,
              schema.returns.approvedBy,
            ]));
            await m.createIndex(schema.returnsExchangeSale);
            await m.alterTable(TableMigration(schema.returnItems,
                newColumns: [schema.returnItems.unitCost]));
          },
        ),
      );
}
