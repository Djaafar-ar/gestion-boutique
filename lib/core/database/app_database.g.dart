// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ShopsTable extends Shops with TableInfo<$ShopsTable, ShopRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShopsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _address1Meta =
      const VerificationMeta('address1');
  @override
  late final GeneratedColumn<String> address1 = GeneratedColumn<String>(
      'address1', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _address2Meta =
      const VerificationMeta('address2');
  @override
  late final GeneratedColumn<String> address2 = GeneratedColumn<String>(
      'address2', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _footerMeta = const VerificationMeta('footer');
  @override
  late final GeneratedColumn<String> footer = GeneratedColumn<String>(
      'footer', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _shopSecretMeta =
      const VerificationMeta('shopSecret');
  @override
  late final GeneratedColumn<String> shopSecret = GeneratedColumn<String>(
      'shop_secret', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _expiryWarnDaysMeta =
      const VerificationMeta('expiryWarnDays');
  @override
  late final GeneratedColumn<int> expiryWarnDays = GeneratedColumn<int>(
      'expiry_warn_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _maxWorkerDiscountPctMeta =
      const VerificationMeta('maxWorkerDiscountPct');
  @override
  late final GeneratedColumn<int> maxWorkerDiscountPct = GeneratedColumn<int>(
      'max_worker_discount_pct', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(10));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        deviceId,
        userId,
        deleted,
        name,
        address1,
        address2,
        phone,
        footer,
        shopSecret,
        expiryWarnDays,
        maxWorkerDiscountPct
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shops';
  @override
  VerificationContext validateIntegrity(Insertable<ShopRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address1')) {
      context.handle(_address1Meta,
          address1.isAcceptableOrUnknown(data['address1']!, _address1Meta));
    }
    if (data.containsKey('address2')) {
      context.handle(_address2Meta,
          address2.isAcceptableOrUnknown(data['address2']!, _address2Meta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('footer')) {
      context.handle(_footerMeta,
          footer.isAcceptableOrUnknown(data['footer']!, _footerMeta));
    }
    if (data.containsKey('shop_secret')) {
      context.handle(
          _shopSecretMeta,
          shopSecret.isAcceptableOrUnknown(
              data['shop_secret']!, _shopSecretMeta));
    } else if (isInserting) {
      context.missing(_shopSecretMeta);
    }
    if (data.containsKey('expiry_warn_days')) {
      context.handle(
          _expiryWarnDaysMeta,
          expiryWarnDays.isAcceptableOrUnknown(
              data['expiry_warn_days']!, _expiryWarnDaysMeta));
    }
    if (data.containsKey('max_worker_discount_pct')) {
      context.handle(
          _maxWorkerDiscountPctMeta,
          maxWorkerDiscountPct.isAcceptableOrUnknown(
              data['max_worker_discount_pct']!, _maxWorkerDiscountPctMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShopRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShopRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      address1: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address1'])!,
      address2: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address2'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      footer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}footer'])!,
      shopSecret: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shop_secret'])!,
      expiryWarnDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}expiry_warn_days'])!,
      maxWorkerDiscountPct: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}max_worker_discount_pct'])!,
    );
  }

  @override
  $ShopsTable createAlias(String alias) {
    return $ShopsTable(attachedDatabase, alias);
  }
}

class ShopRow extends DataClass implements Insertable<ShopRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String deviceId;
  final String? userId;
  final bool deleted;
  final String name;
  final String address1;
  final String address2;
  final String phone;
  final String footer;

  /// Secret shared with paired phones, used to sign sync messages.
  final String shopSecret;
  final int expiryWarnDays;
  final int maxWorkerDiscountPct;
  const ShopRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deviceId,
      this.userId,
      required this.deleted,
      required this.name,
      required this.address1,
      required this.address2,
      required this.phone,
      required this.footer,
      required this.shopSecret,
      required this.expiryWarnDays,
      required this.maxWorkerDiscountPct});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    map['address1'] = Variable<String>(address1);
    map['address2'] = Variable<String>(address2);
    map['phone'] = Variable<String>(phone);
    map['footer'] = Variable<String>(footer);
    map['shop_secret'] = Variable<String>(shopSecret);
    map['expiry_warn_days'] = Variable<int>(expiryWarnDays);
    map['max_worker_discount_pct'] = Variable<int>(maxWorkerDiscountPct);
    return map;
  }

  ShopsCompanion toCompanion(bool nullToAbsent) {
    return ShopsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deviceId: Value(deviceId),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      deleted: Value(deleted),
      name: Value(name),
      address1: Value(address1),
      address2: Value(address2),
      phone: Value(phone),
      footer: Value(footer),
      shopSecret: Value(shopSecret),
      expiryWarnDays: Value(expiryWarnDays),
      maxWorkerDiscountPct: Value(maxWorkerDiscountPct),
    );
  }

  factory ShopRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShopRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      userId: serializer.fromJson<String?>(json['userId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
      address1: serializer.fromJson<String>(json['address1']),
      address2: serializer.fromJson<String>(json['address2']),
      phone: serializer.fromJson<String>(json['phone']),
      footer: serializer.fromJson<String>(json['footer']),
      shopSecret: serializer.fromJson<String>(json['shopSecret']),
      expiryWarnDays: serializer.fromJson<int>(json['expiryWarnDays']),
      maxWorkerDiscountPct:
          serializer.fromJson<int>(json['maxWorkerDiscountPct']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'userId': serializer.toJson<String?>(userId),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
      'address1': serializer.toJson<String>(address1),
      'address2': serializer.toJson<String>(address2),
      'phone': serializer.toJson<String>(phone),
      'footer': serializer.toJson<String>(footer),
      'shopSecret': serializer.toJson<String>(shopSecret),
      'expiryWarnDays': serializer.toJson<int>(expiryWarnDays),
      'maxWorkerDiscountPct': serializer.toJson<int>(maxWorkerDiscountPct),
    };
  }

  ShopRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? deviceId,
          Value<String?> userId = const Value.absent(),
          bool? deleted,
          String? name,
          String? address1,
          String? address2,
          String? phone,
          String? footer,
          String? shopSecret,
          int? expiryWarnDays,
          int? maxWorkerDiscountPct}) =>
      ShopRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deviceId: deviceId ?? this.deviceId,
        userId: userId.present ? userId.value : this.userId,
        deleted: deleted ?? this.deleted,
        name: name ?? this.name,
        address1: address1 ?? this.address1,
        address2: address2 ?? this.address2,
        phone: phone ?? this.phone,
        footer: footer ?? this.footer,
        shopSecret: shopSecret ?? this.shopSecret,
        expiryWarnDays: expiryWarnDays ?? this.expiryWarnDays,
        maxWorkerDiscountPct: maxWorkerDiscountPct ?? this.maxWorkerDiscountPct,
      );
  ShopRow copyWithCompanion(ShopsCompanion data) {
    return ShopRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
      address1: data.address1.present ? data.address1.value : this.address1,
      address2: data.address2.present ? data.address2.value : this.address2,
      phone: data.phone.present ? data.phone.value : this.phone,
      footer: data.footer.present ? data.footer.value : this.footer,
      shopSecret:
          data.shopSecret.present ? data.shopSecret.value : this.shopSecret,
      expiryWarnDays: data.expiryWarnDays.present
          ? data.expiryWarnDays.value
          : this.expiryWarnDays,
      maxWorkerDiscountPct: data.maxWorkerDiscountPct.present
          ? data.maxWorkerDiscountPct.value
          : this.maxWorkerDiscountPct,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShopRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('address1: $address1, ')
          ..write('address2: $address2, ')
          ..write('phone: $phone, ')
          ..write('footer: $footer, ')
          ..write('shopSecret: $shopSecret, ')
          ..write('expiryWarnDays: $expiryWarnDays, ')
          ..write('maxWorkerDiscountPct: $maxWorkerDiscountPct')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      deviceId,
      userId,
      deleted,
      name,
      address1,
      address2,
      phone,
      footer,
      shopSecret,
      expiryWarnDays,
      maxWorkerDiscountPct);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShopRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deviceId == this.deviceId &&
          other.userId == this.userId &&
          other.deleted == this.deleted &&
          other.name == this.name &&
          other.address1 == this.address1 &&
          other.address2 == this.address2 &&
          other.phone == this.phone &&
          other.footer == this.footer &&
          other.shopSecret == this.shopSecret &&
          other.expiryWarnDays == this.expiryWarnDays &&
          other.maxWorkerDiscountPct == this.maxWorkerDiscountPct);
}

