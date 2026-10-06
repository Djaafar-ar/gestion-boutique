import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'hub_service.dart';
import 'sync_protocol.dart';

/// Sends one signed message to the hub and returns its (checked) answer.
abstract class SyncTransport {
  Future<Map<String, Object?>> send(
      {required String host,
      required int port,
      required String secret,
      required Map<String, Object?> message});
}

/// Turns the hub's "ok: false" answers into [SyncException]s.
Map<String, Object?> checkAnswer(Map<String, Object?> answer) {
  if (answer['ok'] == true) return answer;
  throw SyncException(
      SyncError.values.asNameMap()[answer['error']] ?? SyncError.other);
}

/// Talks to the hub over the local Wi-Fi (HTTP).
class HttpSyncTransport implements SyncTransport {
  final Duration timeout;
  const HttpSyncTransport({this.timeout = const Duration(seconds: 8)});

  @override
  Future<Map<String, Object?>> send(
      {required String host,
      required int port,
      required String secret,
      required Map<String, Object?> message}) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final body = jsonEncode(message);
      final request = await client.post(host, port, '/sync').timeout(timeout);
      request.headers
        ..contentType = ContentType.json
        ..set('x-signature', signBody(secret, body));
      request.add(utf8.encode(body));
      final response = await request.close().timeout(timeout * 4);
      final text = await utf8.decodeStream(response).timeout(timeout * 4);
      if (response.statusCode == HttpStatus.unauthorized) {
        throw const SyncException(SyncError.badSignature);
      }
      // Only the real hub knows the secret to sign its answer.
      if (!checkSignature(
          secret, text, response.headers.value('x-signature'))) {
        throw const SyncException(SyncError.badSignature);
      }
      return checkAnswer(Map<String, Object?>.from(jsonDecode(text) as Map));
    } on SyncException {
      rethrow;
    } on SocketException catch (e) {
      throw SyncException(SyncError.unreachable, e.message);
    } on TimeoutException {
      throw const SyncException(SyncError.unreachable, 'timeout');
    } on HttpException catch (e) {
      throw SyncException(SyncError.unreachable, e.message);
    } finally {
      client.close(force: true);
    }
  }
}

/// The hub's server on the owner's phone: sync requests over HTTP, and
/// answers to "where is the hub?" over UDP.
class HubServer {
  final HubService hub;
  HttpServer? _http;
  RawDatagramSocket? _udp;

  HubServer(this.hub);

  bool get running => _http != null;
  int? get port => _http?.port;

  /// Where "where is the hub?" questions are answered.
  int? get discoveryPortInUse => _udp?.port;

  Future<void> start(
      {int port = syncPort, int? discovery = discoveryPort}) async {
    if (running) return;
    final http = await HttpServer.bind(InternetAddress.anyIPv4, port);
    _http = http;
    http.listen(_handle, onError: (Object e) => debugPrint('Hub: $e'));
    if (discovery != null) {
      try {
        final udp = await RawDatagramSocket.bind(
            InternetAddress.anyIPv4, discovery,
            reuseAddress: true);
        _udp = udp;
        udp.listen((event) {
          if (event == RawSocketEvent.read) _answerDiscovery(udp);
        });
      } catch (e) {
        // Pairing by QR code still works without it.
        debugPrint('Hub discovery unavailable: $e');
      }
    }
  }

