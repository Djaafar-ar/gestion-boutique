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
  Users,
  ChangeLogs,
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
  int get schemaVersion => 2;

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
        ),
      );
}