class ShopsCompanion extends UpdateCompanion<ShopRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> deviceId;
  final Value<String?> userId;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<String> address1;
  final Value<String> address2;
  final Value<String> phone;
  final Value<String> footer;
  final Value<String> shopSecret;
  final Value<int> expiryWarnDays;
  final Value<int> maxWorkerDiscountPct;
  final Value<int> rowid;
  const ShopsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.address1 = const Value.absent(),
    this.address2 = const Value.absent(),
    this.phone = const Value.absent(),
    this.footer = const Value.absent(),
    this.shopSecret = const Value.absent(),
    this.expiryWarnDays = const Value.absent(),
    this.maxWorkerDiscountPct = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShopsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String deviceId,
    this.userId = const Value.absent(),
    this.deleted = const Value.absent(),
    required String name,
    this.address1 = const Value.absent(),
    this.address2 = const Value.absent(),
    this.phone = const Value.absent(),
    this.footer = const Value.absent(),
    required String shopSecret,
    this.expiryWarnDays = const Value.absent(),
    this.maxWorkerDiscountPct = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        deviceId = Value(deviceId),
        name = Value(name),
        shopSecret = Value(shopSecret);
  static Insertable<ShopRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? deviceId,
    Expression<String>? userId,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<String>? address1,
    Expression<String>? address2,
    Expression<String>? phone,
    Expression<String>? footer,
    Expression<String>? shopSecret,
    Expression<int>? expiryWarnDays,
    Expression<int>? maxWorkerDiscountPct,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (userId != null) 'user_id': userId,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (address1 != null) 'address1': address1,
      if (address2 != null) 'address2': address2,
      if (phone != null) 'phone': phone,
      if (footer != null) 'footer': footer,
      if (shopSecret != null) 'shop_secret': shopSecret,
      if (expiryWarnDays != null) 'expiry_warn_days': expiryWarnDays,
      if (maxWorkerDiscountPct != null)
        'max_worker_discount_pct': maxWorkerDiscountPct,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShopsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? deviceId,
      Value<String?>? userId,
      Value<bool>? deleted,
      Value<String>? name,
      Value<String>? address1,
      Value<String>? address2,
      Value<String>? phone,
      Value<String>? footer,
      Value<String>? shopSecret,
      Value<int>? expiryWarnDays,
      Value<int>? maxWorkerDiscountPct,
      Value<int>? rowid}) {
    return ShopsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      phone: phone ?? this.phone,
      footer: footer ?? this.footer,
      shopSecret: shopSecret ?? this.shopSecret,
      expiryWarnDays: expiryWarnDays ?? this.expiryWarnDays,
      maxWorkerDiscountPct: maxWorkerDiscountPct ?? this.maxWorkerDiscountPct,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address1.present) {
      map['address1'] = Variable<String>(address1.value);
    }
    if (address2.present) {
      map['address2'] = Variable<String>(address2.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (footer.present) {
      map['footer'] = Variable<String>(footer.value);
    }
    if (shopSecret.present) {
      map['shop_secret'] = Variable<String>(shopSecret.value);
    }
    if (expiryWarnDays.present) {
      map['expiry_warn_days'] = Variable<int>(expiryWarnDays.value);
    }
    if (maxWorkerDiscountPct.present) {
      map['max_worker_discount_pct'] =
          Variable<int>(maxWorkerDiscountPct.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShopsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('address1: $address1, ')
          ..write('address2: $address2, ')
          ..write('phone: $phone, ')
          ..write('footer: $footer, ')
          ..write('shopSecret: $shopSecret, ')
          ..write('expiryWarnDays: $expiryWarnDays, ')
          ..write('maxWorkerDiscountPct: $maxWorkerDiscountPct, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, createdAt, updatedAt, deviceId, userId, deleted, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String deviceId;
  final String? userId;
  final bool deleted;
  final String name;
  const CategoryRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deviceId,
      this.userId,
      required this.deleted,
      required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deviceId: Value(deviceId),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      deleted: Value(deleted),
      name: Value(name),
    );
  }

  factory CategoryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      userId: serializer.fromJson<String?>(json['userId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'userId': serializer.toJson<String?>(userId),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
    };
  }

  CategoryRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? deviceId,
          Value<String?> userId = const Value.absent(),
          bool? deleted,
          String? name}) =>
      CategoryRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deviceId: deviceId ?? this.deviceId,
        userId: userId.present ? userId.value : this.userId,
        deleted: deleted ?? this.deleted,
        name: name ?? this.name,
      );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, deviceId, userId, deleted, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deviceId == this.deviceId &&
          other.userId == this.userId &&
          other.deleted == this.deleted &&
          other.name == this.name);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> deviceId;
  final Value<String?> userId;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String deviceId,
    this.userId = const Value.absent(),
    this.deleted = const Value.absent(),
    required String name,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        deviceId = Value(deviceId),
        name = Value(name);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? deviceId,
    Expression<String>? userId,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (userId != null) 'user_id': userId,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? deviceId,
      Value<String?>? userId,
      Value<bool>? deleted,
      Value<String>? name,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sellPriceMeta =
      const VerificationMeta('sellPrice');
  @override
  late final GeneratedColumn<int> sellPrice = GeneratedColumn<int>(
      'sell_price', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _buyPriceMeta =
      const VerificationMeta('buyPrice');
  @override
  late final GeneratedColumn<int> buyPrice = GeneratedColumn<int>(
      'buy_price', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lowStockThresholdMeta =
      const VerificationMeta('lowStockThreshold');
  @override
  late final GeneratedColumn<int> lowStockThreshold = GeneratedColumn<int>(
      'low_stock_threshold', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _archivedMeta =
      const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
      'archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        deviceId,
        userId,
        deleted,
        name,
        barcode,
        sellPrice,
        buyPrice,
        categoryId,
        lowStockThreshold,
        archived
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<ProductRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('sell_price')) {
      context.handle(_sellPriceMeta,
          sellPrice.isAcceptableOrUnknown(data['sell_price']!, _sellPriceMeta));
    } else if (isInserting) {
      context.missing(_sellPriceMeta);
    }
    if (data.containsKey('buy_price')) {
      context.handle(_buyPriceMeta,
          buyPrice.isAcceptableOrUnknown(data['buy_price']!, _buyPriceMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('low_stock_threshold')) {
      context.handle(
          _lowStockThresholdMeta,
          lowStockThreshold.isAcceptableOrUnknown(
              data['low_stock_threshold']!, _lowStockThresholdMeta));
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta,
          archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode'])!,
      sellPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sell_price'])!,
      buyPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}buy_price'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      lowStockThreshold: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}low_stock_threshold'])!,
      archived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String deviceId;
  final String? userId;
  final bool deleted;
  final String name;
  final String barcode;
  final int sellPrice;
  final int buyPrice;
  final String? categoryId;
  final int lowStockThreshold;
  final bool archived;
  const ProductRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deviceId,
      this.userId,
      required this.deleted,
      required this.name,
      required this.barcode,
      required this.sellPrice,
      required this.buyPrice,
      this.categoryId,
      required this.lowStockThreshold,
      required this.archived});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    map['barcode'] = Variable<String>(barcode);
    map['sell_price'] = Variable<int>(sellPrice);
    map['buy_price'] = Variable<int>(buyPrice);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['low_stock_threshold'] = Variable<int>(lowStockThreshold);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deviceId: Value(deviceId),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      deleted: Value(deleted),
      name: Value(name),
      barcode: Value(barcode),
      sellPrice: Value(sellPrice),
      buyPrice: Value(buyPrice),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      lowStockThreshold: Value(lowStockThreshold),
      archived: Value(archived),
    );
  }

  factory ProductRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      userId: serializer.fromJson<String?>(json['userId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
      barcode: serializer.fromJson<String>(json['barcode']),
      sellPrice: serializer.fromJson<int>(json['sellPrice']),
      buyPrice: serializer.fromJson<int>(json['buyPrice']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      lowStockThreshold: serializer.fromJson<int>(json['lowStockThreshold']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'userId': serializer.toJson<String?>(userId),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
      'barcode': serializer.toJson<String>(barcode),
      'sellPrice': serializer.toJson<int>(sellPrice),
      'buyPrice': serializer.toJson<int>(buyPrice),
      'categoryId': serializer.toJson<String?>(categoryId),
      'lowStockThreshold': serializer.toJson<int>(lowStockThreshold),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  ProductRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? deviceId,
          Value<String?> userId = const Value.absent(),
          bool? deleted,
          String? name,
          String? barcode,
          int? sellPrice,
          int? buyPrice,
          Value<String?> categoryId = const Value.absent(),
          int? lowStockThreshold,
          bool? archived}) =>
      ProductRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deviceId: deviceId ?? this.deviceId,
        userId: userId.present ? userId.value : this.userId,
        deleted: deleted ?? this.deleted,
        name: name ?? this.name,
        barcode: barcode ?? this.barcode,
        sellPrice: sellPrice ?? this.sellPrice,
        buyPrice: buyPrice ?? this.buyPrice,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
        archived: archived ?? this.archived,
      );
  ProductRow copyWithCompanion(ProductsCompanion data) {
    return ProductRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      sellPrice: data.sellPrice.present ? data.sellPrice.value : this.sellPrice,
      buyPrice: data.buyPrice.present ? data.buyPrice.value : this.buyPrice,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      lowStockThreshold: data.lowStockThreshold.present
          ? data.lowStockThreshold.value
          : this.lowStockThreshold,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('barcode: $barcode, ')
          ..write('sellPrice: $sellPrice, ')
          ..write('buyPrice: $buyPrice, ')
          ..write('categoryId: $categoryId, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      deviceId,
      userId,
      deleted,
      name,
      barcode,
      sellPrice,
      buyPrice,
      categoryId,
      lowStockThreshold,
      archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deviceId == this.deviceId &&
          other.userId == this.userId &&
          other.deleted == this.deleted &&
          other.name == this.name &&
          other.barcode == this.barcode &&
          other.sellPrice == this.sellPrice &&
          other.buyPrice == this.buyPrice &&
          other.categoryId == this.categoryId &&
          other.lowStockThreshold == this.lowStockThreshold &&
          other.archived == this.archived);
}

class ProductsCompanion extends UpdateCompanion<ProductRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> deviceId;
  final Value<String?> userId;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<String> barcode;
  final Value<int> sellPrice;
  final Value<int> buyPrice;
  final Value<String?> categoryId;
  final Value<int> lowStockThreshold;
  final Value<bool> archived;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.barcode = const Value.absent(),
    this.sellPrice = const Value.absent(),
    this.buyPrice = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.lowStockThreshold = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String deviceId,
    this.userId = const Value.absent(),
    this.deleted = const Value.absent(),
    required String name,
    required String barcode,
    required int sellPrice,
    this.buyPrice = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.lowStockThreshold = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        deviceId = Value(deviceId),
        name = Value(name),
        barcode = Value(barcode),
        sellPrice = Value(sellPrice);
  static Insertable<ProductRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? deviceId,
    Expression<String>? userId,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<String>? barcode,
    Expression<int>? sellPrice,
    Expression<int>? buyPrice,
    Expression<String>? categoryId,
    Expression<int>? lowStockThreshold,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (userId != null) 'user_id': userId,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (barcode != null) 'barcode': barcode,
      if (sellPrice != null) 'sell_price': sellPrice,
      if (buyPrice != null) 'buy_price': buyPrice,
      if (categoryId != null) 'category_id': categoryId,
      if (lowStockThreshold != null) 'low_stock_threshold': lowStockThreshold,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? deviceId,
      Value<String?>? userId,
      Value<bool>? deleted,
      Value<String>? name,
      Value<String>? barcode,
      Value<int>? sellPrice,
      Value<int>? buyPrice,
      Value<String?>? categoryId,
      Value<int>? lowStockThreshold,
      Value<bool>? archived,
      Value<int>? rowid}) {
    return ProductsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      sellPrice: sellPrice ?? this.sellPrice,
      buyPrice: buyPrice ?? this.buyPrice,
      categoryId: categoryId ?? this.categoryId,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (sellPrice.present) {
      map['sell_price'] = Variable<int>(sellPrice.value);
    }
    if (buyPrice.present) {
      map['buy_price'] = Variable<int>(buyPrice.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (lowStockThreshold.present) {
      map['low_stock_threshold'] = Variable<int>(lowStockThreshold.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('barcode: $barcode, ')
          ..write('sellPrice: $sellPrice, ')
          ..write('buyPrice: $buyPrice, ')
          ..write('categoryId: $categoryId, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeliveriesTable extends Deliveries
    with TableInfo<$DeliveriesTable, DeliveryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeliveriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _buyPriceMeta =
      const VerificationMeta('buyPrice');
  @override
  late final GeneratedColumn<int> buyPrice = GeneratedColumn<int>(
      'buy_price', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _expiryDateMeta =
      const VerificationMeta('expiryDate');
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
      'expiry_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _supplierIdMeta =
      const VerificationMeta('supplierId');
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
      'supplier_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _receivedAtMeta =
      const VerificationMeta('receivedAt');
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
      'received_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        deviceId,
        userId,
        deleted,
        productId,
        quantity,
        buyPrice,
        expiryDate,
        supplierId,
        receivedAt,
        note
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deliveries';
  @override
  VerificationContext validateIntegrity(Insertable<DeliveryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('buy_price')) {
      context.handle(_buyPriceMeta,
          buyPrice.isAcceptableOrUnknown(data['buy_price']!, _buyPriceMeta));
    } else if (isInserting) {
      context.missing(_buyPriceMeta);
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
          _expiryDateMeta,
          expiryDate.isAcceptableOrUnknown(
              data['expiry_date']!, _expiryDateMeta));
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
          _supplierIdMeta,
          supplierId.isAcceptableOrUnknown(
              data['supplier_id']!, _supplierIdMeta));
    }
    if (data.containsKey('received_at')) {
      context.handle(
          _receivedAtMeta,
          receivedAt.isAcceptableOrUnknown(
              data['received_at']!, _receivedAtMeta));
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeliveryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeliveryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      buyPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}buy_price'])!,
      expiryDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expiry_date']),
      supplierId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier_id']),
      receivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}received_at'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $DeliveriesTable createAlias(String alias) {
    return $DeliveriesTable(attachedDatabase, alias);
  }
}

class DeliveryRow extends DataClass implements Insertable<DeliveryRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String deviceId;
  final String? userId;
  final bool deleted;
  final String productId;
  final int quantity;
  final int buyPrice;
  final DateTime? expiryDate;
  final String? supplierId;
  final DateTime receivedAt;
  final String? note;
  const DeliveryRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deviceId,
      this.userId,
      required this.deleted,
      required this.productId,
      required this.quantity,
      required this.buyPrice,
      this.expiryDate,
      this.supplierId,
      required this.receivedAt,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['deleted'] = Variable<bool>(deleted);
    map['product_id'] = Variable<String>(productId);
    map['quantity'] = Variable<int>(quantity);
    map['buy_price'] = Variable<int>(buyPrice);
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<DateTime>(expiryDate);
    }
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<String>(supplierId);
    }
    map['received_at'] = Variable<DateTime>(receivedAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  DeliveriesCompanion toCompanion(bool nullToAbsent) {
    return DeliveriesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deviceId: Value(deviceId),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      deleted: Value(deleted),
      productId: Value(productId),
      quantity: Value(quantity),
      buyPrice: Value(buyPrice),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      receivedAt: Value(receivedAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory DeliveryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeliveryRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      userId: serializer.fromJson<String?>(json['userId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      productId: serializer.fromJson<String>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      buyPrice: serializer.fromJson<int>(json['buyPrice']),
      expiryDate: serializer.fromJson<DateTime?>(json['expiryDate']),
      supplierId: serializer.fromJson<String?>(json['supplierId']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'userId': serializer.toJson<String?>(userId),
      'deleted': serializer.toJson<bool>(deleted),
      'productId': serializer.toJson<String>(productId),
      'quantity': serializer.toJson<int>(quantity),
      'buyPrice': serializer.toJson<int>(buyPrice),
      'expiryDate': serializer.toJson<DateTime?>(expiryDate),
      'supplierId': serializer.toJson<String?>(supplierId),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'note': serializer.toJson<String?>(note),
    };
  }

  DeliveryRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? deviceId,
          Value<String?> userId = const Value.absent(),
          bool? deleted,
          String? productId,
          int? quantity,
          int? buyPrice,
          Value<DateTime?> expiryDate = const Value.absent(),
          Value<String?> supplierId = const Value.absent(),
          DateTime? receivedAt,
          Value<String?> note = const Value.absent()}) =>
      DeliveryRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deviceId: deviceId ?? this.deviceId,
        userId: userId.present ? userId.value : this.userId,
        deleted: deleted ?? this.deleted,
        productId: productId ?? this.productId,
        quantity: quantity ?? this.quantity,
        buyPrice: buyPrice ?? this.buyPrice,
        expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
        supplierId: supplierId.present ? supplierId.value : this.supplierId,
        receivedAt: receivedAt ?? this.receivedAt,
        note: note.present ? note.value : this.note,
      );
  DeliveryRow copyWithCompanion(DeliveriesCompanion data) {
    return DeliveryRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      buyPrice: data.buyPrice.present ? data.buyPrice.value : this.buyPrice,
      expiryDate:
          data.expiryDate.present ? data.expiryDate.value : this.expiryDate,
      supplierId:
          data.supplierId.present ? data.supplierId.value : this.supplierId,
      receivedAt:
          data.receivedAt.present ? data.receivedAt.value : this.receivedAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeliveryRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('deleted: $deleted, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('buyPrice: $buyPrice, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('supplierId: $supplierId, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      deviceId,
      userId,
      deleted,
      productId,
      quantity,
      buyPrice,
      expiryDate,
      supplierId,
      receivedAt,
      note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeliveryRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deviceId == this.deviceId &&
          other.userId == this.userId &&
          other.deleted == this.deleted &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.buyPrice == this.buyPrice &&
          other.expiryDate == this.expiryDate &&
          other.supplierId == this.supplierId &&
          other.receivedAt == this.receivedAt &&
          other.note == this.note);
}

class DeliveriesCompanion extends UpdateCompanion<DeliveryRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> deviceId;
  final Value<String?> userId;
  final Value<bool> deleted;
  final Value<String> productId;
  final Value<int> quantity;
  final Value<int> buyPrice;
  final Value<DateTime?> expiryDate;
  final Value<String?> supplierId;
  final Value<DateTime> receivedAt;
  final Value<String?> note;
  final Value<int> rowid;
  const DeliveriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.buyPrice = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeliveriesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String deviceId,
    this.userId = const Value.absent(),
    this.deleted = const Value.absent(),
    required String productId,
    required int quantity,
    required int buyPrice,
    this.expiryDate = const Value.absent(),
    this.supplierId = const Value.absent(),
    required DateTime receivedAt,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        deviceId = Value(deviceId),
        productId = Value(productId),
        quantity = Value(quantity),
        buyPrice = Value(buyPrice),
        receivedAt = Value(receivedAt);
  static Insertable<DeliveryRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? deviceId,
    Expression<String>? userId,
    Expression<bool>? deleted,
    Expression<String>? productId,
    Expression<int>? quantity,
    Expression<int>? buyPrice,
    Expression<DateTime>? expiryDate,
    Expression<String>? supplierId,
    Expression<DateTime>? receivedAt,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (userId != null) 'user_id': userId,
      if (deleted != null) 'deleted': deleted,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (buyPrice != null) 'buy_price': buyPrice,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (supplierId != null) 'supplier_id': supplierId,
      if (receivedAt != null) 'received_at': receivedAt,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeliveriesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? deviceId,
      Value<String?>? userId,
      Value<bool>? deleted,
      Value<String>? productId,
      Value<int>? quantity,
      Value<int>? buyPrice,
      Value<DateTime?>? expiryDate,
      Value<String?>? supplierId,
      Value<DateTime>? receivedAt,
      Value<String?>? note,
      Value<int>? rowid}) {
    return DeliveriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      deleted: deleted ?? this.deleted,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      buyPrice: buyPrice ?? this.buyPrice,
      expiryDate: expiryDate ?? this.expiryDate,
      supplierId: supplierId ?? this.supplierId,
      receivedAt: receivedAt ?? this.receivedAt,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (buyPrice.present) {
      map['buy_price'] = Variable<int>(buyPrice.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeliveriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('deleted: $deleted, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('buyPrice: $buyPrice, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('supplierId: $supplierId, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, SaleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
      'number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<int> subtotal = GeneratedColumn<int>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _discountMeta =
      const VerificationMeta('discount');
  @override
  late final GeneratedColumn<int> discount = GeneratedColumn<int>(
      'discount', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
      'total', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _paidNowMeta =
      const VerificationMeta('paidNow');
  @override
  late final GeneratedColumn<int> paidNow = GeneratedColumn<int>(
      'paid_now', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
      'customer_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        deviceId,
        userId,
        deleted,
        number,
        subtotal,
        discount,
        total,
        paidNow,
        customerId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(Insertable<SaleRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('number')) {
      context.handle(_numberMeta,
          number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('discount')) {
      context.handle(_discountMeta,
          discount.isAcceptableOrUnknown(data['discount']!, _discountMeta));
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('paid_now')) {
      context.handle(_paidNowMeta,
          paidNow.isAcceptableOrUnknown(data['paid_now']!, _paidNowMeta));
    } else if (isInserting) {
      context.missing(_paidNowMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      number: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}number'])!,
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subtotal'])!,
      discount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}discount'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total'])!,
      paidNow: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}paid_now'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_id']),
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class SaleRow extends DataClass implements Insertable<SaleRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String deviceId;
  final String? userId;
  final bool deleted;

  /// Ticket number shown to people and printed on the receipt.
  final int number;
  final int subtotal;
  final int discount;
  final int total;

  /// Money received at checkout. Less than [total] only for credit sales.
  final int paidNow;
  final String? customerId;
  const SaleRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deviceId,
      this.userId,
      required this.deleted,
      required this.number,
      required this.subtotal,
      required this.discount,
      required this.total,
      required this.paidNow,
      this.customerId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['deleted'] = Variable<bool>(deleted);
    map['number'] = Variable<int>(number);
    map['subtotal'] = Variable<int>(subtotal);
    map['discount'] = Variable<int>(discount);
    map['total'] = Variable<int>(total);
    map['paid_now'] = Variable<int>(paidNow);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deviceId: Value(deviceId),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      deleted: Value(deleted),
      number: Value(number),
      subtotal: Value(subtotal),
      discount: Value(discount),
      total: Value(total),
      paidNow: Value(paidNow),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
    );
  }

  factory SaleRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      userId: serializer.fromJson<String?>(json['userId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      number: serializer.fromJson<int>(json['number']),
      subtotal: serializer.fromJson<int>(json['subtotal']),
      discount: serializer.fromJson<int>(json['discount']),
      total: serializer.fromJson<int>(json['total']),
      paidNow: serializer.fromJson<int>(json['paidNow']),
      customerId: serializer.fromJson<String?>(json['customerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'userId': serializer.toJson<String?>(userId),
      'deleted': serializer.toJson<bool>(deleted),
      'number': serializer.toJson<int>(number),
      'subtotal': serializer.toJson<int>(subtotal),
      'discount': serializer.toJson<int>(discount),
      'total': serializer.toJson<int>(total),
      'paidNow': serializer.toJson<int>(paidNow),
      'customerId': serializer.toJson<String?>(customerId),
    };
  }

  SaleRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? deviceId,
          Value<String?> userId = const Value.absent(),
          bool? deleted,
          int? number,
          int? subtotal,
          int? discount,
          int? total,
          int? paidNow,
          Value<String?> customerId = const Value.absent()}) =>
      SaleRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deviceId: deviceId ?? this.deviceId,
        userId: userId.present ? userId.value : this.userId,
        deleted: deleted ?? this.deleted,
        number: number ?? this.number,
        subtotal: subtotal ?? this.subtotal,
        discount: discount ?? this.discount,
        total: total ?? this.total,
        paidNow: paidNow ?? this.paidNow,
        customerId: customerId.present ? customerId.value : this.customerId,
      );
  SaleRow copyWithCompanion(SalesCompanion data) {
    return SaleRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      number: data.number.present ? data.number.value : this.number,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      discount: data.discount.present ? data.discount.value : this.discount,
      total: data.total.present ? data.total.value : this.total,
      paidNow: data.paidNow.present ? data.paidNow.value : this.paidNow,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('deleted: $deleted, ')
          ..write('number: $number, ')
          ..write('subtotal: $subtotal, ')
          ..write('discount: $discount, ')
          ..write('total: $total, ')
          ..write('paidNow: $paidNow, ')
          ..write('customerId: $customerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, deviceId, userId,
      deleted, number, subtotal, discount, total, paidNow, customerId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deviceId == this.deviceId &&
          other.userId == this.userId &&
          other.deleted == this.deleted &&
          other.number == this.number &&
          other.subtotal == this.subtotal &&
          other.discount == this.discount &&
          other.total == this.total &&
          other.paidNow == this.paidNow &&
          other.customerId == this.customerId);
}

