import 'package:drift/drift.dart';

// All money columns are whole centimes: 12,50 DA is stored as 1250.

/// Columns every shared record carries so phones can sync later:
/// a random unique id, when it was created/changed, which phone made it,
/// who made it, and a "deleted" flag instead of really erasing rows.
mixin SyncColumns on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get deviceId => text()();
  TextColumn get userId => text().nullable()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
}

@DataClassName('ShopRow')
class Shops extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get address1 => text().withDefault(const Constant(''))();
  TextColumn get address2 => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get footer => text().withDefault(const Constant(''))();

  /// Secret shared with paired phones, used to sign sync messages.
  TextColumn get shopSecret => text()();
  IntColumn get expiryWarnDays => integer().withDefault(const Constant(3))();
  IntColumn get maxWorkerDiscountPct =>
      integer().withDefault(const Constant(10))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CategoryRow')
class Categories extends Table with SyncColumns {
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProductRow')
@TableIndex(name: 'products_barcode', columns: {#barcode})
class Products extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get barcode => text()();
  IntColumn get sellPrice => integer()();
  IntColumn get buyPrice => integer().withDefault(const Constant(0))();
  TextColumn get categoryId => text().nullable()();
  IntColumn get lowStockThreshold => integer().withDefault(const Constant(0))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// One stock entry (a "batch"). Stock is computed from these, minus sales
/// and losses, so it is never typed in by hand.
@DataClassName('DeliveryRow')
@TableIndex(name: 'deliveries_product', columns: {#productId})
@TableIndex(name: 'deliveries_supplier', columns: {#supplierId})
class Deliveries extends Table with SyncColumns {
  TextColumn get productId => text()();
  IntColumn get quantity => integer()();
  IntColumn get buyPrice => integer()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  TextColumn get supplierId => text().nullable()();
  DateTimeColumn get receivedAt => dateTime()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Where items left the stock from: one row per batch touched by a sale,
/// a loss or a return. Positive quantity = taken out, negative = put back.
/// [deliveryId] is null when there was no stock left (sold anyway).
///
/// Stock of a product = delivered - sum of these quantities.
@DataClassName('StockAllocationRow')
@TableIndex(name: 'stock_allocations_product', columns: {#productId})
@TableIndex(name: 'stock_allocations_source', columns: {#sourceId})
class StockAllocations extends Table with SyncColumns {
  TextColumn get productId => text()();
  TextColumn get deliveryId => text().nullable()();
  IntColumn get quantity => integer()();
  TextColumn get source => text()(); // 'sale', 'loss' or 'return'
  /// The sale line (for 'sale' and 'return') or the loss.
  TextColumn get sourceId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Items thrown away, eaten, stolen... valued at their buying price.
@DataClassName('LossRow')
@TableIndex(name: 'losses_product', columns: {#productId})
class Losses extends Table with SyncColumns {
  TextColumn get productId => text()();
  IntColumn get quantity => integer()();
  TextColumn get reason => text()(); // damaged, expired, staff, stolen, other
  TextColumn get note => text().nullable()();

  /// Buying price per item at the time (centimes).
  IntColumn get unitCost => integer()();

  /// The batch chosen by the person (for example the expired one).
  TextColumn get deliveryId => text().nullable()();

  /// Set when a customer brought back a damaged item: the item already
  /// left the stock with the sale, so this loss does not touch the stock.
  TextColumn get returnItemId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A customer bringing items back.
@DataClassName('ReturnRow')
@TableIndex(name: 'returns_sale', columns: {#saleId})
class Returns extends Table with SyncColumns {
  TextColumn get saleId => text()();
  IntColumn get total => integer()(); // money given back, centimes
  TextColumn get refundMode => text().withDefault(const Constant('cash'))();
  TextColumn get reason => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ReturnItemRow')
@TableIndex(name: 'return_items_sale_item', columns: {#saleItemId})
class ReturnItems extends Table with SyncColumns {
  TextColumn get returnId => text()();
  TextColumn get saleItemId => text()();
  TextColumn get productId => text()();
  IntColumn get quantity => integer()();

  /// True: back on the shelf. False: damaged, recorded as a loss.
  BoolColumn get backToStock => boolean()();
  IntColumn get refund => integer()(); // centimes

  @override
  Set<Column> get primaryKey => {id};
}

/// People and companies the shop buys from.
@DataClassName('SupplierRow')
class Suppliers extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get note => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Money given to a supplier. `userId` is who paid. A worker's payment is
/// 'pending' until the owner validates (or rejects) it; only validated
/// payments lower what the shop owes.
@DataClassName('SupplierPaymentRow')
@TableIndex(name: 'supplier_payments_supplier', columns: {#supplierId})
@TableIndex(name: 'supplier_payments_status', columns: {#status})
class SupplierPayments extends Table with SyncColumns {
  TextColumn get supplierId => text()();
  IntColumn get amount => integer()(); // centimes
  TextColumn get note => text().nullable()();
  TextColumn get status => text()(); // pending, validated, rejected
  TextColumn get validatedBy => text().nullable()();
  DateTimeColumn get validatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Customers who buy on credit (the "carnet").
@DataClassName('CustomerRow')
class Customers extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get note => text().nullable()();

  /// Highest debt allowed (centimes), or null for no limit. Set by the
  /// owner only.
  IntColumn get creditLimit => integer().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// A customer paying back part of their debt. `userId` is who received
/// the money.
@DataClassName('CustomerPaymentRow')
@TableIndex(name: 'customer_payments_customer', columns: {#customerId})
class CustomerPayments extends Table with SyncColumns {
  TextColumn get customerId => text()();
  IntColumn get amount => integer()(); // centimes
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SaleRow')
@TableIndex(name: 'sales_created', columns: {#createdAt})
@TableIndex(name: 'sales_customer', columns: {#customerId})
class Sales extends Table with SyncColumns {
  /// Ticket number shown to people and printed on the receipt.
  IntColumn get number => integer()();
  IntColumn get subtotal => integer()();
  IntColumn get discount => integer().withDefault(const Constant(0))();
  IntColumn get total => integer()();

  /// Money received at checkout. Less than [total] only for credit sales.
  IntColumn get paidNow => integer()();
  TextColumn get customerId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Name and prices are copied at sale time so old receipts and profits
/// stay correct after a product changes.
@DataClassName('SaleItemRow')
@TableIndex(name: 'sale_items_sale', columns: {#saleId})
@TableIndex(name: 'sale_items_product', columns: {#productId})
class SaleItems extends Table with SyncColumns {
  TextColumn get saleId => text()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  IntColumn get sellPrice => integer()();
  IntColumn get unitCost => integer()();
  IntColumn get quantity => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The owner and the workers. Everyone logs in with a 4-digit PIN, which
/// is never saved as is: only a salted hash of it is kept.
@DataClassName('UserRow')
class Users extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get role => text()(); // 'owner' or 'worker'
  TextColumn get pinHash => text()();
  TextColumn get pinSalt => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  /// 4 for everyone; the owner may choose 6.
  IntColumn get pinLength => integer().withDefault(const Constant(4))();

  /// Set after too many wrong PINs. A worker is unlocked by the owner,
  /// the owner by the recovery code.
  BoolColumn get lockedOut => boolean().withDefault(const Constant(false))();

  /// Owner only: hash of the one-time recovery code (never the code).
  TextColumn get recoveryHash => text().nullable()();
  TextColumn get recoverySalt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Every wrong PIN or recovery code typed, so the owner can see who
/// tried to get into which account and when.
@DataClassName('FailedLoginRow')
@TableIndex(name: 'failed_logins_seen', columns: {#seen})
class FailedLogins extends Table with SyncColumns {
  /// The account someone tried to open.
  TextColumn get accountId => text()();
  TextColumn get kind => text()(); // 'pin' or 'recovery'
  /// True once the owner has seen the warning.
  BoolColumn get seen => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// History of changes: who changed which field, when, from what to what.
/// `userId` and `createdAt` (from [SyncColumns]) say who and when.
@DataClassName('ChangeLogRow')
@TableIndex(name: 'change_logs_entity', columns: {#entityId})
class ChangeLogs extends Table with SyncColumns {
  TextColumn get entity => text()(); // for now always 'product'
  TextColumn get entityId => text()();
  TextColumn get field => text()();
  TextColumn get oldValue => text().nullable()();
  TextColumn get newValue => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Alerts shown in the Alertes tab. Each phone works them out from its own
/// data (after a sync too), so they are never synced. [id] says what the
/// alert is about, for example 'lowStock:<product id>': there is never
/// more than one alert for the same thing.
@DataClassName('AlertRow')
@TableIndex(name: 'alerts_active', columns: {#active})
class Alerts extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();

  /// The product, delivery, payment, customer... it is about.
  TextColumn get refId => text()();

  /// What the message needs (names, quantities...), as JSON.
  TextColumn get data => text().withDefault(const Constant('{}'))();

  /// Hidden from workers (payments, security...).
  BoolColumn get ownerOnly => boolean()();

  /// False once the problem is gone (stock back up, payment validated...).
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  /// When it started (again).
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Who has read which alert: each person has their own unread alerts.
@DataClassName('AlertReadRow')
class AlertReads extends Table {
  TextColumn get alertId => text()();
  TextColumn get userId => text()();
  DateTimeColumn get readAt => dateTime()();

  @override
  Set<Column> get primaryKey => {alertId, userId};
}

/// Settings that belong to this phone only (language, theme, printer...).
/// They are never synced.
@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
