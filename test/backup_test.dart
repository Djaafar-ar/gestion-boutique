import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/backup/data/backup_service.dart';
import 'package:billing_app/features/billing/data/repositories/sale_repository_impl.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/sheet/data/sheet_settings.dart';
import 'package:billing_app/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:billing_app/features/shop/domain/entities/shop.dart';
import 'package:billing_app/features/stock/data/stock_ledger.dart';
import 'package:billing_app/features/sync/data/sync_settings.dart';
import 'package:billing_app/features/users/data/repositories/user_repository_impl.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Backups: one .zip file with the whole shop; restoring it gives back
/// exactly the same data, and only for the right shop and owner.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory dir;
  late AppDatabase db;
  late SettingsStore settings;
  late BackupService backups;
  var tick = 0;

  const soda = Product(
      id: 'soda', name: 'Hamoud 33cl', barcode: '613', sellPrice: 6000);

  /// The shop database file, as on the phone.
  File dbFile() => File(p.join(dir.path, '${AppDatabase.fileName}.sqlite'));

  Future<void> open() async {
    db = AppDatabase(NativeDatabase(dbFile()));
    settings = SettingsStore(db);
    await settings.load();
    // A minute later at each backup, so their names differ.
    backups = BackupService(db, settings,
        folder: () async => dir,
        clock: () => DateTime(2026, 10, 7, 21).add(Duration(minutes: tick++)));
  }

  /// A shop with its owner (PIN 1234) and [count] sales.
  Future<void> makeShop(String name, {int count = 2}) async {
    final users = UserRepositoryImpl(db, settings);
    final owner =
        (await users.createOwner(name: 'Karim', phone: '', pin: '1234'))
            .getOrElse((f) => fail(f.message))
            .owner;
    final session = SessionCubit(hasOwner: true)..login(owner);
    await ShopRepositoryImpl(db, settings).updateShop(Shop(name: name));
    await ProductRepositoryImpl(db, settings, session).addProduct(soda);
    final sales = SaleRepositoryImpl(db, settings, session, StockLedger(db));
    for (var i = 0; i < count; i++) {
      await sales.saveSale(const [CartItem(product: soda)]);
    }
    await session.close();
  }

  Future<int> salesCount() async =>
      (await db.select(db.sales).get()).length;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('backup_test');
    await open();
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  test('a backup says which shop and when; the read key stays here',
      () async {
    await makeShop('Épicerie El Baraka');
    await settings.setSheetReadKey('b' * 32);
    final file = await backups.create();
    expect(p.basename(file.path), startsWith('sauvegarde_epicerie_el_baraka_'));

    final (info, data) = BackupService.read(await file.readAsBytes());
    expect(info.shopName, 'Épicerie El Baraka');
    expect(info.shopId, (await currentShopRow(db))!.id);
    expect(info.schema, db.schemaVersion);
    // The copy inside has the sales but not the Google Sheet read key.
    final copy = File(p.join(dir.path, 'check.sqlite'))..writeAsBytesSync(data);
    final inside = AppDatabase(NativeDatabase(copy));
    expect(await inside.select(inside.sales).get(), hasLength(2));
    expect(
        await (inside.select(inside.appSettings)
              ..where((s) => s.key.equals(SheetSettings.readKeyName)))
            .get(),
        isEmpty);
    await inside.close();
  });

  test('restore gives back exactly the data of the backup', () async {
    await makeShop('Épicerie El Baraka');
    final backup = await (await backups.create()).readAsBytes();
    final before = await db.select(db.sales).get();

    // Later: more sales, then the owner restores the backup.
    await makeShopSales(db, settings, 3);
    expect(await salesCount(), 5);
    await backups.prepareRestore(backup, pin: '1234');
    // A backup of the current data was made first, just in case.
    final zips = dir
        .listSync(recursive: true)
        .where((f) => f.path.endsWith('.zip'))
        .toList();
    expect(zips, hasLength(2));

    // The app closes, and the backup is put in place at the next start.
    await db.close();
    expect(await BackupService.applyPendingRestore(dir: dir), isTrue);
    expect(await BackupService.applyPendingRestore(dir: dir), isFalse);
    await open();
    expect(await db.select(db.sales).get(), before);
  });

  test('refused: another shop, a newer version, a wrong PIN, a worker phone',
      () async {
    await makeShop('Épicerie El Baraka');
    final mine = await (await backups.create()).readAsBytes();

    // Another shop's backup.
    final otherDir = await Directory.systemTemp.createTemp('other_shop');
    final other = AppDatabase(NativeDatabase.memory());
    final otherSettings = SettingsStore(other);
    await otherSettings.load();
    final saved = (db, settings);
    (db, settings) = (other, otherSettings);
    await makeShop('Superette Bab Ezzouar');
    (db, settings) = saved;
    final theirs = await (await BackupService(other, otherSettings,
                folder: () async => otherDir)
            .create())
        .readAsBytes();
    await other.close();
    await otherDir.delete(recursive: true);

    Future<void> refused(List<int> zip, BackupError error,
            {String pin = '1234'}) =>
        expectLater(
            backups.prepareRestore(Uint8List.fromList(zip), pin: pin),
            throwsA(isA<BackupException>()
                .having((e) => e.error, 'error', error)));

    await refused(theirs, BackupError.otherShop);
    await refused(mine, BackupError.wrongPin, pin: '0000');
    await refused(utf8.encode('not a zip'), BackupError.notABackup);

    // Made by a newer app version.
    final archive = ZipDecoder().decodeBytes(mine);
    final info = jsonDecode(utf8.decode(archive.findFile('info.json')!.content))
        as Map<String, Object?>;
    final newer = Archive()
      ..addFile(ArchiveFile.string(
          'info.json', jsonEncode({...info, 'schema': db.schemaVersion + 1})))
      ..addFile(ArchiveFile.bytes(
          'shop.sqlite', archive.findFile('shop.sqlite')!.content));
    await refused(ZipEncoder().encodeBytes(newer), BackupError.newerVersion);

    await settings.setSyncRole(SyncRole.worker);
    await refused(mine, BackupError.workerPhone);
    expect(File(p.join(dir.path, BackupService.pendingName)).existsSync(),
        isFalse);
  });

  test('a new phone: any shop, with the owner PIN of the backup', () async {
    await makeShop('Épicerie El Baraka');
    final backup = await (await backups.create()).readAsBytes();
    await db.close();
    // A new, empty phone.
    await dir.delete(recursive: true);
    dir = await Directory.systemTemp.createTemp('new_phone');
    await open();
    expect(await currentShopRow(db), isNull);

    await expectLater(backups.prepareRestore(backup, pin: '9999'),
        throwsA(isA<BackupException>()));
    await backups.prepareRestore(backup, pin: '1234');
    await db.close();
    await BackupService.applyPendingRestore(dir: dir);
    await open();
    expect((await currentShopRow(db))!.name, 'Épicerie El Baraka');
    expect(await salesCount(), 2);
    expect(await UserRepositoryImpl(db, settings).hasOwner(), isTrue);
  });
}

Future<void> makeShopSales(
    AppDatabase db, SettingsStore settings, int count) async {
  final owner = (await (db.select(db.users)).get()).first;
  final session = SessionCubit(hasOwner: true);
  final users = UserRepositoryImpl(db, settings);
  session.login((await users.getUsers())
      .getOrElse((f) => fail(f.message))
      .firstWhere((u) => u.id == owner.id));
  final sales = SaleRepositoryImpl(db, settings, session, StockLedger(db));
  const soda = Product(
      id: 'soda', name: 'Hamoud 33cl', barcode: '613', sellPrice: 6000);
  for (var i = 0; i < count; i++) {
    await sales.saveSale(const [CartItem(product: soda)]);
  }
  await session.close();
}