class SalesCompanion extends UpdateCompanion<SaleRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> deviceId;
  final Value<String?> userId;
  final Value<bool> deleted;
  final Value<int> number;
  final Value<int> subtotal;
  final Value<int> discount;
  final Value<int> total;
  final Value<int> paidNow;
  final Value<String?> customerId;
  final Value<int> rowid;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.number = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discount = const Value.absent(),
    this.total = const Value.absent(),
    this.paidNow = const Value.absent(),
    this.customerId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String deviceId,
    this.userId = const Value.absent(),
    this.deleted = const Value.absent(),
    required int number,
    required int subtotal,
    this.discount = const Value.absent(),
    required int total,
    required int paidNow,
    this.customerId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        deviceId = Value(deviceId),
        number = Value(number),
        subtotal = Value(subtotal),
        total = Value(total),
        paidNow = Value(paidNow);
  static Insertable<SaleRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? deviceId,
    Expression<String>? userId,
    Expression<bool>? deleted,
    Expression<int>? number,
    Expression<int>? subtotal,
    Expression<int>? discount,
    Expression<int>? total,
    Expression<int>? paidNow,
    Expression<String>? customerId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (userId != null) 'user_id': userId,
      if (deleted != null) 'deleted': deleted,
      if (number != null) 'number': number,
      if (subtotal != null) 'subtotal': subtotal,
      if (discount != null) 'discount': discount,
      if (total != null) 'total': total,
      if (paidNow != null) 'paid_now': paidNow,
      if (customerId != null) 'customer_id': customerId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? deviceId,
      Value<String?>? userId,
      Value<bool>? deleted,
      Value<int>? number,
      Value<int>? subtotal,
      Value<int>? discount,
      Value<int>? total,
      Value<int>? paidNow,
      Value<String?>? customerId,
      Value<int>? rowid}) {
    return SalesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      deleted: deleted ?? this.deleted,
      number: number ?? this.number,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      paidNow: paidNow ?? this.paidNow,
      customerId: customerId ?? this.customerId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<int>(subtotal.value);
    }
    if (discount.present) {
      map['discount'] = Variable<int>(discount.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (paidNow.present) {
      map['paid_now'] = Variable<int>(paidNow.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('deleted: $deleted, ')
          ..write('number: $number, ')
          ..write('subtotal: $subtotal, ')
          ..write('discount: $discount, ')
          ..write('total: $total, ')
          ..write('paidNow: $paidNow, ')
          ..write('customerId: $customerId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleItemsTable extends SaleItems
    with TableInfo<$SaleItemsTable, SaleItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
      'sale_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sellPriceMeta =
      const VerificationMeta('sellPrice');
  @override
  late final GeneratedColumn<int> sellPrice = GeneratedColumn<int>(
      'sell_price', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitCostMeta =
      const VerificationMeta('unitCost');
  @override
  late final GeneratedColumn<int> unitCost = GeneratedColumn<int>(
      'unit_cost', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        deviceId,
        userId,
        deleted,
        saleId,
        productId,
        productName,
        sellPrice,
        unitCost,
        quantity
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_items';
  @override
  VerificationContext validateIntegrity(Insertable<SaleItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('sale_id')) {
      context.handle(_saleIdMeta,
          saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta));
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('sell_price')) {
      context.handle(_sellPriceMeta,
          sellPrice.isAcceptableOrUnknown(data['sell_price']!, _sellPriceMeta));
    } else if (isInserting) {
      context.missing(_sellPriceMeta);
    }
    if (data.containsKey('unit_cost')) {
      context.handle(_unitCostMeta,
          unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta));
    } else if (isInserting) {
      context.missing(_unitCostMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleItemRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      saleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sale_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      sellPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sell_price'])!,
      unitCost: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unit_cost'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
    );
  }

  @override
  $SaleItemsTable createAlias(String alias) {
    return $SaleItemsTable(attachedDatabase, alias);
  }
}

class SaleItemRow extends DataClass implements Insertable<SaleItemRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String deviceId;
  final String? userId;
  final bool deleted;
  final String saleId;
  final String productId;
  final String productName;
  final int sellPrice;
  final int unitCost;
  final int quantity;
  const SaleItemRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deviceId,
      this.userId,
      required this.deleted,
      required this.saleId,
      required this.productId,
      required this.productName,
      required this.sellPrice,
      required this.unitCost,
      required this.quantity});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['deleted'] = Variable<bool>(deleted);
    map['sale_id'] = Variable<String>(saleId);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['sell_price'] = Variable<int>(sellPrice);
    map['unit_cost'] = Variable<int>(unitCost);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  SaleItemsCompanion toCompanion(bool nullToAbsent) {
    return SaleItemsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deviceId: Value(deviceId),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      deleted: Value(deleted),
      saleId: Value(saleId),
      productId: Value(productId),
      productName: Value(productName),
      sellPrice: Value(sellPrice),
      unitCost: Value(unitCost),
      quantity: Value(quantity),
    );
  }

  factory SaleItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleItemRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      userId: serializer.fromJson<String?>(json['userId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      saleId: serializer.fromJson<String>(json['saleId']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      sellPrice: serializer.fromJson<int>(json['sellPrice']),
      unitCost: serializer.fromJson<int>(json['unitCost']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'userId': serializer.toJson<String?>(userId),
      'deleted': serializer.toJson<bool>(deleted),
      'saleId': serializer.toJson<String>(saleId),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'sellPrice': serializer.toJson<int>(sellPrice),
      'unitCost': serializer.toJson<int>(unitCost),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  SaleItemRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? deviceId,
          Value<String?> userId = const Value.absent(),
          bool? deleted,
          String? saleId,
          String? productId,
          String? productName,
          int? sellPrice,
          int? unitCost,
          int? quantity}) =>
      SaleItemRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deviceId: deviceId ?? this.deviceId,
        userId: userId.present ? userId.value : this.userId,
        deleted: deleted ?? this.deleted,
        saleId: saleId ?? this.saleId,
        productId: productId ?? this.productId,
        productName: productName ?? this.productName,
        sellPrice: sellPrice ?? this.sellPrice,
        unitCost: unitCost ?? this.unitCost,
        quantity: quantity ?? this.quantity,
      );
  SaleItemRow copyWithCompanion(SaleItemsCompanion data) {
    return SaleItemRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      sellPrice: data.sellPrice.present ? data.sellPrice.value : this.sellPrice,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('deleted: $deleted, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('sellPrice: $sellPrice, ')
          ..write('unitCost: $unitCost, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, deviceId, userId,
      deleted, saleId, productId, productName, sellPrice, unitCost, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleItemRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deviceId == this.deviceId &&
          other.userId == this.userId &&
          other.deleted == this.deleted &&
          other.saleId == this.saleId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.sellPrice == this.sellPrice &&
          other.unitCost == this.unitCost &&
          other.quantity == this.quantity);
}

class SaleItemsCompanion extends UpdateCompanion<SaleItemRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> deviceId;
  final Value<String?> userId;
  final Value<bool> deleted;
  final Value<String> saleId;
  final Value<String> productId;
  final Value<String> productName;
  final Value<int> sellPrice;
  final Value<int> unitCost;
  final Value<int> quantity;
  final Value<int> rowid;
  const SaleItemsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.saleId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.sellPrice = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleItemsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String deviceId,
    this.userId = const Value.absent(),
    this.deleted = const Value.absent(),
    required String saleId,
    required String productId,
    required String productName,
    required int sellPrice,
    required int unitCost,
    required int quantity,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        deviceId = Value(deviceId),
        saleId = Value(saleId),
        productId = Value(productId),
        productName = Value(productName),
        sellPrice = Value(sellPrice),
        unitCost = Value(unitCost),
        quantity = Value(quantity);
  static Insertable<SaleItemRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? deviceId,
    Expression<String>? userId,
    Expression<bool>? deleted,
    Expression<String>? saleId,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<int>? sellPrice,
    Expression<int>? unitCost,
    Expression<int>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (userId != null) 'user_id': userId,
      if (deleted != null) 'deleted': deleted,
      if (saleId != null) 'sale_id': saleId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (sellPrice != null) 'sell_price': sellPrice,
      if (unitCost != null) 'unit_cost': unitCost,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleItemsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? deviceId,
      Value<String?>? userId,
      Value<bool>? deleted,
      Value<String>? saleId,
      Value<String>? productId,
      Value<String>? productName,
      Value<int>? sellPrice,
      Value<int>? unitCost,
      Value<int>? quantity,
      Value<int>? rowid}) {
    return SaleItemsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      deleted: deleted ?? this.deleted,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sellPrice: sellPrice ?? this.sellPrice,
      unitCost: unitCost ?? this.unitCost,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (sellPrice.present) {
      map['sell_price'] = Variable<int>(sellPrice.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<int>(unitCost.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('deleted: $deleted, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('sellPrice: $sellPrice, ')
          ..write('unitCost: $unitCost, ')
          ..write('quantity: $quantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSettingRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final String value;
  const AppSettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppSettingRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingRow copyWith({String? key, String? value}) => AppSettingRow(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppSettingRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ShopsTable shops = $ShopsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $DeliveriesTable deliveries = $DeliveriesTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $SaleItemsTable saleItems = $SaleItemsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final Index productsBarcode = Index('products_barcode',
      'CREATE INDEX products_barcode ON products (barcode)');
  late final Index deliveriesProduct = Index('deliveries_product',
      'CREATE INDEX deliveries_product ON deliveries (product_id)');
  late final Index salesCreated = Index(
      'sales_created', 'CREATE INDEX sales_created ON sales (created_at)');
  late final Index saleItemsSale = Index('sale_items_sale',
      'CREATE INDEX sale_items_sale ON sale_items (sale_id)');
  late final Index saleItemsProduct = Index('sale_items_product',
      'CREATE INDEX sale_items_product ON sale_items (product_id)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        shops,
        categories,
        products,
        deliveries,
        sales,
        saleItems,
        appSettings,
        productsBarcode,
        deliveriesProduct,
        salesCreated,
        saleItemsSale,
        saleItemsProduct
      ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ShopsTableCreateCompanionBuilder = ShopsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  required String deviceId,
  Value<String?> userId,
  Value<bool> deleted,
  required String name,
  Value<String> address1,
  Value<String> address2,
  Value<String> phone,
  Value<String> footer,
  required String shopSecret,
  Value<int> expiryWarnDays,
  Value<int> maxWorkerDiscountPct,
  Value<int> rowid,
});
typedef $$ShopsTableUpdateCompanionBuilder = ShopsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> deviceId,
  Value<String?> userId,
  Value<bool> deleted,
  Value<String> name,
  Value<String> address1,
  Value<String> address2,
  Value<String> phone,
  Value<String> footer,
  Value<String> shopSecret,
  Value<int> expiryWarnDays,
  Value<int> maxWorkerDiscountPct,
  Value<int> rowid,
});

class $$ShopsTableFilterComposer extends Composer<_$AppDatabase, $ShopsTable> {
  $$ShopsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address1 => $composableBuilder(
      column: $table.address1, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address2 => $composableBuilder(
      column: $table.address2, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get footer => $composableBuilder(
      column: $table.footer, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shopSecret => $composableBuilder(
      column: $table.shopSecret, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get expiryWarnDays => $composableBuilder(
      column: $table.expiryWarnDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxWorkerDiscountPct => $composableBuilder(
      column: $table.maxWorkerDiscountPct,
      builder: (column) => ColumnFilters(column));
}

class $$ShopsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShopsTable> {
  $$ShopsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address1 => $composableBuilder(
      column: $table.address1, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address2 => $composableBuilder(
      column: $table.address2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get footer => $composableBuilder(
      column: $table.footer, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shopSecret => $composableBuilder(
      column: $table.shopSecret, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get expiryWarnDays => $composableBuilder(
      column: $table.expiryWarnDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxWorkerDiscountPct => $composableBuilder(
      column: $table.maxWorkerDiscountPct,
      builder: (column) => ColumnOrderings(column));
}

class $$ShopsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShopsTable> {
  $$ShopsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address1 =>
      $composableBuilder(column: $table.address1, builder: (column) => column);

  GeneratedColumn<String> get address2 =>
      $composableBuilder(column: $table.address2, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get footer =>
      $composableBuilder(column: $table.footer, builder: (column) => column);

  GeneratedColumn<String> get shopSecret => $composableBuilder(
      column: $table.shopSecret, builder: (column) => column);

  GeneratedColumn<int> get expiryWarnDays => $composableBuilder(
      column: $table.expiryWarnDays, builder: (column) => column);

  GeneratedColumn<int> get maxWorkerDiscountPct => $composableBuilder(
      column: $table.maxWorkerDiscountPct, builder: (column) => column);
}

class $$ShopsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShopsTable,
    ShopRow,
    $$ShopsTableFilterComposer,
    $$ShopsTableOrderingComposer,
    $$ShopsTableAnnotationComposer,
    $$ShopsTableCreateCompanionBuilder,
    $$ShopsTableUpdateCompanionBuilder,
    (ShopRow, BaseReferences<_$AppDatabase, $ShopsTable, ShopRow>),
    ShopRow,
    PrefetchHooks Function()> {
  $$ShopsTableTableManager(_$AppDatabase db, $ShopsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShopsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShopsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShopsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> address1 = const Value.absent(),
            Value<String> address2 = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String> footer = const Value.absent(),
            Value<String> shopSecret = const Value.absent(),
            Value<int> expiryWarnDays = const Value.absent(),
            Value<int> maxWorkerDiscountPct = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShopsCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deviceId: deviceId,
            userId: userId,
            deleted: deleted,
            name: name,
            address1: address1,
            address2: address2,
            phone: phone,
            footer: footer,
            shopSecret: shopSecret,
            expiryWarnDays: expiryWarnDays,
            maxWorkerDiscountPct: maxWorkerDiscountPct,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime createdAt,
            required DateTime updatedAt,
            required String deviceId,
            Value<String?> userId = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            required String name,
            Value<String> address1 = const Value.absent(),
            Value<String> address2 = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String> footer = const Value.absent(),
            required String shopSecret,
            Value<int> expiryWarnDays = const Value.absent(),
            Value<int> maxWorkerDiscountPct = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShopsCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deviceId: deviceId,
            userId: userId,
            deleted: deleted,
            name: name,
            address1: address1,
            address2: address2,
            phone: phone,
            footer: footer,
            shopSecret: shopSecret,
            expiryWarnDays: expiryWarnDays,
            maxWorkerDiscountPct: maxWorkerDiscountPct,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ShopsTable, ShopRow>(table),
                    BaseReferences<_$AppDatabase, $ShopsTable, ShopRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ShopsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ShopsTable,
    ShopRow,
    $$ShopsTableFilterComposer,
    $$ShopsTableOrderingComposer,
    $$ShopsTableAnnotationComposer,
    $$ShopsTableCreateCompanionBuilder,
    $$ShopsTableUpdateCompanionBuilder,
    (ShopRow, BaseReferences<_$AppDatabase, $ShopsTable, ShopRow>),
    ShopRow,
    PrefetchHooks Function()>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  required String deviceId,
  Value<String?> userId,
  Value<bool> deleted,
  required String name,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> deviceId,
  Value<String?> userId,
  Value<bool> deleted,
  Value<String> name,
  Value<int> rowid,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryRow,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryRow, BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>),
    CategoryRow,
    PrefetchHooks Function()> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deviceId: deviceId,
            userId: userId,
            deleted: deleted,
            name: name,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime createdAt,
            required DateTime updatedAt,
            required String deviceId,
            Value<String?> userId = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deviceId: deviceId,
            userId: userId,
            deleted: deleted,
            name: name,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CategoriesTable, CategoryRow>(table),
                    BaseReferences<_$AppDatabase, $CategoriesTable,
                        CategoryRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryRow,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryRow, BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>),
    CategoryRow,
    PrefetchHooks Function()>;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  required String deviceId,
  Value<String?> userId,
  Value<bool> deleted,
  required String name,
  required String barcode,
  required int sellPrice,
  Value<int> buyPrice,
  Value<String?> categoryId,
  Value<int> lowStockThreshold,
  Value<bool> archived,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> deviceId,
  Value<String?> userId,
  Value<bool> deleted,
  Value<String> name,
  Value<String> barcode,
  Value<int> sellPrice,
  Value<int> buyPrice,
  Value<String?> categoryId,
  Value<int> lowStockThreshold,
  Value<bool> archived,
  Value<int> rowid,
});

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sellPrice => $composableBuilder(
      column: $table.sellPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get buyPrice => $composableBuilder(
      column: $table.buyPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lowStockThreshold => $composableBuilder(
      column: $table.lowStockThreshold,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archived => $composableBuilder(
      column: $table.archived, builder: (column) => ColumnFilters(column));
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sellPrice => $composableBuilder(
      column: $table.sellPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get buyPrice => $composableBuilder(
      column: $table.buyPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lowStockThreshold => $composableBuilder(
      column: $table.lowStockThreshold,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived => $composableBuilder(
      column: $table.archived, builder: (column) => ColumnOrderings(column));
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<int> get sellPrice =>
      $composableBuilder(column: $table.sellPrice, builder: (column) => column);

  GeneratedColumn<int> get buyPrice =>
      $composableBuilder(column: $table.buyPrice, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<int> get lowStockThreshold => $composableBuilder(
      column: $table.lowStockThreshold, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);
}

class $$ProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTable,
    ProductRow,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (ProductRow, BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>),
    ProductRow,
    PrefetchHooks Function()> {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> barcode = const Value.absent(),
            Value<int> sellPrice = const Value.absent(),
            Value<int> buyPrice = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<int> lowStockThreshold = const Value.absent(),
            Value<bool> archived = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deviceId: deviceId,
            userId: userId,
            deleted: deleted,
            name: name,
            barcode: barcode,
            sellPrice: sellPrice,
            buyPrice: buyPrice,
            categoryId: categoryId,
            lowStockThreshold: lowStockThreshold,
            archived: archived,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime createdAt,
            required DateTime updatedAt,
            required String deviceId,
            Value<String?> userId = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            required String name,
            required String barcode,
            required int sellPrice,
            Value<int> buyPrice = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<int> lowStockThreshold = const Value.absent(),
            Value<bool> archived = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deviceId: deviceId,
            userId: userId,
            deleted: deleted,
            name: name,
            barcode: barcode,
            sellPrice: sellPrice,
            buyPrice: buyPrice,
            categoryId: categoryId,
            lowStockThreshold: lowStockThreshold,
            archived: archived,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ProductsTable, ProductRow>(table),
                    BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTable,
    ProductRow,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (ProductRow, BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>),
    ProductRow,
    PrefetchHooks Function()>;
typedef $$DeliveriesTableCreateCompanionBuilder = DeliveriesCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  required String deviceId,
  Value<String?> userId,
  Value<bool> deleted,
  required String productId,
  required int quantity,
  required int buyPrice,
  Value<DateTime?> expiryDate,
  Value<String?> supplierId,
  required DateTime receivedAt,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$DeliveriesTableUpdateCompanionBuilder = DeliveriesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> deviceId,
  Value<String?> userId,
  Value<bool> deleted,
  Value<String> productId,
  Value<int> quantity,
  Value<int> buyPrice,
  Value<DateTime?> expiryDate,
  Value<String?> supplierId,
  Value<DateTime> receivedAt,
  Value<String?> note,
  Value<int> rowid,
});

class $$DeliveriesTableFilterComposer
    extends Composer<_$AppDatabase, $DeliveriesTable> {
  $$DeliveriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get buyPrice => $composableBuilder(
      column: $table.buyPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
      column: $table.receivedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$DeliveriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DeliveriesTable> {
  $$DeliveriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get buyPrice => $composableBuilder(
      column: $table.buyPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
      column: $table.receivedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$DeliveriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeliveriesTable> {
  $$DeliveriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get buyPrice =>
      $composableBuilder(column: $table.buyPrice, builder: (column) => column);

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => column);

  GeneratedColumn<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
      column: $table.receivedAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$DeliveriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DeliveriesTable,
    DeliveryRow,
    $$DeliveriesTableFilterComposer,
    $$DeliveriesTableOrderingComposer,
    $$DeliveriesTableAnnotationComposer,
    $$DeliveriesTableCreateCompanionBuilder,
    $$DeliveriesTableUpdateCompanionBuilder,
    (DeliveryRow, BaseReferences<_$AppDatabase, $DeliveriesTable, DeliveryRow>),
    DeliveryRow,
    PrefetchHooks Function()> {
  $$DeliveriesTableTableManager(_$AppDatabase db, $DeliveriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeliveriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeliveriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeliveriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> buyPrice = const Value.absent(),
            Value<DateTime?> expiryDate = const Value.absent(),
            Value<String?> supplierId = const Value.absent(),
            Value<DateTime> receivedAt = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DeliveriesCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deviceId: deviceId,
            userId: userId,
            deleted: deleted,
            productId: productId,
            quantity: quantity,
            buyPrice: buyPrice,
            expiryDate: expiryDate,
            supplierId: supplierId,
            receivedAt: receivedAt,
            note: note,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime createdAt,
            required DateTime updatedAt,
            required String deviceId,
            Value<String?> userId = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            required String productId,
            required int quantity,
            required int buyPrice,
            Value<DateTime?> expiryDate = const Value.absent(),
            Value<String?> supplierId = const Value.absent(),
            required DateTime receivedAt,
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DeliveriesCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deviceId: deviceId,
            userId: userId,
            deleted: deleted,
            productId: productId,
            quantity: quantity,
            buyPrice: buyPrice,
            expiryDate: expiryDate,
            supplierId: supplierId,
            receivedAt: receivedAt,
            note: note,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$DeliveriesTable, DeliveryRow>(table),
                    BaseReferences<_$AppDatabase, $DeliveriesTable,
                        DeliveryRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DeliveriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DeliveriesTable,
    DeliveryRow,
    $$DeliveriesTableFilterComposer,
    $$DeliveriesTableOrderingComposer,
    $$DeliveriesTableAnnotationComposer,
    $$DeliveriesTableCreateCompanionBuilder,
    $$DeliveriesTableUpdateCompanionBuilder,
    (DeliveryRow, BaseReferences<_$AppDatabase, $DeliveriesTable, DeliveryRow>),
    DeliveryRow,
    PrefetchHooks Function()>;
typedef $$SalesTableCreateCompanionBuilder = SalesCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  required String deviceId,
  Value<String?> userId,
  Value<bool> deleted,
  required int number,
  required int subtotal,
  Value<int> discount,
  required int total,
  required int paidNow,
  Value<String?> customerId,
  Value<int> rowid,
});
typedef $$SalesTableUpdateCompanionBuilder = SalesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> deviceId,
  Value<String?> userId,
  Value<bool> deleted,
  Value<int> number,
  Value<int> subtotal,
  Value<int> discount,
  Value<int> total,
  Value<int> paidNow,
  Value<String?> customerId,
  Value<int> rowid,
});

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get paidNow => $composableBuilder(
      column: $table.paidNow, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnFilters(column));
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get paidNow => $composableBuilder(
      column: $table.paidNow, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnOrderings(column));
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<int> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<int> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<int> get paidNow =>
      $composableBuilder(column: $table.paidNow, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => column);
}

class $$SalesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SalesTable,
    SaleRow,
    $$SalesTableFilterComposer,
    $$SalesTableOrderingComposer,
    $$SalesTableAnnotationComposer,
    $$SalesTableCreateCompanionBuilder,
    $$SalesTableUpdateCompanionBuilder,
    (SaleRow, BaseReferences<_$AppDatabase, $SalesTable, SaleRow>),
    SaleRow,
    PrefetchHooks Function()> {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<int> number = const Value.absent(),
            Value<int> subtotal = const Value.absent(),
            Value<int> discount = const Value.absent(),
            Value<int> total = const Value.absent(),
            Value<int> paidNow = const Value.absent(),
            Value<String?> customerId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SalesCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deviceId: deviceId,
            userId: userId,
            deleted: deleted,
            number: number,
            subtotal: subtotal,
            discount: discount,
            total: total,
            paidNow: paidNow,
            customerId: customerId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime createdAt,
            required DateTime updatedAt,
            required String deviceId,
            Value<String?> userId = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            required int number,
            required int subtotal,
            Value<int> discount = const Value.absent(),
            required int total,
            required int paidNow,
            Value<String?> customerId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SalesCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deviceId: deviceId,
            userId: userId,
            deleted: deleted,
            number: number,
            subtotal: subtotal,
            discount: discount,
            total: total,
            paidNow: paidNow,
            customerId: customerId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SalesTable, SaleRow>(table),
                    BaseReferences<_$AppDatabase, $SalesTable, SaleRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SalesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SalesTable,
    SaleRow,
    $$SalesTableFilterComposer,
    $$SalesTableOrderingComposer,
    $$SalesTableAnnotationComposer,
    $$SalesTableCreateCompanionBuilder,
    $$SalesTableUpdateCompanionBuilder,
    (SaleRow, BaseReferences<_$AppDatabase, $SalesTable, SaleRow>),
    SaleRow,
    PrefetchHooks Function()>;
typedef $$SaleItemsTableCreateCompanionBuilder = SaleItemsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  required String deviceId,
  Value<String?> userId,
  Value<bool> deleted,
  required String saleId,
  required String productId,
  required String productName,
  required int sellPrice,
  required int unitCost,
  required int quantity,
  Value<int> rowid,
});
typedef $$SaleItemsTableUpdateCompanionBuilder = SaleItemsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> deviceId,
  Value<String?> userId,
  Value<bool> deleted,
  Value<String> saleId,
  Value<String> productId,
  Value<String> productName,
  Value<int> sellPrice,
  Value<int> unitCost,
  Value<int> quantity,
  Value<int> rowid,
});

class $$SaleItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get saleId => $composableBuilder(
      column: $table.saleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sellPrice => $composableBuilder(
      column: $table.sellPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));
}

class $$SaleItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get saleId => $composableBuilder(
      column: $table.saleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sellPrice => $composableBuilder(
      column: $table.sellPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));
}

class $$SaleItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<int> get sellPrice =>
      $composableBuilder(column: $table.sellPrice, builder: (column) => column);

  GeneratedColumn<int> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$SaleItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SaleItemsTable,
    SaleItemRow,
    $$SaleItemsTableFilterComposer,
    $$SaleItemsTableOrderingComposer,
    $$SaleItemsTableAnnotationComposer,
    $$SaleItemsTableCreateCompanionBuilder,
    $$SaleItemsTableUpdateCompanionBuilder,
    (SaleItemRow, BaseReferences<_$AppDatabase, $SaleItemsTable, SaleItemRow>),
    SaleItemRow,
    PrefetchHooks Function()> {
  $$SaleItemsTableTableManager(_$AppDatabase db, $SaleItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<String> saleId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<int> sellPrice = const Value.absent(),
            Value<int> unitCost = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SaleItemsCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deviceId: deviceId,
            userId: userId,
            deleted: deleted,
            saleId: saleId,
            productId: productId,
            productName: productName,
            sellPrice: sellPrice,
            unitCost: unitCost,
            quantity: quantity,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime createdAt,
            required DateTime updatedAt,
            required String deviceId,
            Value<String?> userId = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            required String saleId,
            required String productId,
            required String productName,
            required int sellPrice,
            required int unitCost,
            required int quantity,
            Value<int> rowid = const Value.absent(),
          }) =>
              SaleItemsCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deviceId: deviceId,
            userId: userId,
            deleted: deleted,
            saleId: saleId,
            productId: productId,
            productName: productName,
            sellPrice: sellPrice,
            unitCost: unitCost,
            quantity: quantity,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SaleItemsTable, SaleItemRow>(table),
                    BaseReferences<_$AppDatabase, $SaleItemsTable, SaleItemRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SaleItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SaleItemsTable,
    SaleItemRow,
    $$SaleItemsTableFilterComposer,
    $$SaleItemsTableOrderingComposer,
    $$SaleItemsTableAnnotationComposer,
    $$SaleItemsTableCreateCompanionBuilder,
    $$SaleItemsTableUpdateCompanionBuilder,
    (SaleItemRow, BaseReferences<_$AppDatabase, $SaleItemsTable, SaleItemRow>),
    SaleItemRow,
    PrefetchHooks Function()>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSettingRow,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (
      AppSettingRow,
      BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>
    ),
    AppSettingRow,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AppSettingsTable, AppSettingRow>(table),
                    BaseReferences<_$AppDatabase, $AppSettingsTable,
                        AppSettingRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSettingRow,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (
      AppSettingRow,
      BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>
    ),
    AppSettingRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ShopsTableTableManager get shops =>
      $$ShopsTableTableManager(_db, _db.shops);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$DeliveriesTableTableManager get deliveries =>
      $$DeliveriesTableTableManager(_db, _db.deliveries);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$SaleItemsTableTableManager get saleItems =>
      $$SaleItemsTableTableManager(_db, _db.saleItems);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
