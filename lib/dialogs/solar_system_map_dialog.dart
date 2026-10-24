import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/celestial_body_data.dart';
import '../services/audio_service.dart';
import '../theme/notion_theme.dart';

class SolarSystemMapDialog extends StatefulWidget {
  final Function(String missionId) onSelectMission;
  final VoidCallback onClose;

  const SolarSystemMapDialog({
    super.key,
    required this.onSelectMission,
    required this.onClose,
  });

  @override
  State<SolarSystemMapDialog> createState() => _SolarSystemMapDialogState();
}

class _SolarSystemMapDialogState extends State<SolarSystemMapDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  final List<CelestialBody> _bodies = CelestialBody.getBodies();
  late CelestialBody _selectedBody;

  final TransformationController _transformController = TransformationController();
  double _simSpeed = 1.0;
  bool _isPlaying = true;
  double _simTime = 0.0;
  DateTime _lastTick = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedBody = _bodies.firstWhere((b) => b.id == "earth");
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_onTick)
      ..repeat();
  }

  void _onTick() {
    final now = DateTime.now();
    final dt = now.difference(_lastTick).inMicroseconds / 1000000.0;
    _lastTick = now;

    if (_isPlaying) {
      setState(() {
        _simTime += dt * _simSpeed * 0.4;
      });
    }
  }

  @override
  void dispose() {
    _anim.removeListener(_onTick);
    _anim.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _recenterView() {
    AudioService.playZoom();
    _transformController.value = Matrix4.identity();
  }

  void _selectBody(CelestialBody body) {
    AudioService.playClick();
    setState(() => _selectedBody = body);
  }

  void _handleCanvasTap(Offset localPos, Size canvasSize) {
    // Convert tap position to canvas centered space
    final cx = canvasSize.width / 2;
    final cy = canvasSize.height / 2;

    CelestialBody? tappedBody;
    double minDistance = 28.0;

    for (final body in _bodies) {
      double bx = cx;
      double by = cy;

      if (body.orbitRadius > 0) {
        if (body.id == "moon") {
          final earth = _bodies.firstWhere((b) => b.id == "earth");
          final earthAngle = _simTime * earth.speed + (earth.orbitRadius * 0.05);
          final earthR = earth.orbitRadius * 0.44;
          final ex = cx + math.cos(earthAngle) * earthR;
          final ey = cy + math.sin(earthAngle) * earthR;
          final moonAngle = _simTime * 3.5;
          final moonR = 14.0;
          bx = ex + math.cos(moonAngle) * moonR;
          by = ey + math.sin(moonAngle) * moonR;
        } else {
          final angle = _simTime * body.speed + (body.orbitRadius * 0.05);
          final r = body.orbitRadius * 0.44;
          bx = cx + math.cos(angle) * r;
          by = cy + math.sin(angle) * r;
        }
      }

      final dist = (Offset(bx, by) - localPos).distance;
      if (dist < minDistance) {
        minDistance = dist;
        tappedBody = body;
      }
    }

    if (tappedBody != null) {
      _selectBody(tappedBody);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final isCompact = screen.height < 450;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: screen.width * 0.94,
          height: screen.height * 0.92,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF0C0E14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NotionTheme.borderMuted, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Tactical Header
              _buildHeader(),

              // Live 2D Simulator Work Area
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left: Live 2D Solar System Canvas & HUD Overlay
                    Expanded(
                      flex: 7,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final size = Size(constraints.maxWidth, constraints.maxHeight);
                                return InteractiveViewer(
                                  transformationController: _transformController,
                                  minScale: 0.4,
                                  maxScale: 3.5,
                                  boundaryMargin: const EdgeInsets.all(400),
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTapUp: (details) {
                                      _handleCanvasTap(details.localPosition, size);
                                    },
                                    child: CustomPaint(
                                      size: size,
                                      painter: _SolarSystemSimPainter(
                                        simTime: _simTime,
                                        bodies: _bodies,
                                        selectedBodyId: _selectedBody.id,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Top-Left Simulation Telemetry Badge
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xDD090F1D),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _isPlaying ? const Color(0xFF38BDF8) : Colors.amber,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "EPOCH T+${(_simTime * 365.25 / (math.pi * 2)).toStringAsFixed(1)} DAYS",
                                    style: const TextStyle(
                                      color: Color(0xFF38BDF8),
                                      fontSize: 9,
                                      fontFamily: NotionTheme.pixelFont,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Bottom Simulation Speed & Transport Controls
                          Positioned(
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: _buildTransportControls(),
                          ),
                        ],
                      ),
                    ),

                    // Vertical Divider
                    Container(width: 1, color: NotionTheme.borderMuted),

                    // Right: Planet Telemetry & Mission Directive Card
                    Expanded(
                      flex: 5,
                      child: _buildTelemetryPanel(isCompact),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        border: Border(bottom: BorderSide(color: NotionTheme.borderMuted)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.orbit, size: 16, color: Color(0xFF38BDF8)),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Text(
                  "SOLAR SYSTEM 2D ORBITAL SIMULATOR",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontFamily: NotionTheme.pixelFont,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.5,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Solar System Orbital Chart • Mission Directory",
                    style: TextStyle(
                      color: NotionTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              AudioService.playBack();
              widget.onClose();
            },
            icon: const Icon(LucideIcons.x, color: NotionTheme.textSecondary, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: "Close Orbital Map",
          ),
        ],
      ),
    );
  }

  Widget _buildTransportControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xEE090F1D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Play / Pause Toggle
            InkWell(
              onTap: () {
                AudioService.playClick();
                setState(() => _isPlaying = !_isPlaying);
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: _isPlaying
                      ? const Color(0xFF38BDF8).withValues(alpha: 0.2)
                      : Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: _isPlaying ? const Color(0xFF38BDF8) : Colors.amber,
                      width: 0.8),
                ),
                child: Icon(
                  _isPlaying ? LucideIcons.pause : LucideIcons.play,
                  size: 13,
                  color: _isPlaying ? const Color(0xFF38BDF8) : Colors.amber,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Speed Presets
            ...[0.5, 1.0, 2.5, 5.0].map((s) {
              final isSel = (_simSpeed == s);
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: InkWell(
                  onTap: () {
                    AudioService.playClick();
                    setState(() => _simSpeed = s);
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSel
                          ? const Color(0xFF38BDF8).withValues(alpha: 0.25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: isSel ? const Color(0xFF38BDF8) : Colors.white24,
                          width: 0.8),
                    ),
                    child: Text(
                      "${s}x",
                      style: TextStyle(
                        color: isSel ? const Color(0xFF38BDF8) : NotionTheme.textSecondary,
                        fontSize: 8.5,
                        fontFamily: NotionTheme.pixelFont,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(width: 8),

            // Reset View Button
            InkWell(
              onTap: _recenterView,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white24, width: 0.8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.focus, size: 11, color: Colors.white70),
                    SizedBox(width: 4),
                    Text(
                      "RECENTER",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 8,
                        fontFamily: NotionTheme.pixelFont,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryPanel(bool isCompact) {
    return Container(
      color: const Color(0xFF0F131D),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Planet Quick Selector Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _bodies.map((b) {
                  final isSel = b.id == _selectedBody.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: InkWell(
                      onTap: () => _selectBody(b),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSel ? b.color.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSel ? b.color : Colors.white12,
                            width: isSel ? 1.0 : 0.6,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(color: b.color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              b.name.split(" ").first.toUpperCase(),
                              style: TextStyle(
                                color: isSel ? Colors.white : NotionTheme.textSecondary,
                                fontSize: 8,
                                fontFamily: NotionTheme.pixelFont,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Scrollable Telemetry Body Details
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _selectedBody.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _selectedBody.color.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedBody.name.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              _selectedBody.tag,
                              style: TextStyle(
                                color: _selectedBody.color,
                                fontSize: 9.5,
                                fontFamily: NotionTheme.pixelFont,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          _selectedBody.distAU,
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 9,
                            fontFamily: NotionTheme.pixelFont,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Overview Description
                  Text(
                    _selectedBody.description,
                    style: const TextStyle(
                      color: NotionTheme.textSecondary,
                      fontSize: 10,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Live Telemetry Grid
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        _buildTelemetryRow("ORBITAL VELOCITY", _selectedBody.orbitalVelocity, LucideIcons.gauge),
                        _buildTelemetryRow("ORBITAL PERIOD", _selectedBody.orbitalPeriod, LucideIcons.clock),
                        _buildTelemetryRow("SURFACE GRAVITY", _selectedBody.surfaceGravity, LucideIcons.arrowDown),
                        _buildTelemetryRow("TEMPERATURE", _selectedBody.temperature, LucideIcons.thermometer),
                        _buildTelemetryRow("ATMOSPHERE", _selectedBody.atmosphere, LucideIcons.wind),
                        _buildTelemetryRow("NATURAL SATELLITES", _selectedBody.moonsCount, LucideIcons.moon),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Historical Probes & Missions
                  if (_selectedBody.historicalMissions.isNotEmpty) ...[
                    Text(
                      "HISTORICAL NASA PROBES & EXPLORATION",
                      style: TextStyle(
                        color: NotionTheme.textTertiary,
                        fontSize: 8.5,
                        fontFamily: NotionTheme.pixelFont,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: _selectedBody.historicalMissions.map((m) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3), width: 0.8),
                          ),
                          child: Text(
                            m,
                            style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Launch Mission Button (if linked to a level)
                  if (_selectedBody.missionId.isNotEmpty)
                    SizedBox(
                      height: 36,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          AudioService.playLaunch();
                          widget.onSelectMission(_selectedBody.missionId);
                          widget.onClose();
                        },
                        icon: const Icon(LucideIcons.rocket, size: 14),
                        label: Text(
                          _selectedBody.missionTitle.isNotEmpty
                              ? "LAUNCH ${_selectedBody.missionTitle}"
                              : "LAUNCH MISSION RECONSTRUCTION",
                          style: TextStyle(
                            fontFamily: NotionTheme.pixelFont,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: Colors.black,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Icon(icon, size: 10, color: NotionTheme.textTertiary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: NotionTheme.textTertiary,
              fontSize: 8,
              fontFamily: NotionTheme.pixelFont,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: NotionTheme.textPrimary,
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SolarSystemSimPainter extends CustomPainter {
  final double simTime;
  final List<CelestialBody> bodies;
  final String selectedBodyId;

  _SolarSystemSimPainter({
    required this.simTime,
    required this.bodies,
    required this.selectedBodyId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // 1. Draw Starfield
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.15);
    for (int i = 0; i < 90; i++) {
      final sx = (i * 73.1 + 17) % size.width;
      final sy = (i * 97.7 + 31) % size.height;
      final sr = ((i % 3) == 0) ? 1.2 : 0.6;
      canvas.drawCircle(Offset(sx, sy), sr, starPaint);
    }

    // 2. Draw Orbit Paths
    final orbitPaint = Paint()
      ..color = const Color(0x1A38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (final body in bodies) {
      if (body.orbitRadius > 0 && body.id != "moon") {
        final r = body.orbitRadius * 0.44;
        canvas.drawCircle(Offset(cx, cy), r, orbitPaint);
      }
    }

    // 3. Draw Asteroid Belt (Dynamic rotating specks between Mars & Jupiter)
    final asteroidPaint = Paint()..color = const Color(0x44A3E635);
    for (int i = 0; i < 90; i++) {
      final angle = (i * 0.07) + (simTime * 0.12);
      final dist = (194.0 + math.sin(i * 4.3) * 12.0) * 0.44;
      final ax = cx + math.cos(angle) * dist;
      final ay = cy + math.sin(angle) * dist;
      canvas.drawCircle(Offset(ax, ay), 0.9, asteroidPaint);
    }

    // Track Earth position for Moon's orbit
    double earthX = cx;
    double earthY = cy;

    // 4. Calculate positions for planets
    final Map<String, Offset> positions = {};

    for (final body in bodies) {
      if (body.isSun) {
        positions[body.id] = Offset(cx, cy);
      } else if (body.id != "moon") {
        final angle = simTime * body.speed + (body.orbitRadius * 0.05);
        final r = body.orbitRadius * 0.44;
        final bx = cx + math.cos(angle) * r;
        final by = cy + math.sin(angle) * r;
        positions[body.id] = Offset(bx, by);

        if (body.id == "earth") {
          earthX = bx;
          earthY = by;
        }
      }
    }

    // Calculate Moon around Earth
    final moonAngle = simTime * 3.5;
    final moonR = 14.0;
    positions["moon"] = Offset(
      earthX + math.cos(moonAngle) * moonR,
      earthY + math.sin(moonAngle) * moonR,
    );

    // Draw Moon's orbit around Earth
    final moonOrbitPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    canvas.drawCircle(Offset(earthX, earthY), moonR, moonOrbitPaint);

    // 5. Draw Celestial Bodies
    for (final body in bodies) {
      final pos = positions[body.id] ?? Offset(cx, cy);
      final isSelected = body.id == selectedBodyId;

      // Selection Reticle & Radius Line
      if (isSelected) {
        // Line from Sun to planet
        if (!body.isSun) {
          final rayPaint = Paint()
            ..color = body.color.withValues(alpha: 0.25)
            ..strokeWidth = 0.8
            ..style = PaintingStyle.stroke;
          canvas.drawLine(Offset(cx, cy), pos, rayPaint);
        }

        // Animated Pulse Reticle
        final haloPaint = Paint()
          ..color = body.color.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        canvas.drawCircle(pos, body.size * 0.7 + 6, haloPaint);

        // Corner Reticles
        final rSize = body.size * 0.7 + 9;
        final retPaint = Paint()
          ..color = const Color(0xFF38BDF8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        canvas.drawArc(
          Rect.fromCircle(center: pos, radius: rSize),
          -math.pi / 4,
          math.pi / 6,
          false,
          retPaint,
        );
        canvas.drawArc(
          Rect.fromCircle(center: pos, radius: rSize),
          3 * math.pi / 4,
          math.pi / 6,
          false,
          retPaint,
        );
      }

      // Sun Pulsing Glow
      if (body.isSun) {
        final coronaPaint = Paint()
          ..color = const Color(0x33FBBF24)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
        canvas.drawCircle(pos, body.size * 1.1, coronaPaint);

        final innerGlow = Paint()
          ..color = const Color(0x66F59E0B)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(pos, body.size * 0.8, innerGlow);
      }

      // Planet Sphere Body
      final bodyPaint = Paint()..color = body.color;
      canvas.drawCircle(pos, body.size * 0.5, bodyPaint);

      // Saturn Rings
      if (body.id == "saturn") {
        final ringPaint = Paint()
          ..color = const Color(0x99EAB308)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8;
        canvas.drawOval(
          Rect.fromCenter(
            center: pos,
            width: body.size * 2.2,
            height: body.size * 0.7,
          ),
          ringPaint,
        );

        final outerRingPaint = Paint()
          ..color = const Color(0x55FDE047)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawOval(
          Rect.fromCenter(
            center: pos,
            width: body.size * 2.7,
            height: body.size * 0.85,
          ),
          outerRingPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SolarSystemSimPainter oldDelegate) => true;
}
