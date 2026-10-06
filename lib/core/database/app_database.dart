import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Shops,
  Categories,
  Products,
  Deliveries,
  Sales,
  SaleItems,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  /// Opens the shop database file on the phone. Tests pass an in-memory
  /// [executor] instead.
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: fileName));

  static const fileName = 'shop_db';

  // Raise this number and add a step in [migration] whenever a table changes.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
      );
}
