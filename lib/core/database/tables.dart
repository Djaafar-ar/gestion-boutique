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

@DataClassName('SaleRow')
@TableIndex(name: 'sales_created', columns: {#createdAt})
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

/// Settings that belong to this phone only (language, theme, printer...).
/// They are never synced.
@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
