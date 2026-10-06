import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Turns a PIN into a hash so the PIN itself is never stored.
///
/// A random [salt] per user means two people with the same PIN get
/// different hashes, and many rounds make guessing slower.
class PinHasher {
  static const _rounds = 10000;

  /// A new random salt (16 bytes as hex).
  static String newSalt() {
    final random = Random.secure();
    return List.generate(16, (_) => random.nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  static String hash(String pin, String salt) {
    final key = utf8.encode(salt);
    var digest = Hmac(sha256, key).convert(utf8.encode(pin)).bytes;
    for (var i = 1; i < _rounds; i++) {
      digest = Hmac(sha256, key).convert(digest).bytes;
    }
    return digest.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static bool verify(String pin, String salt, String expectedHash) {
    final actual = hash(pin, salt);
    // Compare every character so the time taken does not reveal anything.
    if (actual.length != expectedHash.length) return false;
    var difference = 0;
    for (var i = 0; i < actual.length; i++) {
      difference |= actual.codeUnitAt(i) ^ expectedHash.codeUnitAt(i);
    }
    return difference == 0;
  }

  /// A valid PIN is exactly 4 digits.
  static bool isValidPin(String pin) => RegExp(r'^\d{4}$').hasMatch(pin);
}
