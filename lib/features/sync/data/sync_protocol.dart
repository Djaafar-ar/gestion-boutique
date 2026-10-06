import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'sync_store.dart';

/// The hub listens here for sync requests (TCP)...
const syncPort = 8787;

/// ...and here for "where is the hub?" questions (UDP broadcast).
const discoveryPort = 8788;

/// Rows sent per request, each way.
const syncPageSize = 500;

/// Signature of [body] with the shop secret: only phones that know the
/// secret (given by the pairing QR code) can talk to the hub, and only the
/// real hub can answer.
String signBody(String secret, String body) => base64Url
    .encode(Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(body)).bytes);

/// Compares in constant time, so the signature cannot be guessed byte by
/// byte.
bool checkSignature(String secret, String body, String? signature) {
  if (signature == null) return false;
  final expected = signBody(secret, body);
  if (expected.length != signature.length) return false;
  var diff = 0;
  for (var i = 0; i < expected.length; i++) {
    diff |= expected.codeUnitAt(i) ^ signature.codeUnitAt(i);
  }
  return diff == 0;
}

/// Why the hub refused a request.
enum SyncError {
  /// Wrong secret, or not this shop.
  badSignature,

  /// The phones run different versions of the app.
  version,

  /// This phone was removed from the shop (or never paired).
  unknownDevice,

  /// The hub could not be reached.
  unreachable,

  /// Anything else.
  other,
}

class SyncException implements Exception {
  final SyncError error;
  final String? detail;
  const SyncException(this.error, [this.detail]);

  @override
  String toString() => 'SyncException($error, $detail)';
}

List<Map<String, Object?>> encodeRows(List<SyncRow> rows) => [
      for (final row in rows) {'t': row.table, 'd': row.data}
    ];

List<SyncRow> decodeRows(Object? json) => [
      for (final item in (json as List? ?? const []).cast<Map>())
        (
          table: item['t'] as String,
          data: Map<String, Object?>.from(item['d'] as Map),
        ),
    ];

/// What the pairing QR code holds: where the hub is and the shop secret.
class PairingInfo {
  final String host;
  final int port;
  final String shopId;
  final String secret;
  final String shopName;

  const PairingInfo({
    required this.host,
    required this.port,
    required this.shopId,
    required this.secret,
    required this.shopName,
  });

  static const _marker = 'shop-sync';

  String encode() => jsonEncode({
        'app': _marker,
        'v': 1,
        'host': host,
        'port': port,
        'shop': shopId,
        'secret': secret,
        'name': shopName,
      });

  /// Null when [text] is not a pairing code of this app.
  static PairingInfo? decode(String text) {
    try {
      final json = jsonDecode(text);
      if (json is! Map || json['app'] != _marker || json['v'] != 1) {
        return null;
      }
      return PairingInfo(
        host: json['host'] as String,
        port: json['port'] as int,
        shopId: json['shop'] as String,
        secret: json['secret'] as String,
        shopName: json['name'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}
