import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/audio_service.dart';
import '../theme/notion_theme.dart';

/// High-tech sci-fi splash screen featuring the official app logo,
/// animated telemetry progress loaders, and initialization sequencing.
class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;
  final Duration duration;

  const SplashScreen({
    super.key,
    required this.onFinish,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;
  late final AnimationController _progressController;

  late final Animation<double> _pulseAnimation;
  late final Animation<double> _fadeAnimation;

  Timer? _statusTimer;
  int _statusIndex = 0;
  bool _isFinished = false;

  static const List<String> _loadingStatuses = [
    "INITIALIZING QUANTUM TELEMETRY INTERFACE...",
    "VERIFYING NASA ARCHIVAL 3D HARDWARE SCHEMATICS...",
    "SYNCHRONIZING DUAL-CHANNEL AUDIO CORE & SFX...",
    "DECRYPTING UNIT ECHO INVESTIGATION DOSSIERS...",
    "ESTABLISHING SECURE TEMPORAL LINK (2027-2047)...",
    "SYSTEM CHECK OPTIMAL // LAUNCHING HUD...",
  ];

  @override
  void initState() {
    super.initState();

    // Pulse animation for the central logo glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Continuous rotation for HUD loader icon
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Progress animation over duration
    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _progressController,
      curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
    );

    _progressController.addListener(() {
      setState(() {
        final progress = _progressController.value;
        final newIndex = (progress * (_loadingStatuses.length - 1)).floor();
        if (newIndex != _statusIndex && newIndex < _loadingStatuses.length) {
          _statusIndex = newIndex;
        }
      });
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _completeAndProceed();
      }
    });

    // Start initialization sequence
    _startInitialization();
  }

  void _startInitialization() async {
    // Warm up image assets
    try {
      if (mounted) {
        precacheImage(const AssetImage('assets/images/app_logo.png'), context);
      }
    } catch (_) {}

    if (widget.duration == Duration.zero) {
      _completeAndProceed();
    } else {
      _progressController.forward();
    }
  }

  void _completeAndProceed() {
    if (_isFinished) return;
    _isFinished = true;
    widget.onFinish();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _pulseController.dispose();
    _rotateController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progressController.value;
    final percent = (progress * 100).clamp(0, 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // Allow investigator to tap to skip into main menu
          AudioService.playClick();
          _completeAndProceed();
        },
        child: Stack(
          children: [
            // 1. Deep Space Radial Gradient Background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, -0.2),
                    radius: 1.1,
                    colors: [
                      Color(0xFF131D31),
                      Color(0xFF090D18),
                      Color(0xFF04060B),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Subtle Tech Grid Pattern & Scanlines
            Positioned.fill(
              child: CustomPaint(
                painter: _SciFiGridPainter(),
              ),
            ),

            // 3. Central Splash Content
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 580),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // App Logo with Animated Glow Ring
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                                    blurRadius: 36,
                                    spreadRadius: 4,
                                  ),
                                  BoxShadow(
                                    color: NotionTheme.pastelAmber.withValues(alpha: 0.25),
                                    blurRadius: 20,
                                    spreadRadius: -4,
                                  ),
                                ],
                                border: Border.all(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.8),
                                  width: 2.5,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/app_logo.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) {
                                    return const Center(
                                      child: Icon(
                                        LucideIcons.rocket,
                                        size: 48,
                                        color: Color(0xFF38BDF8),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Game Title: EMBER
                          const Text(
                            "EMBER",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4.0,
                              fontFamily: NotionTheme.pixelFont,
                              shadows: [
                                Shadow(
                                  color: Color(0xFF38BDF8),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Subtitle & Tagline
                          const Text(
                            "THE SPACE SCIENCE INVESTIGATION",
                            style: TextStyle(
                              color: NotionTheme.textSecondary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              fontFamily: NotionTheme.pixelFont,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // NASA Space Apps Challenge Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.rocket, size: 12, color: Color(0xFF38BDF8)),
                                SizedBox(width: 6),
                                Text(
                                  "NASA SPACE APPS CHALLENGE 2026",
                                  style: TextStyle(
                                    color: Color(0xFF38BDF8),
                                    fontSize: 8.5,
                                    fontFamily: NotionTheme.pixelFont,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // High-Tech Telemetry Progress Loader Bar
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C1322),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Progress Bar HUD Header: Icon, Status, and %
                                Row(
                                  children: [
                                    RotationTransition(
                                      turns: _rotateController,
                                      child: const Icon(
                                        LucideIcons.loader2,
                                        size: 14,
                                        color: Color(0xFF38BDF8),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _loadingStatuses[_statusIndex],
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 9,
                                          fontFamily: NotionTheme.pixelFont,
                                          letterSpacing: 0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "[ $percent% ]",
                                      style: TextStyle(
                                        color: percent >= 100
                                            ? const Color(0xFF22C55E)
                                            : const Color(0xFF38BDF8),
                                        fontSize: 9.5,
                                        fontFamily: NotionTheme.pixelFont,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Styled Custom Progress Rail
                                Stack(
                                  children: [
                                    Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: progress.clamp(0.0, 1.0),
                                      child: Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(3),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF38BDF8),
                                              Color(0xFF60A5FA),
                                              Color(0xFFFBBF24),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Prompt to skip/continue
                          Text(
                            percent >= 100 ? "READY // TAP ANYWHERE TO COMMENCE" : "INITIALIZING ARCHIVES • TAP TO SKIP",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 8.5,
                              fontFamily: NotionTheme.pixelFont,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom subtle sci-fi grid lines painter for the splash screen
class _SciFiGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.035)
      ..strokeWidth = 1.0;

    const spacing = 48.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
