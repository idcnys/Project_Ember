import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/celestial_body_data.dart';
import '../services/audio_service.dart';
import '../space/space_webview.dart';

class ShuttleFlightView extends StatefulWidget {
  final VoidCallback onExitFlight;

  const ShuttleFlightView({
    super.key,
    required this.onExitFlight,
  });

  @override
  State<ShuttleFlightView> createState() => _ShuttleFlightViewState();
}

class _ShuttleFlightViewState extends State<ShuttleFlightView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;

  // Flight Physics & State
  double _pitch = 0.0;
  double _yaw = 0.0;
  double _roll = 0.0;
  double _throttle = 0.8; // 80%
  bool _isWarping = false;

  // Camera Mode: 'chase', 'cockpit', 'orbit'
  String _camMode = 'chase';

  // Autopilot Nav
  String _navTargetName = "MARS";
  double _navDistanceKm = 14200.0;

  final List<CelestialBody> _destinations = CelestialBody.getBodies();

  // Starfield Particles for Fallback
  late final List<_StarParticle> _stars;

  @override
  void initState() {
    super.initState();
    _stars = List.generate(120, (_) => _StarParticle.random());
    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _ticker.addListener(_flightLoop);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _flightLoop() {
    final speed = _speed;
    for (var s in _stars) {
      s.z -= (_isWarping ? 18.0 : 4.0) * (_throttle + 0.2);
      if (s.z <= 0) {
        s.reset();
      }
    }

    _navDistanceKm = math.max(250.0, _navDistanceKm - (speed * 0.05));
    if (mounted) setState(() {});
  }

  double get _speed {
    final base = 25.0 * _throttle;
    return _isWarping ? base * 4.5 : base;
  }

  void _toggleWarp() {
    AudioService.playAlert();
    setState(() {
      _isWarping = !_isWarping;
    });
  }

  void _cycleCamera() {
    AudioService.playClick();
    setState(() {
      if (_camMode == 'chase') {
        _camMode = 'cockpit';
      } else if (_camMode == 'cockpit') {
        _camMode = 'orbit';
      } else {
        _camMode = 'chase';
      }
    });
  }

  void _selectAutopilot(CelestialBody body) {
    AudioService.playClick();
    setState(() {
      _navTargetName = body.name.split(" ").first.toUpperCase();
      _navDistanceKm = (body.orbitRadius * 1500.0) + 12000.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02040A),
      body: Stack(
        children: [
          // 1. EXACT 3D SPACE SHUTTLE ORBITER SIMULATION (FROM CONTEXT/)
          Positioned.fill(
            child: SpaceWebView(
              missionId: 'mission-10',
              mode: 'shuttle',
              fallback: CustomPaint(
                painter: _ShuttleSpacePainter(
                  stars: _stars,
                  pitch: _pitch,
                  yaw: _yaw,
                  roll: _roll,
                  throttle: _throttle,
                  isWarping: _isWarping,
                  camMode: _camMode,
                ),
              ),
            ),
          ),

          // 2. Cockpit Canopy Overlay (if in cockpit camera mode)
          if (_camMode == 'cockpit')
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _CockpitCanopyPainter()),
              ),
            ),

          // 3. TOP ORGANIZED FLIGHT HUD & TELEMETRY STRIP
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xDD090F1D),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.4), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      // Status Dot & Name
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "ORBITER // CRUISE",
                        style: TextStyle(
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.6,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Velocity Telemetry Readout
                      _buildTelemChip("VELOCITY", "${_speed.toStringAsFixed(1)} km/s"),
                      const SizedBox(width: 10),

                      // Throttle Meter
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTelemChip("THROTTLE", "${(_throttle * 100).round()}%"),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 60,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: _throttle,
                                minHeight: 4,
                                backgroundColor: Colors.white12,
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),

                      // Target Proximity
                      Flexible(
                        child: _buildTelemChip("NAV TARGET", "$_navTargetName (${_navDistanceKm.round()} km)"),
                      ),

                      const Spacer(),

                      // Warp Boost Pill Button
                      GestureDetector(
                        onTap: _toggleWarp,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isWarping ? const Color(0xFFF59E0B) : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _isWarping ? Colors.transparent : Colors.white24,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.zap,
                                size: 12,
                                color: _isWarping ? Colors.black : const Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isWarping ? "WARP ACTIVE" : "WARP",
                                style: TextStyle(
                                  color: _isWarping ? Colors.black : Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Camera Cycle Pill
                      GestureDetector(
                        onTap: _cycleCamera,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.camera, size: 12, color: Color(0xFF38BDF8)),
                              const SizedBox(width: 4),
                              Text(
                                _camMode.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Exit Flight Button
                      ElevatedButton.icon(
                        onPressed: () {
                          AudioService.playClick();
                          widget.onExitFlight();
                        },
                        icon: const Icon(LucideIcons.x, size: 12),
                        label: const Text("EXIT"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. AUTOPILOT DESTINATION NAV BAR (BOTTOM-CENTER)
          Positioned(
            bottom: 12,
            left: 100,
            right: 100,
            child: SafeArea(
              top: false,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xDD090F1D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.compass, color: Color(0xFF38BDF8), size: 12),
                      const SizedBox(width: 6),
                      const Text(
                        "AUTOPILOT:",
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _destinations.map((b) {
                              final name = b.name.split(" ").first.toUpperCase();
                              final isSelected = name == _navTargetName;
                              return GestureDetector(
                                onTap: () => _selectAutopilot(b),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 5),
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF38BDF8) : Colors.white.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      color: isSelected ? Colors.black : Colors.white70,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 5. FLIGHT ATTITUDE CONTROLS (BOTTOM-LEFT)
          Positioned(
            left: 14,
            bottom: 12,
            child: SafeArea(
              top: false,
              right: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFlightButton(LucideIcons.chevronUp, () => _pitch -= 0.12),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFlightButton(LucideIcons.chevronLeft, () {
                        _yaw -= 0.12;
                        _roll = -0.25;
                      }, () => _roll = 0.0),
                      const SizedBox(width: 32),
                      _buildFlightButton(LucideIcons.chevronRight, () {
                        _yaw += 0.12;
                        _roll = 0.25;
                      }, () => _roll = 0.0),
                    ],
                  ),
                  const SizedBox(height: 2),
                  _buildFlightButton(LucideIcons.chevronDown, () => _pitch += 0.12),
                ],
              ),
            ),
          ),

          // 6. THROTTLE LEVER (BOTTOM-RIGHT)
          Positioned(
            right: 14,
            bottom: 16,
            child: SafeArea(
              top: false,
              left: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFlightButton(
                    LucideIcons.plus,
                    () => setState(() => _throttle = math.min(1.0, _throttle + 0.1)),
                    null,
                    const Color(0xFF22C55E),
                  ),
                  const SizedBox(height: 10),
                  _buildFlightButton(
                    LucideIcons.minus,
                    () => setState(() => _throttle = math.max(0.1, _throttle - 0.1)),
                    null,
                    const Color(0xFFEF4444),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemChip(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$label: ",
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 9,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 9.5,
            fontFamily: 'monospace',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFlightButton(
    IconData icon,
    VoidCallback onPress, [
    VoidCallback? onRelease,
    Color color = const Color(0xFF38BDF8),
  ]) {
    return GestureDetector(
      onTapDown: (_) {
        AudioService.playClick();
        onPress();
      },
      onTapUp: (_) => onRelease?.call(),
      onTapCancel: () => onRelease?.call(),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xDD090F1D),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.6), width: 1.2),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _StarParticle {
  double x;
  double y;
  double z;

  _StarParticle(this.x, this.y, this.z);

  factory _StarParticle.random() {
    final rand = math.Random();
    return _StarParticle(
      (rand.nextDouble() - 0.5) * 800.0,
      (rand.nextDouble() - 0.5) * 600.0,
      rand.nextDouble() * 500.0 + 10.0,
    );
  }

  void reset() {
    final rand = math.Random();
    x = (rand.nextDouble() - 0.5) * 800.0;
    y = (rand.nextDouble() - 0.5) * 600.0;
    z = 500.0;
  }
}

class _ShuttleSpacePainter extends CustomPainter {
  final List<_StarParticle> stars;
  final double pitch;
  final double yaw;
  final double roll;
  final double throttle;
  final bool isWarping;
  final String camMode;

  _ShuttleSpacePainter({
    required this.stars,
    required this.pitch,
    required this.yaw,
    required this.roll,
    required this.throttle,
    required this.isWarping,
    required this.camMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final bgPaint = Paint()..color = const Color(0xFF02040A);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final fov = size.width * 0.7;
    final starPaint = Paint()..color = Colors.white;
    final warpPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 1.5;

    for (var s in stars) {
      if (s.z <= 0) continue;
      final k = fov / s.z;
      final px = cx + s.x * k;
      final py = cy + s.y * k;

      if (px >= 0 && px <= size.width && py >= 0 && py <= size.height) {
        if (isWarping) {
          final tailK = fov / (s.z + 25.0);
          final tailX = cx + s.x * tailK;
          final tailY = cy + s.y * tailK;
          canvas.drawLine(Offset(tailX, tailY), Offset(px, py), warpPaint);
        } else {
          final rad = math.max(0.6, (1.0 - s.z / 500.0) * 1.8);
          canvas.drawCircle(Offset(px, py), rad, starPaint);
        }
      }
    }

    if (camMode != 'cockpit') {
      canvas.save();
      canvas.translate(cx, cy + 25);
      canvas.rotate(roll);

      final bodyPaint = Paint()..color = const Color(0xFFF1F5F9);
      final blackTilePaint = Paint()..color = const Color(0xFF0F172A);
      final flamePaint = Paint()..color = const Color(0xFF38BDF8);

      final deltaWing = Path()
        ..moveTo(0, -45)
        ..lineTo(32, 25)
        ..lineTo(26, 28)
        ..lineTo(0, 24)
        ..lineTo(-26, 28)
        ..lineTo(-32, 25)
        ..close();
      canvas.drawPath(deltaWing, bodyPaint);

      final noseCap = Path()
        ..moveTo(0, -45)
        ..lineTo(8, -25)
        ..lineTo(-8, -25)
        ..close();
      canvas.drawPath(noseCap, blackTilePaint);

      final rudder = Path()
        ..moveTo(0, -10)
        ..lineTo(4, 20)
        ..lineTo(-4, 20)
        ..close();
      canvas.drawPath(rudder, Paint()..color = const Color(0xFFCBD5E1));

      final flameLength = (15.0 + math.Random().nextDouble() * 12.0) * throttle * (isWarping ? 2.5 : 1.0);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(-10, 26 + flameLength / 2), width: 6, height: flameLength),
        flamePaint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(10, 26 + flameLength / 2), width: 6, height: flameLength),
        flamePaint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(0, 28 + flameLength * 0.9 / 2), width: 7, height: flameLength * 0.9),
        flamePaint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ShuttleSpacePainter oldDelegate) => true;
}

class _CockpitCanopyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final framePaint = Paint()
      ..color = const Color(0xDD0B1220)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final leftStrut = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.28, size.height * 0.45)
      ..lineTo(size.width * 0.25, size.height * 0.45)
      ..lineTo(0, 20)
      ..close();
    canvas.drawPath(leftStrut, framePaint);
    canvas.drawPath(leftStrut, strokePaint);

    final rightStrut = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width * 0.72, size.height * 0.45)
      ..lineTo(size.width * 0.75, size.height * 0.45)
      ..lineTo(size.width, 20)
      ..close();
    canvas.drawPath(rightStrut, framePaint);
    canvas.drawPath(rightStrut, strokePaint);

    final hudReticle = Paint()
      ..color = const Color(0xFF22C55E).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 24, hudReticle);
    canvas.drawLine(
      Offset(size.width / 2 - 36, size.height / 2),
      Offset(size.width / 2 - 28, size.height / 2),
      hudReticle,
    );
    canvas.drawLine(
      Offset(size.width / 2 + 28, size.height / 2),
      Offset(size.width / 2 + 36, size.height / 2),
      hudReticle,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
