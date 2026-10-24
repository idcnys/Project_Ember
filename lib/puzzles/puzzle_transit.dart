import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/audio_service.dart';
import '../theme/notion_theme.dart';

class PuzzleTransitWidget extends StatefulWidget {
  final String missionId;
  final Function(List<String> clueIds, String message) onSolved;

  const PuzzleTransitWidget({
    super.key,
    required this.missionId,
    required this.onSolved,
  });

  @override
  State<PuzzleTransitWidget> createState() => _PuzzleTransitWidgetState();
}

class _PuzzleTransitWidgetState extends State<PuzzleTransitWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  double _radius = 0.8;
  double _incline = 84.0;

  // Target: Kepler-452b (Radius ~1.6, Incline ~90)
  final double _targetRadius = 1.6;
  final double _targetIncline = 90.0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  double get _accuracy {
    final diffR = (_radius - _targetRadius).abs() / 3.0;
    final diffI = (_incline - _targetIncline).abs() / 15.0;
    final score = 1.0 - (diffR + diffI) / 2.0;
    return (score.clamp(0.0, 1.0) * 100).roundToDouble();
  }

  bool get _isConfirmed => _accuracy >= 85.0;

  void _confirmDiscovery() {
    if (_isConfirmed) {
      AudioService.playSuccess();
      final prefix = widget.missionId.replaceAll("mission-", "m");
      widget.onSolved(
        ["$prefix-c01", "$prefix-c02"],
        "EXOPLANET DISCOVERY CONFIRMED: Kepler-452b transit signature validated in stellar habitable zone!",
      );
    } else {
      AudioService.playAlert();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Science Guidance
        NotionTheme.callout(
          icon: LucideIcons.graduationCap,
          title: "STUDENT FIELD GUIDE",
          message:
              "An exoplanet blocking a star dips its brightness: ΔF/F = (Rp/R*)². Adjust Planet Radius to ~1.6 R⊕ and Inclination to ~90° to confirm Kepler-452b!",
          accentColor: NotionTheme.pastelPurple,
          bgColor: NotionTheme.pastelPurpleBg,
        ),
        const SizedBox(height: 10),

        // Transit Visualizer Canvas
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFF030712),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              return CustomPaint(
                painter: _TransitPainter(
                  time: _anim.value * math.pi * 2,
                  radius: _radius,
                  incline: _incline,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Dials
        Row(
          children: [
            Expanded(
              child: _buildDial(
                label: "PLANET RADIUS: ${_radius.toStringAsFixed(1)} R⊕",
                value: _radius,
                min: 0.5,
                max: 3.5,
                onChanged: (v) => setState(() => _radius = v),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDial(
                label: "INCLINATION: ${_incline.round()}°",
                value: _incline,
                min: 80.0,
                max: 100.0,
                onChanged: (v) => setState(() => _incline = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Action row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _isConfirmed
                    ? "LIGHT CURVE LOCKED: ${_accuracy.round()}%"
                    : "TRANSIT ALIGNMENT: ${_accuracy.round()}%",
                style: TextStyle(
                  color: _isConfirmed ? const Color(0xFF22C55E) : const Color(0xFF38BDF8),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _isConfirmed ? _confirmDiscovery : null,
              icon: const Icon(LucideIcons.checkCircle2, size: 14),
              label: const Text("CONFIRM EXOPLANET"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
                disabledForegroundColor: Colors.white.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDial({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 10,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            activeTrackColor: const Color(0xFF38BDF8),
            thumbColor: const Color(0xFF38BDF8),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: (v) {
              AudioService.playClick();
              onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}

class _TransitPainter extends CustomPainter {
  final double time;
  final double radius;
  final double incline;

  _TransitPainter({
    required this.time,
    required this.radius,
    required this.incline,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final starX = size.width / 2;
    final starY = 42.0;
    const starR = 24.0;

    // Star Body & Corona Glow
    final corona = Paint()
      ..color = const Color(0x55F59E0B)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(starX, starY), starR * 1.5, corona);

    final starPaint = Paint()..color = const Color(0xFFFEF08A);
    canvas.drawCircle(Offset(starX, starY), starR, starPaint);

    // Orbiting Planet
    const orbitW = 140.0;
    final planetX = starX + math.sin(time) * orbitW;
    final planetY = starY + (incline - 90.0) * 1.5;
    final planetR = radius * 3.5;

    final isBehind = math.cos(time) < 0;
    if (!isBehind) {
      final pPaint = Paint()..color = const Color(0xFF0F172A);
      canvas.drawCircle(Offset(planetX, planetY), planetR, pPaint);

      final pStroke = Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(Offset(planetX, planetY), planetR, pStroke);
    }

    // Light Curve Graph at bottom
    final graphY = size.height - 35.0;
    final graphPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final baselineY = graphY;
    final dipDepth = (radius * radius * 4.0).clamp(2.0, 24.0);
    final inTransit = (!isBehind && (planetX - starX).abs() < (starR + planetR));

    final curvePath = Path();
    for (double x = 10; x < size.width - 10; x += 4) {
      final distFromCenter = (x - starX).abs();
      double y = baselineY;
      if (distFromCenter < starR * 1.5) {
        y += dipDepth * math.exp(-(distFromCenter * distFromCenter) / (starR * starR));
      }
      if (x == 10) {
        curvePath.moveTo(x, y);
      } else {
        curvePath.lineTo(x, y);
      }
    }
    canvas.drawPath(curvePath, graphPaint);

    // Center indicator dot on graph
    final dotX = planetX.clamp(20.0, size.width - 20.0);
    double curY = baselineY;
    if (inTransit) {
      final distFromCenter = (dotX - starX).abs();
      curY += dipDepth * math.exp(-(distFromCenter * distFromCenter) / (starR * starR));
    }
    final dotPaint = Paint()..color = inTransit ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0);
    canvas.drawCircle(Offset(dotX, curY), 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _TransitPainter oldDelegate) => true;
}
