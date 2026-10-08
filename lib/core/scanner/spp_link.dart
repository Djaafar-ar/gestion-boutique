import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// A Bluetooth device already paired in the phone's settings.
class BtDevice {
  final String name;
  final String address;
  const BtDevice(this.name, this.address);
}

/// What an SPP scanner sends: a barcode, or "the connection was lost".
sealed class SppEvent {
  const SppEvent();
}

class SppCode extends SppEvent {
  final String code;
  const SppCode(this.code);
}

class SppDisconnected extends SppEvent {
  const SppDisconnected();
}

/// The Android side of the barcode scanner (android/.../SppScanner.kt):
/// scanners in "SPP" mode (a Bluetooth serial link) and the beep.
/// Tests use a fake one.
abstract class SppLink {
  Future<List<BtDevice>> bondedDevices();
  Future<bool> connect(String address);
  Future<void> disconnect();
  Stream<SppEvent> get events;

  /// A short beep (a scan was accepted).
  Future<void> beep();
}

class MethodChannelSppLink implements SppLink {
  static const _methods = MethodChannel('gestion_boutique/scanner');
  static const _events = EventChannel('gestion_boutique/scanner/events');

  late final Stream<SppEvent> _stream = _events
      .receiveBroadcastStream()
      .map<SppEvent>((event) {
        final data = Map<String, Object?>.from(event as Map);
        final code = data['code'];
        return code is String ? SppCode(code) : const SppDisconnected();
      })
      .handleError((Object e) => debugPrint('Scanner link: $e'))
      .asBroadcastStream();

  @override
  Stream<SppEvent> get events => _stream;

  @override
  Future<List<BtDevice>> bondedDevices() async {
    try {
      // Android 12+ asks the person once.
      await [Permission.bluetoothConnect, Permission.bluetoothScan].request();
      final list = await _methods.invokeListMethod<Map>('bondedDevices');
      return [
        for (final d in list ?? const [])
          BtDevice('${d['name']}', '${d['address']}'),
      ];
    } catch (e) {
      debugPrint('Paired devices unavailable: $e');
      return const [];
    }
  }

  @override
  Future<bool> connect(String address) async {
    try {
      return await _methods
              .invokeMethod<bool>('connect', {'address': address}) ??
          false;
    } catch (e) {
      debugPrint('Scanner connect failed: $e');
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _methods.invokeMethod<void>('disconnect');
    } catch (_) {
      // Already gone.
    }
  }

  @override
  Future<void> beep() async {
    try {
      await _methods.invokeMethod<void>('beep');
    } catch (_) {
      // No sound: the vibration is enough.
    }
  }
}
