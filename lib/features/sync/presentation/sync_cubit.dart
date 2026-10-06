import 'dart:async';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/database/app_database.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/session/session_cubit.dart';
import '../../../core/settings/settings_store.dart';
import '../data/hub_keep_alive.dart';
import '../data/hub_service.dart';
import '../data/sync_client.dart';
import '../data/sync_network.dart';
import '../data/sync_protocol.dart';
import '../data/sync_settings.dart';
import '../data/sync_store.dart';

enum SyncStatus { idle, syncing, ok, error }

/// A phone of the shop, as listed on the hub.
class LinkedPhone extends Equatable {
  final String id;
  final String code;
  final String name;
  final bool isHub;
  final bool isThisPhone;
  final DateTime? lastSync;

  const LinkedPhone({
    required this.id,
    required this.code,
    required this.name,
    required this.isHub,
    required this.isThisPhone,
    this.lastSync,
  });

  @override
  List<Object?> get props => [id, code, name, isHub, isThisPhone, lastSync];
}

class SyncState extends Equatable {
  final SyncRole role;

  /// Hub: answering the other phones, and where.
  final bool hubRunning;
  final String? hubAddress;
  final List<LinkedPhone> phones;

  /// Worker: the last sync.
  final SyncStatus status;
  final SyncError? error;
  final DateTime? lastSync;
  final SyncSummary? lastSummary;

  /// Changes made here and not sent yet.
  final int pending;
  final String? deviceCode;
  final String? shopName;

  const SyncState({
    this.role = SyncRole.none,
    this.hubRunning = false,
    this.hubAddress,
    this.phones = const [],
    this.status = SyncStatus.idle,
    this.error,
    this.lastSync,
    this.lastSummary,
    this.pending = 0,
    this.deviceCode,
    this.shopName,
  });

  SyncState copyWith({
    SyncRole? role,
    bool? hubRunning,
    String? hubAddress,
    bool clearAddress = false,
    List<LinkedPhone>? phones,
    SyncStatus? status,
    SyncError? error,
    bool clearError = false,
    DateTime? lastSync,
    SyncSummary? lastSummary,
    int? pending,
    String? deviceCode,
    String? shopName,
  }) =>
      SyncState(
        role: role ?? this.role,
        hubRunning: hubRunning ?? this.hubRunning,
        hubAddress: clearAddress ? null : (hubAddress ?? this.hubAddress),
        phones: phones ?? this.phones,
        status: status ?? this.status,
        error: clearError ? null : (error ?? this.error),
        lastSync: lastSync ?? this.lastSync,
        lastSummary: lastSummary ?? this.lastSummary,
        pending: pending ?? this.pending,
        deviceCode: deviceCode ?? this.deviceCode,
        shopName: shopName ?? this.shopName,
      );

  @override
  List<Object?> get props => [
        role,
        hubRunning,
        hubAddress,
        phones,
        status,
        error,
        lastSync,
        lastSummary,
        pending,
        deviceCode,
        shopName,
      ];
}

/// Runs the Wi-Fi sync of this phone: the hub on the owner's phone, the
/// automatic syncs on a worker's phone.
class SyncCubit extends Cubit<SyncState> {
  final AppDatabase db;
  final SyncStore store;
  final SettingsStore settings;
  final HubService hub;
  final HubServer server;
  final SyncClient client;
  final HubKeepAlive keepAlive;
  final SessionCubit session;
  final Locale Function() locale;

  /// Where the hub listens (another port in tests).
  final int hubPort;
  final int? discoveryPort;

  /// A worker phone syncs this often on its own...
  static const every = Duration(minutes: 2);

  /// ...and this long after something was done on it (a sale...).
  static const afterChange = Duration(seconds: 5);

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Timer? _timer;
  Timer? _debounce;

  SyncCubit({
    required this.db,
    required this.store,
    required this.settings,
    required this.hub,
    required this.server,
    required this.client,
    required this.keepAlive,
    required this.session,
    required this.locale,
    this.hubPort = syncPort,
    this.discoveryPort = 8788,
  }) : super(const SyncState());

  /// Called once when the app starts.
  Future<void> start() async {
    await _refresh();
    // Rows from other phones: the hub's list of phones changes.
    _subscriptions.add(store.received.listen((_) => _refresh()));
    switch (settings.syncRole) {
      case SyncRole.hub when settings.hubRunning:
        await startHub();
      case SyncRole.worker:
        _startWorker();
      default:
    }
  }

