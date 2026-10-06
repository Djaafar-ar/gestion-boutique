import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/entities/product_change.dart';
import 'package:billing_app/features/users/data/repositories/user_repository_impl.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SessionCubit session;
  late ProductRepositoryImpl repo;
  late AppUser amine;

  const juice = Product(
      id: 'p1', name: 'Jus Rouiba 1L', barcode: '613', sellPrice: 18000);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final settings = SettingsStore(db);
    await settings.load();
    final users = UserRepositoryImpl(db, settings);
    await users.createOwner(name: 'Karim', phone: '', pin: '1234');
    amine = (await users.addWorker(name: 'Amine', phone: '', pin: '5678'))
        .getOrElse((f) => fail(f.message));
    session = SessionCubit(hasOwner: true)..login(amine);
    repo = ProductRepositoryImpl(db, settings, session);
    await repo.addProduct(juice);
  });

  tearDown(() async {
    await session.close();
    await db.close();
  });

  Future<List<ProductChange>> history() async =>
      (await repo.getHistory('p1')).getOrElse((f) => fail(f.message));

  test('a new product is saved with who added it', () async {
    final row = await db.select(db.products).getSingle();
    expect(row.userId, amine.id);
    expect(await history(), isEmpty);
  });

  test('only changed fields are written, with who and old/new values',
      () async {
    await repo.updateProduct(juice.copyWith(sellPrice: 20000, buyPrice: 15000));

    final changes = await history();
    expect(changes.map((c) => c.field).toSet(),
        {ProductField.sellPrice, ProductField.buyPrice});
    final price = changes.firstWhere((c) => c.field == ProductField.sellPrice);
    expect(price.oldValue, '18000');
    expect(price.newValue, '20000');
    expect(price.userName, 'Amine');
  });

  test('saving without changes writes nothing', () async {
    await repo.updateProduct(juice);
    expect(await history(), isEmpty);
  });

  test('categories are written by name', () async {
    final drinks =
        (await repo.addCategory('Boissons')).getOrElse((f) => fail(f.message));
    await repo.updateProduct(juice.copyWith(categoryId: drinks.id));

    final change = (await history()).single;
    expect(change.field, ProductField.category);
    expect(change.oldValue, isNull);
    expect(change.newValue, 'Boissons');
  });

  test('the same category name is never created twice', () async {
    final a =
        (await repo.addCategory('Boissons')).getOrElse((f) => fail(f.message));
    final b = (await repo.addCategory(' boissons '))
        .getOrElse((f) => fail(f.message));

    expect(b.id, a.id);
    expect(await db.select(db.categories).get(), hasLength(1));
  });

  test('archiving is in the history and hides the product', () async {
    await repo.archiveProduct('p1');

    expect((await history()).single.field, ProductField.archived);
    expect(
        (await repo.getProducts()).getOrElse((f) => fail(f.message)), isEmpty);
  });
}
