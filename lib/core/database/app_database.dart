import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'app_database.steps.dart';
import 'synced_tables.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(include: {
  'sync.drift',
  'sheet.drift',
}, tables: [
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
  Devices,
  Alerts,
  AlertReads,
  LiveSales,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  /// Opens the shop database file on the phone. Tests pass an in-memory
  /// [executor] instead.
  ///
  /// The app and the background job (Google Sheet, Phase 8) may run at the
  /// same time: they share one connection to the file.
  AppDatabase([QueryExecutor? executor])
      : super(executor ??
            driftDatabase(
                name: fileName,
                native: const DriftNativeOptions(shareAcrossIsolates: true)));

  static const fileName = 'shop_db';

  // How to change a table:
  // 1. edit tables.dart and raise this number,
  // 2. run: dart run drift_dev make-migrations
  // 3. add the new step below (the generated tests check it).
  @override
  int get schemaVersion => 10;

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
          // After Phase 7: may workers sell without stock (owner rule)?
          from8To9: (m, schema) async {
            await m.addColumn(
                schema.shops, schema.shops.workersSellWithoutStock);
          },
          // Phase 8: Google Sheet. The script address and write key on the
          // shop (synced), the queue of records to send, and the sales
          // shown on "Ventes en direct".
          from9To10: (m, schema) async {
            await m.addColumn(schema.shops, schema.shops.sheetUrl);
            await m.addColumn(schema.shops, schema.shops.sheetWriteKey);
            await m.createTable(schema.liveSales);
            await m.createIndex(schema.liveSalesAt);
            await m.createTable(schema.sheetQueue);
            await m.create(schema.sheetSalesInsert);
            await m.create(schema.sheetReturnsInsert);
            await m.create(schema.sheetDeliveriesInsert);
            await m.create(schema.sheetLossesInsert);
            await m.create(schema.sheetSupplierPaymentsInsert);
            await m.create(schema.sheetSupplierPaymentsUpdate);
            await m.create(schema.sheetCustomerPaymentsInsert);
            await m.create(schema.sheetCreditSales);
            await m.create(schema.sheetCreditPayments);
            await m.create(schema.sheetCreditReturns);
            await m.create(schema.sheetCreditCustomers);
          },
          // Phase 7: Wi-Fi sync. Phones get letters, and every change of a
          // shared row is written to the change log by triggers.
          from7To8: (m, schema) async {
            await m.createTable(schema.devices);
            await m.createTable(schema.syncLog);
            await m.create(schema.syncLogShopsInsert);
            await m.create(schema.syncLogShopsUpdate);
            await m.create(schema.syncLogCategoriesInsert);
            await m.create(schema.syncLogCategoriesUpdate);
            await m.create(schema.syncLogProductsInsert);
            await m.create(schema.syncLogProductsUpdate);
            await m.create(schema.syncLogDeliveriesInsert);
            await m.create(schema.syncLogDeliveriesUpdate);
            await m.create(schema.syncLogStockAllocationsInsert);
            await m.create(schema.syncLogStockAllocationsUpdate);
            await m.create(schema.syncLogLossesInsert);
            await m.create(schema.syncLogLossesUpdate);
            await m.create(schema.syncLogReturnsInsert);
            await m.create(schema.syncLogReturnsUpdate);
            await m.create(schema.syncLogReturnItemsInsert);
            await m.create(schema.syncLogReturnItemsUpdate);
            await m.create(schema.syncLogSuppliersInsert);
            await m.create(schema.syncLogSuppliersUpdate);
            await m.create(schema.syncLogSupplierPaymentsInsert);
            await m.create(schema.syncLogSupplierPaymentsUpdate);
            await m.create(schema.syncLogCustomersInsert);
            await m.create(schema.syncLogCustomersUpdate);
            await m.create(schema.syncLogCustomerPaymentsInsert);
            await m.create(schema.syncLogCustomerPaymentsUpdate);
            await m.create(schema.syncLogSalesInsert);
            await m.create(schema.syncLogSalesUpdate);
            await m.create(schema.syncLogSaleItemsInsert);
            await m.create(schema.syncLogSaleItemsUpdate);
            await m.create(schema.syncLogUsersInsert);
            await m.create(schema.syncLogUsersUpdate);
            await m.create(schema.syncLogFailedLoginsInsert);
            await m.create(schema.syncLogFailedLoginsUpdate);
            await m.create(schema.syncLogChangeLogsInsert);
            await m.create(schema.syncLogChangeLogsUpdate);
            await m.create(schema.syncLogDevicesInsert);
            await m.create(schema.syncLogDevicesUpdate);
            // Everything already in the shop is "changed" once, so a worker
            // phone joining later receives it all.
            for (final table in syncedTables) {
              await customStatement(
                  'INSERT OR REPLACE INTO sync_log (entity, row_id) '
                  "SELECT '$table', id FROM $table");
            }
          },
        ),
      );
}
