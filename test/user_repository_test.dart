import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/security/pin_hasher.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/users/data/repositories/user_repository_impl.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' show Either;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SettingsStore settings;
  late UserRepositoryImpl repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsStore(db);
    await settings.load();
    repo = UserRepositoryImpl(db, settings);
  });

  tearDown(() => db.close());

  /// The value of a successful result; the test fails otherwise.
  T ok<T>(Either<Failure, T> result) =>
      result.getOrElse((failure) => fail(failure.message));

  group('PIN hashing', () {
    test('the PIN itself is never stored', () async {
      await repo.createOwner(name: 'Karim', phone: '', pin: '1234');
      final row = await db.select(db.users).getSingle();

      expect(row.pinHash, isNot(contains('1234')));
      expect(row.pinHash, hasLength(64));
      expect(PinHasher.verify('1234', row.pinSalt, row.pinHash), isTrue);
      expect(PinHasher.verify('4321', row.pinSalt, row.pinHash), isFalse);
    });

    test('same PIN, different people, different hashes', () {
      final a = PinHasher.hash('0000', PinHasher.newSalt());
      final b = PinHasher.hash('0000', PinHasher.newSalt());
      expect(a, isNot(b));
    });

    test('a PIN is exactly 4 digits', () {
      expect(PinHasher.isValidPin('0123'), isTrue);
      expect(PinHasher.isValidPin('123'), isFalse);
      expect(PinHasher.isValidPin('12345'), isFalse);
      expect(PinHasher.isValidPin('12a4'), isFalse);
    });
  });

  test('first launch: no owner, then exactly one owner', () async {
    expect(await repo.hasOwner(), isFalse);

    final owner =
        ok(await repo.createOwner(name: ' Karim ', phone: '0555', pin: '1234'));
    expect(owner.isOwner, isTrue);
    expect(owner.name, 'Karim');
    expect(await repo.hasOwner(), isTrue);

    final second =
        await repo.createOwner(name: 'Other', phone: '', pin: '0000');
    expect(second.isLeft(), isTrue);
  });

  test('the owner receives sales and products made before accounts', () async {
    final now = DateTime.now();
    await db.into(db.sales).insert(SalesCompanion.insert(
        id: 's1',
        createdAt: now,
        updatedAt: now,
        deviceId: 'd',
        number: 1,
        subtotal: 100,
        total: 100,
        paidNow: 100));
    await db.into(db.products).insert(ProductsCompanion.insert(
        id: 'p1',
        createdAt: now,
        updatedAt: now,
        deviceId: 'd',
        name: 'Lait',
        barcode: '1',
        sellPrice: 100));

    final owner =
        ok(await repo.createOwner(name: 'Karim', phone: '', pin: '1234'));

    expect((await db.select(db.sales).getSingle()).userId, owner.id);
    expect((await db.select(db.products).getSingle()).userId, owner.id);
  });

  test('log in only with the right PIN and an active account', () async {
    await repo.createOwner(name: 'Karim', phone: '', pin: '1234');
    final amine =
        ok(await repo.addWorker(name: 'Amine', phone: '', pin: '5678'));

    expect(await repo.checkPin(amine.id, '5678'), amine);
    expect(await repo.checkPin(amine.id, '1234'), isNull);

    await repo.updateUser(amine.copyWith(active: false));
    expect(await repo.checkPin(amine.id, '5678'), isNull);

    final active = ok(await repo.getUsers(activeOnly: true));
    expect(active.map((u) => u.name), ['Karim']);
  });

  test('changing a PIN replaces the old one', () async {
    final owner =
        ok(await repo.createOwner(name: 'Karim', phone: '', pin: '1234'));

    await repo.updateUser(owner, newPin: '9999');

    expect(await repo.checkPin(owner.id, '1234'), isNull);
    expect(await repo.checkPin(owner.id, '9999'), isNotNull);
  });

  test('the owner can never be switched off', () async {
    final owner =
        ok(await repo.createOwner(name: 'Karim', phone: '', pin: '1234'));

    final saved = ok(await repo.updateUser(owner.copyWith(active: false)));

    expect(saved.active, isTrue);
  });

  test('list: owner first, then workers by name', () async {
    await repo.createOwner(name: 'Karim', phone: '', pin: '1234');
    await repo.addWorker(name: 'Yacine', phone: '', pin: '1111');
    await repo.addWorker(name: 'amine', phone: '', pin: '2222');

    final users = ok(await repo.getUsers());

    expect(users.map((u) => u.name), ['Karim', 'amine', 'Yacine']);
  });
}
