import '../../../core/settings/settings_store.dart';

/// What this phone is in the shop's Wi-Fi sync.
enum SyncRole {
  /// Not linked to other phones (the only phone).
  none,

  /// The owner's phone: the others sync with it.
  hub,

  /// A phone linked to the hub.
  worker,
}

/// Phone settings of the Wi-Fi sync (never synced themselves).
extension SyncSettings on SettingsStore {
  static const _role = 'sync_role';
  static const _hubHost = 'sync_hub_host';
  static const _hubPort = 'sync_hub_port';
  static const _shopId = 'sync_shop_id';
  static const _secret = 'sync_secret';
  static const _cursor = 'sync_cursor';
  static const _lastSync = 'sync_last';
  static const _code = 'sync_device_code';
  static const _hubRunning = 'sync_hub_running';

  SyncRole get syncRole =>
      SyncRole.values.asNameMap()[get(_role)] ?? SyncRole.none;
  Future<void> setSyncRole(SyncRole role) =>
      set(_role, role == SyncRole.none ? null : role.name);

  /// Worker: where the hub is and the shop it belongs to.
  String? get hubHost => get(_hubHost);
  int get hubPort => int.tryParse(get(_hubPort) ?? '') ?? 8787;
  String? get syncShopId => get(_shopId);
  String? get syncSecret => get(_secret);

  Future<void> setHub(
      {required String host,
      required int port,
      required String shopId,
      required String secret}) async {
    await set(_hubHost, host);
    await set(_hubPort, '$port');
    await set(_shopId, shopId);
    await set(_secret, secret);
  }

  Future<void> setHubHost(String host) => set(_hubHost, host);

  /// Worker: the last change received from the hub.
  int get syncCursor => int.tryParse(get(_cursor) ?? '') ?? 0;
  Future<void> setSyncCursor(int value) => set(_cursor, '$value');

  /// Worker: when the last sync worked.
  DateTime? get lastSync => DateTime.tryParse(get(_lastSync) ?? '');
  Future<void> setLastSync(DateTime at) => set(_lastSync, at.toIso8601String());

  /// The letter of this phone (B, C...), given by the hub.
  String? get deviceCode => get(_code);
  Future<void> setDeviceCode(String code) => set(_code, code);

  /// Hub: when a worker phone last synced.
  DateTime? lastSyncOf(String deviceId) =>
      DateTime.tryParse(get('sync_last_$deviceId') ?? '');
  Future<void> setLastSyncOf(String deviceId, DateTime at) =>
      set('sync_last_$deviceId', at.toIso8601String());

  /// Hub: switched on by the owner (started again with the app).
  bool get hubRunning => get(_hubRunning) == 'true';
  Future<void> setHubRunning(bool on) => set(_hubRunning, on ? 'true' : null);

  /// Forgets everything about the sync (before joining another shop).
  Future<void> clearSync() async {
    for (final key in [
      _role,
      _hubHost,
      _hubPort,
      _shopId,
      _secret,
      _cursor,
      _lastSync,
      _code,
      _hubRunning,
      'alerts_since',
    ]) {
      await set(key, null);
    }
  }
}
