import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/audio_service.dart';
import '../theme/notion_theme.dart';

class PuzzleAerodynamicsWidget extends StatefulWidget {
  final String missionId;
  final Function(List<String> clueIds, String message) onSolved;

  const PuzzleAerodynamicsWidget({
    super.key,
    required this.missionId,
    required this.onSolved,
  });

  @override
  State<PuzzleAerodynamicsWidget> createState() => _PuzzleAerodynamicsWidgetState();
}

class _PuzzleAerodynamicsWidgetState extends State<PuzzleAerodynamicsWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  double _rpm = 1200.0;
  double _bladePitch = 5.0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  // Lift = 0.5 * rho * v^2 * S * Cl
  // In 1% Earth air density: rho ~ 0.015 kg/m^3
  double get _generatedLift {
    final speed = (_rpm / 60.0) * 2 * math.pi * 0.6;
    final cl = math.sin(_bladePitch * math.pi / 180.0) * 1.8;
    return 0.5 * 0.015 * speed * speed * 0.2 * cl * 10.0;
  }

  // Mars gravity weight: 1.8 kg * 3.71 m/s^2 = 6.68 N
  final double _requiredLift = 6.68;

  bool get _canFly => _generatedLift >= _requiredLift;

  void _testFlight() {
    if (_canFly) {
      AudioService.playSuccess();
      final prefix = widget.missionId.replaceAll("mission-", "m");
      widget.onSolved(
        ["$prefix-c02", "$prefix-c05"],
        "AERODYNAMICS VALIDATED: Lift of ${_generatedLift.toStringAsFixed(2)} N exceeds Martian gravity (6.68 N)! Ingenuity achieves stable hovering flight in 1% atmosphere!",
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
              "Mars air is only 1% Earth density. To generate 6.7 N lift, spin carbon-fiber counter-rotating rotors past 2,400 RPM and set blade pitch to ~11°!",
          accentColor: NotionTheme.pastelTeal,
          bgColor: NotionTheme.pastelTealBg,
        ),
        const SizedBox(height: 10),

        // Rotor Aerodynamics Canvas
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
                painter: _MarsHelicopterPainter(
                  rotation: _anim.value * (_rpm / 60.0) * math.pi * 2,
                  altitude: (_generatedLift / _requiredLift).clamp(0.0, 1.4),
                  canFly: _canFly,
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
                label: "ROTOR RPM: ${_rpm.round()} RPM",
                value: _rpm,
                min: 500.0,
                max: 2800.0,
                onChanged: (v) => setState(() => _rpm = v),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDial(
                label: "BLADE PITCH: ${_bladePitch.toStringAsFixed(1)}°",
                value: _bladePitch,
                min: 1.0,
                max: 18.0,
                onChanged: (v) => setState(() => _bladePitch = v),
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
                _canFly
                    ? "AERODYNAMIC LIFT: ${_generatedLift.toStringAsFixed(2)} N (TAKEOFF READY!)"
                    : "AERODYNAMIC LIFT: ${_generatedLift.toStringAsFixed(2)} N / 6.68 N",
                style: TextStyle(
                  color: _canFly ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
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
              onPressed: _canFly ? _testFlight : null,
              icon: const Icon(LucideIcons.wind, size: 14),
              label: const Text("INITIATE FLIGHT TEST"),
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

class _MarsHelicopterPainter extends CustomPainter {
  final double rotation;
  final double altitude;
  final bool canFly;

  _MarsHelicopterPainter({
    required this.rotation,
    required this.altitude,
    required this.canFly,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    // Base Y: ground at 100
    final groundY = size.height - 25.0;
    final heliY = groundY - 20.0 - (altitude * 35.0);

    // Draw Martian Red Surface
    final groundPaint = Paint()..color = const Color(0xFF991B1B);
    canvas.drawRect(Rect.fromLTWH(0, groundY, size.width, size.height - groundY), groundPaint);

    // Helicopter Chassis (Golden cube)
    final bodyPaint = Paint()..color = const Color(0xFFFBBF24);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, heliY), width: 16, height: 16), bodyPaint);

    // Solar Panel on top
    final panelPaint = Paint()..color = const Color(0xFF1E3A8A);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, heliY - 14), width: 22, height: 4), panelPaint);

    // Rotor Mast
    final mastPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(cx, heliY), Offset(cx, heliY - 26), mastPaint);

    // Counter-Rotating Rotor 1 (Top)
    final blade1W = math.cos(rotation) * 44.0;
    final bladePaint = Paint()
      ..color = canFly ? const Color(0xFF22C55E) : const Color(0xFF38BDF8)
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset(cx - blade1W, heliY - 20), Offset(cx + blade1W, heliY - 20), bladePaint);

    // Counter-Rotating Rotor 2 (Bottom)
    final blade2W = math.sin(-rotation) * 44.0;
    canvas.drawLine(Offset(cx - blade2W, heliY - 26), Offset(cx + blade2W, heliY - 26), bladePaint);

    // Landing Legs
    final legPaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(cx - 8, heliY + 8), Offset(cx - 16, heliY + 18), legPaint);
    canvas.drawLine(Offset(cx + 8, heliY + 8), Offset(cx + 16, heliY + 18), legPaint);
  }

  @override
  bool shouldRepaint(covariant _MarsHelicopterPainter oldDelegate) => true;
}
