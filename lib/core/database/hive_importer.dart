import 'package:drift/drift.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../features/shop/data/repositories/shop_repository_impl.dart';
import '../settings/settings_store.dart';
import 'app_database.dart';

/// Copies the data of the previous app version (stored with Hive) into the
/// new SQLite database. It runs only once; the old Hive files are left on
/// the phone untouched as a safety copy.
class HiveImporter {
  static const productBox = 'products';
  static const shopBox = 'shop';
  static const settingsBox = 'settings';
  static const shopKey = 'shop_details';

  final AppDatabase db;
  final SettingsStore settings;

  /// Prepares Hive (on the phone: `Hive.initFlutter()`; in tests: a folder).
  final Future<void> Function() initHive;

  HiveImporter({
    required this.db,
    required this.settings,
    required this.initHive,
  });

  /// Returns how many products were imported (0 when already done).
  Future<int> importIfNeeded() async {
    if (settings.get(SettingsKeys.hiveImported) == 'true') return 0;

    await initHive();
    if (!Hive.isAdapterRegistered(LegacyProductAdapter.id)) {
      Hive.registerAdapter(LegacyProductAdapter());
    }
    if (!Hive.isAdapterRegistered(LegacyShopAdapter.id)) {
      Hive.registerAdapter(LegacyShopAdapter());
    }

    final products = await _read<LegacyProduct>(productBox);
    final legacyShop = (await _read<LegacyShop>(shopBox, key: shopKey));
    final oldSettings = await _readSettings();

    final now = DateTime.now();
    final deviceId = settings.deviceId;
    var imported = 0;

    await db.transaction(() async {
      for (final p in products) {
        final exists = await (db.select(db.products)
              ..where((t) => t.id.equals(p.id)))
            .getSingleOrNull();
        if (exists != null) continue;

        await db.into(db.products).insert(ProductsCompanion.insert(
              id: p.id,
              createdAt: now,
              updatedAt: now,
              deviceId: deviceId,
              name: p.name,
              barcode: p.barcode,
              sellPrice: (p.price * 100).round(),
            ));
        imported++;

        // The old app had a stock number; keep it as an opening delivery.
        if (p.stock > 0) {
          await db.into(db.deliveries).insert(DeliveriesCompanion.insert(
                id: const Uuid().v4(),
                createdAt: now,
                updatedAt: now,
                deviceId: deviceId,
                productId: p.id,
                quantity: p.stock,
                buyPrice: 0,
                receivedAt: now,
                note: const Value('Stock initial (ancienne version)'),
              ));
        }
      }

      final shop = legacyShop.isEmpty ? null : legacyShop.first;
      if (shop != null && await currentShopRow(db) == null) {
        await db.into(db.shops).insert(ShopsCompanion.insert(
              id: const Uuid().v4(),
              createdAt: now,
              updatedAt: now,
              deviceId: deviceId,
              name: shop.name,
              address1: Value(shop.addressLine1),
              address2: Value(shop.addressLine2),
              phone: Value(shop.phoneNumber),
              footer: Value(shop.footerText),
              shopSecret: newShopSecret(),
            ));
      }
    });

    for (final entry in oldSettings.entries) {
      if (settings.get(entry.key) == null) {
        await settings.set(entry.key, entry.value);
      }
    }
    await settings.set(SettingsKeys.hiveImported, 'true');
    return imported;
  }

  /// Reads every value of a box, or the one under [key]. Missing boxes
  /// (a brand new install) simply give an empty list.
  Future<List<T>> _read<T>(String name, {String? key}) async {
    if (!await Hive.boxExists(name)) return [];
    final box = await Hive.openBox<T>(name);
    try {
      if (key != null) {
        final value = box.get(key);
        return value == null ? [] : [value];
      }
      return box.values.toList();
    } finally {
      await box.close();
    }
  }

  Future<Map<String, String>> _readSettings() async {
    if (!await Hive.boxExists(settingsBox)) return {};
    final box = await Hive.openBox(settingsBox);
    try {
      final result = <String, String>{};
      for (final key in [SettingsKeys.printerMac, SettingsKeys.printerName]) {
        final value = box.get(key);
        if (value is String && value.isNotEmpty) result[key] = value;
      }
      return result;
    } finally {
      await box.close();
    }
  }
}

/// A product as the previous app version saved it.
class LegacyProduct {
  final String id;
  final String name;
  final String barcode;
  final double price;
  final int stock;

  const LegacyProduct({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    this.stock = 0,
  });
}

/// The shop details as the previous app version saved them.
class LegacyShop {
  final String name;
  final String addressLine1;
  final String addressLine2;
  final String phoneNumber;
  final String upiId; // read only to stay compatible, never used
  final String footerText;

  const LegacyShop({
    this.name = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.phoneNumber = '',
    this.upiId = '',
    this.footerText = '',
  });
}

// The two adapters below read the exact format the old app wrote
// (Hive type ids 0 and 1). `write` exists so tests can create old data.

Map<int, dynamic> _readFields(BinaryReader reader) {
  final count = reader.readByte();
  return {for (var i = 0; i < count; i++) reader.readByte(): reader.read()};
}

class LegacyProductAdapter extends TypeAdapter<LegacyProduct> {
  static const id = 0;

  @override
  final int typeId = id;

  @override
  LegacyProduct read(BinaryReader reader) {
    final f = _readFields(reader);
    return LegacyProduct(
      id: f[0] as String,
      name: f[1] as String,
      barcode: f[2] as String,
      price: (f[3] as num?)?.toDouble() ?? 0,
      stock: (f[4] as num?)?.toInt() ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, LegacyProduct obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.barcode)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.stock);
  }
}

class LegacyShopAdapter extends TypeAdapter<LegacyShop> {
  static const id = 1;

  @override
  final int typeId = id;

  @override
  LegacyShop read(BinaryReader reader) {
    final f = _readFields(reader);
    return LegacyShop(
      name: f[0] as String? ?? '',
      addressLine1: f[1] as String? ?? '',
      addressLine2: f[2] as String? ?? '',
      phoneNumber: f[3] as String? ?? '',
      upiId: f[4] as String? ?? '',
      footerText: f[5] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, LegacyShop obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.addressLine1)
      ..writeByte(2)
      ..write(obj.addressLine2)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.upiId)
      ..writeByte(5)
      ..write(obj.footerText);
  }
}
