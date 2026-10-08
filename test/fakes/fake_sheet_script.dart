import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// The shop's Google Apps Script (tool/google_sheet/Code.gs) as the tests
/// see it: the same checks (signature, time, replays) and the same
/// answers, with the tabs kept in memory.
class FakeSheetScript {
  static const url = 'https://script.google.com/macros/s/TEST/exec';

  String writeKey;
  String readKey;
  DateTime Function() now;

  /// No internet: every request fails.
  bool offline = false;

  /// The script does the work, then the answer is lost (the phone's
  /// connection drops, or the app is killed at that moment). Once.
  bool loseNextAnswer = false;

  /// Answers like Google: a redirect, then the answer with a GET.
  bool redirect = false;

  /// Tabs by code (S, I, D, L, P, C): their rows as sent.
  final Map<String, List<List<Object?>>> tabs = {
    for (final code in ['S', 'I', 'D', 'L', 'P', 'C', 'H', 'R']) code: [],
  };
  final Map<String, Uint8List> backups = {};

  /// The owner's Gmail address.
  String email = 'boutique.elbaraka@gmail.com';

  /// Tabs only the read key may write.
  static const ownerOnly = {'C', 'R'};
  final List<Map<String, Object?>> requests = [];

  final _seen = <String>{};
  final _nonces = <String>{};
  final _redirected = <String, String>{};

  FakeSheetScript(
      {this.writeKey = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      this.readKey = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
      DateTime Function()? now})
      : now = now ?? DateTime.now;

  /// The configuration code shown in the sheet.
  String get code => jsonEncode(
      {'t': 'gb-sheet', 'v': 1, 'u': url, 'w': writeKey, 'r': readKey});

  http.Client get client => MockClient(_handle);

  /// Rows of a tab as the sheet shows them.
  List<List<Object?>> rows(String code) => tabs[code]!;

  Future<http.Response> _handle(http.Request request) async {
    if (offline) throw const SocketException('No internet');
    if (request.method == 'GET') {
      final answer = _redirected.remove(request.url.queryParameters['id']);
      if (answer == null) return http.Response('<html>Not found</html>', 404);
      return http.Response(answer, 200,
          headers: {'content-type': 'application/json; charset=utf-8'});
    }
    final envelope = jsonDecode(request.body) as Map<String, Object?>;
    final answer = jsonEncode(handle(envelope));
    if (loseNextAnswer) {
      loseNextAnswer = false;
      throw const SocketException('Connection lost');
    }
    if (redirect) {
      final id = '${_redirected.length + 1}';
      _redirected[id] = answer;
      return http.Response('', 302, headers: {
        'location': 'https://script.googleusercontent.com/macros/echo?id=$id'
      });
    }
    return http.Response(answer, 200,
        headers: {'content-type': 'application/json; charset=utf-8'});
  }

  /// What doPost answers.
  Map<String, Object?> handle(Map<String, Object?> req) {
    final keyId = req['k'];
    final key = keyId == 'r' ? readKey : (keyId == 'w' ? writeKey : null);
    if (key == null) return {'ok': false, 'err': 'setup'};
    final message = [
      req['v'],
      req['op'],
      req['ts'],
      req['n'],
      req['k'],
      req['b']
    ].join('\n');
    final signature =
        Hmac(sha256, utf8.encode(key)).convert(utf8.encode(message)).toString();
    if (signature != req['s']) return {'ok': false, 'err': 'sig'};
    final nowMs = now().millisecondsSinceEpoch;
    if ((nowMs - (req['ts'] as num)).abs() > 10 * 60 * 1000) {
      return {'ok': false, 'err': 'time', 'now': nowMs};
    }
    if (!_nonces.add('${req['n']}')) return {'ok': false, 'err': 'replay'};
    final body = jsonDecode(req['b'] as String) as Map<String, Object?>;
    final op = req['op'];
    requests.add({'op': op, 'k': keyId, 'body': body});
    if (const {'live', 'summary', 'backup'}.contains(op) && keyId != 'r') {
      return {'ok': false, 'err': 'sig'};
    }
    switch (op) {
      case 'ping':
        return {
          'ok': true,
          'name': 'Boutique test',
          'v': 2,
          if (keyId == 'r') 'email': email,
        };
      case 'push':
        for (final record in (body['r'] as List).cast<Map>()) {
          final upsert = record['u'] == 1;
          if (!upsert && !_seen.add('${record['k']}:${record['id']}')) {
            continue;
          }
          for (final MapEntry(key: code, value: rows)
              in (record['t'] as Map).entries) {
            // Debts and products: the read key only.
            if (ownerOnly.contains(code) && keyId != 'r') continue;
            for (final row in (rows as List).cast<List>()) {
              final tab = tabs[code]!;
              final at = upsert ? tab.indexWhere((r) => r[0] == row[0]) : -1;
              if (at >= 0) {
                tab[at] = row;
              } else {
                tab.add(row);
              }
            }
          }
        }
        return {'ok': true};
      case 'live':
        final sales = tabs['S']!;
        final last = sales.length + 1; // row number of the last row
        final cursor = body['c'];
        final fresh = !(cursor is int && cursor >= 1 && cursor <= last);
        final start = fresh ? 2 : cursor + 1;
        final out = <List<Object?>>[];
        for (var line = start; line <= last; line++) {
          final v = sales[line - 2];
          final day = dayText(v[1] as int);
          if (fresh && day != body['d']) continue;
          if (v[6] == 'Paiement client') continue;
          out.add([v[0], day, v[2], v[3], v[4], v[5], v[6], v[12]]);
        }
        return {'ok': true, 'c': last, 'r': out, 'm': false};
      case 'summary':
        final sums = {
          'sales': 0.0, 'revenue': 0.0, 'profit': 0.0, //
          'cash': 0.0, 'returns': 0.0, 'discounts': 0.0,
        };
        for (final v in tabs['S']!) {
          if (dayText(v[1] as int) != body['d']) continue;
          sums['sales'] = sums['sales']! + (v[9] as num);
          sums['discounts'] = sums['discounts']! + (v[11] as num);
          sums['revenue'] = sums['revenue']! + (v[12] as num);
          sums['profit'] = sums['profit']! + (v[13] as num);
          sums['returns'] = sums['returns']! + (v[14] as num);
          sums['cash'] = sums['cash']! + (v[15] as num);
        }
        return {'ok': true, ...sums};
      case 'backup':
        backups['${body['name']}'] = base64Decode(body['data'] as String);
        return {'ok': true, 'kept': backups.length};
    }
    return {'ok': false, 'err': 'op'};
  }

  /// Google Sheets day number to "yyyy-MM-dd".
  static String dayText(int serial) {
    final d = DateTime.utc(1899, 12, 30).add(Duration(days: serial));
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }
}
