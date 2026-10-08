import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:vibration/vibration.dart';

import '../settings/settings_store.dart';
import 'spp_link.dart';

/// A screen that wants scans (see [ScanListener]).
abstract class ScanTarget {
  /// True while the screen is the one the person sees.
  bool get acceptsScans;

  /// Uses the barcode. Returns true when it was accepted (a known
  /// product...): then the phone beeps.
  bool onScan(String code);
}

enum SppStatus { none, connecting, connected, disconnected }

/// The Bluetooth barcode scanner ("douchette"), for the whole app.
///
/// - Most scanners act like a keyboard (HID): they type the barcode and
///   press Enter. While no text field is being typed in, those keys are
///   caught here and the barcode goes to the screen on top. When a text
///   field has the focus, the scanner simply types into it.
/// - Scanners in "SPP" mode send the barcode over a Bluetooth serial
///   link: the phone connects to the one chosen in Plus → Douchette and
///   reconnects by itself.
///
/// The PC keyboard of the emulator works the same way: type a barcode,
/// then Enter.
class BarcodeScanService {
  final SppLink spp;
  final SettingsStore settings;
  final DateTime Function() clock;

  /// Keys further apart than this start a new barcode.
  static const keyGap = Duration(milliseconds: 1500);
  static const minLength = 3;
  static const retryEvery = Duration(seconds: 15);

  static const _sppAddress = 'scanner_spp_address';
  static const _sppName = 'scanner_spp_name';
  static const _feedback = 'scanner_feedback';

  final List<ScanTarget> _targets = [];
  final _buffer = StringBuffer();
  DateTime? _lastKey;
  final _scans = StreamController<String>.broadcast();
  final ValueNotifier<SppStatus> sppStatus = ValueNotifier(SppStatus.none);
  StreamSubscription<SppEvent>? _sppEvents;
  Timer? _retry;
  bool _started = false;

  BarcodeScanService(this.spp, this.settings, {DateTime Function()? clock})
      : clock = clock ?? DateTime.now;

  /// Every barcode received, wherever it went.
  Stream<String> get scans => _scans.stream;

  String? get sppAddress => settings.get(_sppAddress);
  String? get sppName => settings.get(_sppName);

  /// Beep and vibrate when a scan is accepted (on by default).
  bool get feedbackOn => settings.get(_feedback) != 'off';
  Future<void> setFeedback(bool on) =>
      settings.set(_feedback, on ? null : 'off');

  void start() {
    if (_started) return;
    _started = true;
    HardwareKeyboard.instance.addHandler(handleKey);
    _sppEvents = spp.events.listen(_onSpp);
    if (sppAddress != null) unawaited(_connectRemembered());
  }

  Future<void> stop() async {
    if (!_started) return;
    _started = false;
    HardwareKeyboard.instance.removeHandler(handleKey);
    await _sppEvents?.cancel();
    _retry?.cancel();
  }

  void register(ScanTarget target) => _targets.add(target);
  void unregister(ScanTarget target) => _targets.remove(target);

  /// Is someone typing in a text field? Then the keys are theirs.
  static bool get _typingInField {
    final context = FocusManager.instance.primaryFocus?.context;
    if (context == null) return false;
    return context.widget is EditableText ||
        context.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  /// Keys from a keyboard scanner (or the emulator's PC keyboard).
  /// Returns true when the key was used for a barcode.
  bool handleKey(KeyEvent event) {
    if (event is KeyUpEvent || _typingInField) return false;
    final key = event.logicalKey;
    final now = clock();
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.tab) {
      if (_buffer.isEmpty) return false;
      final code = _buffer.toString();
      _buffer.clear();
      if (code.length < minLength) return true;
      deliver(code);
      return true;
    }
    final character = event.character;
    if (character == null ||
        character.isEmpty ||
        character.codeUnitAt(0) < 0x20 ||
        character.codeUnitAt(0) == 0x7f) {
      return false;
    }
    final last = _lastKey;
    if (last != null && now.difference(last) > keyGap) _buffer.clear();
    _lastKey = now;
    _buffer.write(character);
    return true;
  }

  /// Gives [code] to the screen on top, and beeps when it accepted it.
  /// Returns true when a screen took it.
  bool deliver(String code) {
    final clean = code.trim();
    if (clean.isEmpty) return false;
    _scans.add(clean);
    for (final target in _targets.reversed) {
      if (target.acceptsScans) {
        if (target.onScan(clean)) unawaited(accepted());
        return true;
      }
    }
    return false;
  }

  /// A short beep and vibration: the scan was accepted.
  Future<void> accepted() async {
    if (!feedbackOn) return;
    unawaited(spp.beep());
    try {
      if (await Vibration.hasVibrator()) await Vibration.vibrate(duration: 60);
    } catch (_) {
      // No vibrator (tests, some tablets).
    }
  }

  // ------------------------------------------------------------------ SPP

  void _onSpp(SppEvent event) {
    switch (event) {
      case SppCode(:final code):
        deliver(code);
      case SppDisconnected():
        sppStatus.value = SppStatus.disconnected;
        _planRetry();
    }
  }

  /// Plus → Douchette: connect to [device] and remember it.
  Future<bool> connect(BtDevice device) async {
    await settings.set(_sppAddress, device.address);
    await settings.set(_sppName, device.name);
    return _connectRemembered();
  }

  Future<bool> _connectRemembered() async {
    final address = sppAddress;
    if (address == null) return false;
    _retry?.cancel();
    sppStatus.value = SppStatus.connecting;
    final ok = await spp.connect(address);
    if (sppAddress != address) return false; // forgotten meanwhile
    sppStatus.value = ok ? SppStatus.connected : SppStatus.disconnected;
    if (!ok) _planRetry();
    return ok;
  }

  /// The scanner was switched off or went too far: try again later.
  void _planRetry() {
    _retry?.cancel();
    if (sppAddress == null || !_started) return;
    _retry = Timer(retryEvery, () => unawaited(_connectRemembered()));
  }

  /// Plus → Douchette: forget the SPP scanner.
  Future<void> forget() async {
    _retry?.cancel();
    await settings.set(_sppAddress, null);
    await settings.set(_sppName, null);
    await spp.disconnect();
    sppStatus.value = SppStatus.none;
  }
}
