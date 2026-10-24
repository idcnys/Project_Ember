import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class SpaceWebServer {
  static SpaceWebServer? _instance;
  static SpaceWebServer get instance => _instance ??= SpaceWebServer._();

  SpaceWebServer._();

  HttpServer? _server;
  int? _port;
  bool _isStarting = false;

  int? get port => _port;
  bool get isRunning => _server != null && _port != null;

  Future<int> start() async {
    if (isRunning) return _port!;
    if (_isStarting) {
      while (_isStarting) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      if (isRunning) return _port!;
    }

    _isStarting = true;
    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      _port = _server!.port;

      _server!.listen(_handleRequest, onError: (err) {
        // Handle error silently
      });

      return _port!;
    } finally {
      _isStarting = false;
    }
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _port = null;
  }

  String getUrl({String mode = '3d', String mission = 'mission-01', String hud = 'flutter'}) {
    final p = _port ?? 0;
    return 'http://127.0.0.1:$p/?mode=$mode&mission=$mission&hud=$hud';
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final response = request.response;
    response.headers.add('Access-Control-Allow-Origin', '*');
    response.headers.add('Access-Control-Allow-Methods', 'GET, OPTIONS');
    response.headers.add('Access-Control-Allow-Headers', '*');

    if (request.method == 'OPTIONS') {
      response.statusCode = HttpStatus.ok;
      await response.close();
      return;
    }

    if (request.method != 'GET') {
      response.statusCode = HttpStatus.methodNotAllowed;
      await response.close();
      return;
    }

    var path = request.uri.path;
    if (path == '/' || path.isEmpty) {
      path = '/index.html';
    }
    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    // Strip any query strings
    if (path.contains('?')) {
      path = path.split('?').first;
    }

    final contentType = _getContentType(path);
    response.headers.contentType = contentType;
    response.headers.add('Cache-Control', 'public, max-age=3600');

    // 1. First attempt to read from local file system (fastest during development)
    final localFile = File('assets/web/$path');
    if (await localFile.exists()) {
      try {
        await response.addStream(localFile.openRead());
        await response.close();
        return;
      } catch (_) {}
    }

    // 2. Fallback to Flutter rootBundle (for Android release/device bundle)
    try {
      final assetKey = 'assets/web/$path';
      final byteData = await rootBundle.load(assetKey);
      final bytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
      response.headers.contentLength = bytes.length;
      response.add(bytes);
      await response.close();
    } catch (_) {
      // 3. Fallback to context/dist if available
      final distFile = File('context/dist/$path');
      if (await distFile.exists()) {
        try {
          await response.addStream(distFile.openRead());
          await response.close();
          return;
        } catch (_) {}
      }

      response.statusCode = HttpStatus.notFound;
      response.write('File not found: $path');
      await response.close();
    }
  }

  ContentType _getContentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.html')) return ContentType('text', 'html', charset: 'utf-8');
    if (lower.endsWith('.js')) return ContentType('application', 'javascript', charset: 'utf-8');
    if (lower.endsWith('.css')) return ContentType('text', 'css', charset: 'utf-8');
    if (lower.endsWith('.wasm')) return ContentType('application', 'wasm');
    if (lower.endsWith('.glb')) return ContentType('model', 'gltf-binary');
    if (lower.endsWith('.gltf')) return ContentType('model', 'gltf+json');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return ContentType('image', 'jpeg');
    if (lower.endsWith('.png')) return ContentType('image', 'png');
    if (lower.endsWith('.svg')) return ContentType('image', 'svg+xml');
    if (lower.endsWith('.mp4')) return ContentType('video', 'mp4');
    if (lower.endsWith('.json')) return ContentType('application', 'json');
    return ContentType.binary;
  }
}
