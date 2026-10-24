import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/space_web_server.dart';
import '../theme/notion_theme.dart';

typedef EmberBridgeCallback = void Function(String messageJson);

class SpaceWebView extends StatefulWidget {
  final String missionId;
  final String mode; // '3d' or 'shuttle'
  final Widget? fallback;
  final Function(WebViewController controller)? onControllerReady;
  final EmberBridgeCallback? onBridgeMessage;

  const SpaceWebView({
    super.key,
    required this.missionId,
    this.mode = '3d',
    this.fallback,
    this.onControllerReady,
    this.onBridgeMessage,
  });

  @override
  State<SpaceWebView> createState() => SpaceWebViewState();
}

class SpaceWebViewState extends State<SpaceWebView> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _activeMissionId = '';

  @override
  void initState() {
    super.initState();
    _activeMissionId = widget.missionId;
    _initWebView();
  }

  bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  Future<void> _initWebView() async {
    if (!_isSupportedPlatform) {
      if (mounted) setState(() => _hasError = true);
      return;
    }

    try {
      await SpaceWebServer.instance.start();
      final url = SpaceWebServer.instance.getUrl(
        mode: widget.mode,
        mission: _activeMissionId,
        hud: 'flutter',
      );

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFF02040A))
        ..addJavaScriptChannel(
          'EmberBridge',
          onMessageReceived: (JavaScriptMessage message) {
            widget.onBridgeMessage?.call(message.message);
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (_) {
              if (mounted) {
                setState(() => _isLoading = false);
                _syncMission();
              }
            },
            onWebResourceError: (error) {
              debugPrint('WebView resource error: ${error.description}');
            },
          ),
        )
        ..loadRequest(Uri.parse(url));

      if (mounted) {
        setState(() {
          _controller = controller;
        });
        widget.onControllerReady?.call(controller);
      }
    } catch (e) {
      debugPrint('WebView init error: $e');
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void didUpdateWidget(covariant SpaceWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.missionId != widget.missionId || oldWidget.mode != widget.mode) {
      _activeMissionId = widget.missionId;
      _syncMission();
    }
  }

  void _syncMission() {
    if (_controller == null || _isLoading) return;
    if (widget.mode == 'shuttle') {
      _controller?.runJavaScript("if (window.mohasunno) window.mohasunno.launchShuttle();");
    } else {
      _controller?.runJavaScript("if (window.mohasunno) window.mohasunno.launchMission('$_activeMissionId');");
    }
  }

  void switchMission(String missionId) {
    _activeMissionId = missionId;
    _syncMission();
  }

  void switchCameraPerspective(String perspective) {
    _controller?.runJavaScript("if (window.mohasunno) window.mohasunno.setPerspective('$perspective');");
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || !_isSupportedPlatform || _controller == null) {
      return widget.fallback ??
          Container(
            color: const Color(0xFF02040A),
            child: Center(
              child: NotionTheme.subtleLoader(
                label: "INITIALIZING 3D ENVIRONMENT...",
              ),
            ),
          );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: WebViewWidget(controller: _controller!),
        ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF02040A),
              child: Center(
                child: NotionTheme.subtleLoader(
                  label: "CONNECTING 3D TELEMETRY SENSORS...",
                  size: 24.0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