  Future<void> stop() async {
    await _http?.close(force: true);
    _http = null;
    _udp?.close();
    _udp = null;
  }

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    try {
      final keys = await hub.shop();
      final body = await utf8.decodeStream(request);
      if (request.method != 'POST' ||
          request.uri.path != '/sync' ||
          keys == null ||
          !checkSignature(
              keys.secret, body, request.headers.value('x-signature'))) {
        response.statusCode = HttpStatus.unauthorized;
        await response.close();
        return;
      }
      final answer = jsonEncode(
          await hub.handle(Map<String, Object?>.from(jsonDecode(body) as Map)));
      response.headers
        ..contentType = ContentType.json
        ..set('x-signature', signBody(keys.secret, answer));
      response.add(utf8.encode(answer));
      await response.close();
    } catch (e) {
      debugPrint('Hub request failed: $e');
      try {
        response.statusCode = HttpStatus.internalServerError;
        await response.close();
      } catch (_) {}
    }
  }

  Future<void> _answerDiscovery(RawDatagramSocket udp) async {
    final datagram = udp.receive();
    if (datagram == null) return;
    try {
      final question = jsonDecode(utf8.decode(datagram.data)) as Map;
      final keys = await hub.shop();
      if (question['q'] != 'hub' ||
          keys == null ||
          question['shop'] != keys.id) {
        return;
      }
      final nonce = '${question['nonce']}';
      final answer = jsonEncode({
        'shop': keys.id,
        'port': port,
        'nonce': nonce,
        'sig': signBody(keys.secret, '${keys.id}|$port|$nonce'),
      });
      udp.send(utf8.encode(answer), datagram.address, datagram.port);
    } catch (_) {
      // Not for us.
    }
  }
}

/// Finds the hub on the Wi-Fi when its address changed (routers give new
/// addresses): asks everyone "where is the hub of this shop?" and trusts
/// only an answer signed with the shop secret.
class HubFinder {
  /// Where to ask; the whole local network by default.
  final InternetAddress target;
  final int port;

  HubFinder({InternetAddress? target, this.port = discoveryPort})
      : target = target ?? InternetAddress('255.255.255.255');

  Future<({String host, int port})?> find(
      {required String shopId,
      required String secret,
      Duration timeout = const Duration(seconds: 3)}) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
      ..broadcastEnabled = true;
    final nonce = '${Random.secure().nextInt(1 << 32)}';
    final found = Completer<({String host, int port})?>();
    socket.listen((event) {
      if (event != RawSocketEvent.read || found.isCompleted) return;
      final datagram = socket.receive();
      if (datagram == null) return;
      try {
        final answer = jsonDecode(utf8.decode(datagram.data)) as Map;
        final hubPort = answer['port'] as int;
        if (answer['shop'] == shopId &&
            answer['nonce'] == nonce &&
            checkSignature(
                secret, '$shopId|$hubPort|$nonce', answer['sig'] as String?)) {
          found.complete((host: datagram.address.address, port: hubPort));
        }
      } catch (_) {}
    });
    socket.send(
        utf8.encode(jsonEncode({'q': 'hub', 'shop': shopId, 'nonce': nonce})),
        target,
        port);
    try {
      return await found.future.timeout(timeout, onTimeout: () => null);
    } finally {
      socket.close();
    }
  }
}

/// This phone's address on the Wi-Fi (for the pairing QR code).
Future<String?> localWifiAddress() async {
  final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4, includeLoopback: false);
  bool private(String ip) =>
      ip.startsWith('192.168.') ||
      ip.startsWith('10.') ||
      RegExp(r'^172\.(1[6-9]|2\d|3[01])\.').hasMatch(ip);
  // The Wi-Fi first (wlan), then any local network address.
  interfaces.sort((a, b) => (b.name.startsWith('wlan') ? 1 : 0)
      .compareTo(a.name.startsWith('wlan') ? 1 : 0));
  for (final interface in interfaces) {
    for (final address in interface.addresses) {
      if (private(address.address)) return address.address;
    }
  }
  return null;
}

/// Calls [HubService] directly, as if over the network (used by tests).
class DirectTransport implements SyncTransport {
  final HubService hub;
  DirectTransport(this.hub);

  @override
  Future<Map<String, Object?>> send(
      {required String host,
      required int port,
      required String secret,
      required Map<String, Object?> message}) async {
    final keys = await hub.shop();
    if (keys == null || keys.secret != secret) {
      throw const SyncException(SyncError.badSignature);
    }
    // Through JSON both ways, like the real thing.
    final answer = await hub.handle(
        Map<String, Object?>.from(jsonDecode(jsonEncode(message)) as Map));
    return checkAnswer(
        Map<String, Object?>.from(jsonDecode(jsonEncode(answer)) as Map));
  }
}
