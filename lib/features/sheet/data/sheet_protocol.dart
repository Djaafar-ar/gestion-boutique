import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Version of the messages understood by the Google Apps Script
/// (tool/google_sheet/Code.gs).
const sheetProtocolVersion = 1;

/// What the owner scans in the sheet (menu Boutique → "Afficher le code de
/// configuration"): the script address and its two keys.
class SheetConfig {
  final String url;

  /// Lets a phone add records. Every phone of the shop has it.
  final String writeKey;

  /// Lets a phone read the shop's figures (live sales, daily report) and
  /// save backups. Only on the owner's phone; null on the others.
  final String? readKey;

  const SheetConfig({required this.url, required this.writeKey, this.readKey});

  static final _key = RegExp(r'^[0-9a-f]{32,128}$');

  /// Only Google's script addresses are accepted, so a wrong code can
  /// never send the shop's data somewhere else.
  static bool isScriptUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host == 'script.google.com' &&
        uri.path.endsWith('/exec');
  }

  /// Reads a scanned (or pasted) code, or returns null when it is not a
  /// configuration code of the shop's sheet.
  static SheetConfig? decode(String text) {
    try {
      final data = jsonDecode(text.trim());
      if (data is! Map || data['t'] != 'gb-sheet') return null;
      final url = data['u'], write = data['w'], read = data['r'];
      if (url is! String || !isScriptUrl(url)) return null;
      if (write is! String || !_key.hasMatch(write)) return null;
      if (read != null && (read is! String || !_key.hasMatch(read))) {
        return null;
      }
      return SheetConfig(url: url, writeKey: write, readKey: read as String?);
    } catch (_) {
      return null;
    }
  }

  String encode() => jsonEncode({
        't': 'gb-sheet',
        'v': sheetProtocolVersion,
        'u': url,
        'w': writeKey,
        if (readKey != null) 'r': readKey,
      });
}

/// The text signed with a key: the script rebuilds it and checks the
/// signature.
String sheetMessage(
        {required String op,
        required int ts,
        required String nonce,
        required String keyId,
        required String body}) =>
    [sheetProtocolVersion, op, ts, nonce, keyId, body].join('\n');

/// HMAC-SHA256 of [message] with [key], as hex.
String sheetSignature(String key, String message) =>
    Hmac(sha256, utf8.encode(key)).convert(utf8.encode(message)).toString();

/// Google Sheets counts days from 30/12/1899. Sending the day as this
/// number (not as a date and time) keeps it right whatever the time zone.
int sheetDay(DateTime date) => DateTime.utc(date.year, date.month, date.day)
    .difference(DateTime.utc(1899, 12, 30))
    .inDays;

/// "2026-10-07": how the script names a day.
String sheetDayText(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// Centimes as dinars for a sheet cell (1250 -> 12.5).
num sheetMoney(int centimes) =>
    centimes % 100 == 0 ? centimes ~/ 100 : centimes / 100;

/// Dinars read from the sheet back to centimes.
int centimesFromSheet(Object? value) =>
    value is num ? (value * 100).round() : 0;