  Future<void> _refresh() async {
    final keys = await hub.shop();
    final devices = await db.select(db.devices).get();
    final phones = [
      for (final d in devices)
        if (!d.deleted)
          LinkedPhone(
            id: d.id,
            code: d.code,
            name: d.name,
            isHub: d.role == 'hub',
            isThisPhone: d.id == settings.deviceId,
            lastSync: settings.lastSyncOf(d.id),
          ),
    ]..sort((a, b) => a.code.compareTo(b.code));
    if (isClosed) return;
    emit(state.copyWith(
      role: settings.syncRole,
      phones: phones,
      shopName: keys?.name,
      deviceCode: settings.deviceCode,
      lastSync: settings.lastSync,
      pending:
          settings.syncRole == SyncRole.worker ? await store.outboxCount() : 0,
    ));
  }

  // ------------------------------------------------------------------ hub

  /// Owner: makes this phone the hub (if not yet) and starts answering.
  Future<void> startHub() async {
    if (settings.syncRole == SyncRole.worker) return;
    if (settings.syncRole == SyncRole.none) {
      await hub.becomeHub(name: session.state.user?.name ?? 'Hub');
    }
    try {
      await server.start(port: hubPort, discovery: discoveryPort);
    } catch (_) {
      emit(state.copyWith(error: SyncError.other));
      return;
    }
    await settings.setHubRunning(true);
    final l10n = lookupAppLocalizations(locale());
    await keepAlive.start(
        title: l10n.hubServiceTitle, text: l10n.hubServiceText);
    final address = await localWifiAddress();
    emit(state.copyWith(
        hubRunning: true,
        hubAddress: address == null ? null : '$address:${server.port}',
        clearAddress: address == null,
        clearError: true));
    await _refresh();
  }

  Future<void> stopHub() async {
    await server.stop();
    await keepAlive.stop();
    await settings.setHubRunning(false);
    emit(state.copyWith(hubRunning: false, clearAddress: true));
  }

  /// What the pairing QR code shows, or null without Wi-Fi.
  Future<PairingInfo?> pairingInfo() async {
    final keys = await hub.shop();
    final address = await localWifiAddress();
    if (keys == null || address == null || !server.running) return null;
    return PairingInfo(
        host: address,
        port: server.port!,
        shopId: keys.id,
        secret: keys.secret,
        shopName: keys.name);
  }

  Future<void> removePhone(String deviceId) async {
    await hub.removeDevice(deviceId);
    await _refresh();
  }

  // --------------------------------------------------------------- worker

  /// Links this (empty) phone to the hub and downloads the shop.
  Future<String> join(PairingInfo info, {required String deviceName}) async {
    final code = await client.join(info, deviceName: deviceName);
    session.shopJoined();
    _startWorker();
    await _refresh();
    return code;
  }

  void _startWorker() {
    if (_timer != null) return;
    _timer = Timer.periodic(every, (_) => syncNow());
    _subscriptions.add(db
        .tableUpdates(TableUpdateQuery.onAllTables([
      db.sales,
      db.deliveries,
      db.losses,
      db.returns,
      db.products,
      db.customers,
      db.customerPayments,
      db.supplierPayments,
      db.suppliers,
      db.users,
    ]))
        .listen((_) {
      if (state.status == SyncStatus.syncing) return;
      _debounce?.cancel();
      _debounce = Timer(afterChange, () async {
        if (await store.outboxCount() > 0) await syncNow();
      });
    }));
    syncNow();
  }

  /// Worker: sends and receives now.
  Future<void> syncNow() async {
    if (settings.syncRole != SyncRole.worker ||
        state.status == SyncStatus.syncing ||
        isClosed) {
      return;
    }
    emit(state.copyWith(status: SyncStatus.syncing));
    try {
      final summary = await client.sync();
      if (isClosed) return;
      emit(state.copyWith(
          status: SyncStatus.ok, lastSummary: summary, clearError: true));
    } on SyncException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: SyncStatus.error, error: e.error));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(status: SyncStatus.error, error: SyncError.other));
    }
    await _refresh();
  }

  /// Owner of a phone that is not linked yet: erases it so it can join
  /// the owner's shop as a worker phone.
  Future<void> eraseThisPhone() async {
    await stopHub();
    _timer?.cancel();
    _timer = null;
    await store.wipe();
    await settings.clearSync();
    emit(const SyncState());
    session.shopLeft();
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _timer?.cancel();
    _debounce?.cancel();
    await server.stop();
    return super.close();
  }
}
