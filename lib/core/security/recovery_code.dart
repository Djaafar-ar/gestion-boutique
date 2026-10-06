import 'dart:math';

/// The owner's one-time recovery code, like `K7QM-3WZD-HP9X`.
///
/// 12 characters from 32 easy-to-read letters and digits (no 0/O or 1/I
/// to avoid mistakes) give about 60 bits: impossible to guess.
class RecoveryCode {
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const _length = 12;

  static String generate() {
    final random = Random.secure();
    final chars = List.generate(
        _length, (_) => _alphabet[random.nextInt(_alphabet.length)]);
    return [
      for (var i = 0; i < _length; i += 4) chars.sublist(i, i + 4).join(),
    ].join('-');
  }

  /// Makes typed text comparable: upper case, without spaces or dashes,
  /// so "k7qm 3wzd-hp9x" matches "K7QM-3WZD-HP9X".
  static String normalize(String typed) =>
      typed.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
}
