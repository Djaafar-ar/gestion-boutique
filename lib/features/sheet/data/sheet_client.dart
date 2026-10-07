import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../../../core/settings/settings_store.dart';
import 'sheet_protocol.dart';
import 'sheet_settings.dart';

/// Why talking to the Google Sheet failed.
enum SheetError {
  /// No sheet set up on this phone.
  notConfigured,

  /// No internet (or Google did not answer): try again later.
  offline,

  /// The script is not reachable as "Anyone" (deployment settings).
  access,

  /// Wrong key: the keys were changed in the sheet.
  signature,

  /// Something else went wrong in the script.
  server,
}

class SheetException implements Exception {
  final SheetError error;
  final String? detail;
  const SheetException(this.error, [this.detail]);

  @override
  String toString() => 'SheetException(${error.name}, $detail)';
}

/// Sends one signed request to the shop's Google Apps Script.
class SheetClient {
  final http.Client http_;
  final SettingsStore settings;
  final DateTime Function() clock;
  final Random _random = Random.secure();

  SheetClient(this.http_, this.settings, {DateTime Function()? clock})
      : clock = clock ?? DateTime.now;

  /// Calls [op] of the script with [body], signed with [key] (keyId 'w'
  /// for the write key, 'r' for the read key). Returns the answer.
  Future<Map<String, Object?>> call(
    String url, {
    required String key,
    required String keyId,
    required String op,
    required Object? body,
    Duration timeout = const Duration(seconds: 45),
  }) async {
    final text = jsonEncode(body);
    for (var attempt = 0;; attempt++) {
      final ts = clock().millisecondsSinceEpoch + settings.sheetClockOffset;
      final nonce = List.generate(
              16, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'))
          .join();
      final message = sheetMessage(
          op: op, ts: ts, nonce: nonce, keyId: keyId, body: text);
      final envelope = jsonEncode({
        'v': sheetProtocolVersion,
        'op': op,
        'ts': ts,
        'n': nonce,
        'k': keyId,
        'b': text,
        's': sheetSignature(key, message),
      });
      final answer = await _post(url, envelope, timeout);
      if (answer['ok'] == true) return answer;
      switch (answer['err']) {
        // This phone's clock is wrong: remember the difference, try again.
        case 'time' when attempt == 0 && answer['now'] is num:
          final offset = (answer['now'] as num).toInt() -
              clock().millisecondsSinceEpoch;
          await settings.set(SheetSettings.clockOffsetName, '$offset');
          continue;
        case 'sig' || 'setup':
          throw const SheetException(SheetError.signature);
        default:
          throw SheetException(SheetError.server, '${answer['msg'] ?? answer['err']}');
      }
    }
  }

  /// Google answers a POST with a redirect to the result, which is then
  /// fetched with a GET.
  Future<Map<String, Object?>> _post(
      String url, String envelope, Duration timeout) async {
    try {
      final request = http.Request('POST', Uri.parse(url))
        ..followRedirects = false
        ..headers['content-type'] = 'text/plain; charset=utf-8'
        ..body = envelope;
      var response = await http.Response.fromStream(
              await http_.send(request).timeout(timeout))
          .timeout(timeout);
      if (response.isRedirect || (response.statusCode ~/ 100 == 3)) {
        final location = response.headers['location'];
        if (location == null) throw const SheetException(SheetError.server);
        response = await http_.get(Uri.parse(location)).timeout(timeout);
      }
      final text = utf8.decode(response.bodyBytes, allowMalformed: true);
      if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          text.trimLeft().startsWith('<')) {
        // A Google sign-in or error page instead of the script's answer.
        throw SheetException(SheetError.access, '${response.statusCode}');
      }
      if (response.statusCode != 200) {
        throw SheetException(SheetError.server, '${response.statusCode}');
      }
      final data = jsonDecode(text);
      if (data is! Map) throw const SheetException(SheetError.server);
      return Map<String, Object?>.from(data);
    } on SheetException {
      rethrow;
    } on SocketException catch (e) {
      throw SheetException(SheetError.offline, e.message);
    } on TimeoutException {
      throw const SheetException(SheetError.offline, 'timeout');
    } on http.ClientException catch (e) {
      throw SheetException(SheetError.offline, e.message);
    } on HandshakeException catch (e) {
      throw SheetException(SheetError.offline, e.message);
    } on FormatException catch (e) {
      throw SheetException(SheetError.server, e.message);
    }
  }
}
