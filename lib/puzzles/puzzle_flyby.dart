import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/audio_service.dart';
import '../theme/notion_theme.dart';

class PuzzleFlybyWidget extends StatefulWidget {
  final String missionId;
  final Function(List<String> clueIds, String message) onSolved;

  const PuzzleFlybyWidget({
    super.key,
    required this.missionId,
    required this.onSolved,
  });

  @override
  State<PuzzleFlybyWidget> createState() => _PuzzleFlybyWidgetState();
}

class _PuzzleFlybyWidgetState extends State<PuzzleFlybyWidget> {
  double _periapsis = 4.2;
  double _approachVel = 48.0;

  double get _escapeVelocity {
    return _approachVel * 1.38 - _periapsis * 2.8;
  }

  bool get _isCrash => _periapsis < 1.6;
  bool get _isSuccess => _escapeVelocity >= 51.0 && !_isCrash;

  void _calculateSlingshot() {
    if (_isSuccess) {
      AudioService.playSuccess();
      final prefix = widget.missionId.replaceAll("mission-", "m");
      widget.onSolved(
        ["$prefix-c03", "$prefix-c04"],
        "ORBITAL MECHANICS CONFIRMED: Slingshot trajectory validated! Solar escape velocity of ${_escapeVelocity.toStringAsFixed(1)} km/s achieved!",
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
              "Jupiter is 318x Earth's mass. Too close (< 1.6 R_J) crashes into radiation belts. Set Periapsis between 2.0–3.0 R_J to achieve ≥ 51.0 km/s escape speed!",
          accentColor: NotionTheme.pastelAmber,
          bgColor: NotionTheme.pastelAmberBg,
        ),
        const SizedBox(height: 10),

        // Orbit Trajectory Canvas
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFF030712),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: CustomPaint(
            painter: _FlybyTrajectoryPainter(
              periapsis: _periapsis,
              velocity: _approachVel,
              isCrash: _isCrash,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Dials
        Row(
          children: [
            Expanded(
              child: _buildDial(
                label: "PERIAPSIS: ${_periapsis.toStringAsFixed(1)} R_J",
                value: _periapsis,
                min: 1.0,
                max: 6.0,
                onChanged: (v) => setState(() => _periapsis = v),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDial(
                label: "VELOCITY: ${_approachVel.toStringAsFixed(1)} km/s",
                value: _approachVel,
                min: 20.0,
                max: 60.0,
                onChanged: (v) => setState(() => _approachVel = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Feedback & Action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _isCrash
                    ? "RADIATION CRASH: Periapsis < 1.6 R_J!"
                    : _isSuccess
                        ? "SLINGSHOT SUCCESS: ${_escapeVelocity.toStringAsFixed(1)} km/s!"
                        : "ESCAPE VELOCITY: ${_escapeVelocity.toStringAsFixed(1)} km/s (Need ≥ 51)",
                style: TextStyle(
                  color: _isCrash
                      ? const Color(0xFFEF4444)
                      : _isSuccess
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFF59E0B),
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
              onPressed: _isSuccess ? _calculateSlingshot : null,
              icon: const Icon(LucideIcons.orbit, size: 14),
              label: const Text("EXECUTE SLINGSHOT"),
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

class _FlybyTrajectoryPainter extends CustomPainter {
  final double periapsis;
  final double velocity;
  final bool isCrash;

  _FlybyTrajectoryPainter({
    required this.periapsis,
    required this.velocity,
    required this.isCrash,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final px = size.width / 2;
    final py = size.height / 2;

    // Jupiter body
    final jupPaint = Paint()..color = const Color(0xFFB45309);
    canvas.drawCircle(Offset(px, py), 22, jupPaint);

    final jupStroke = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(px, py), 22, jupStroke);

    // Radiation belt danger threshold
    final radPaint = Paint()
      ..color = const Color(0x66EF4444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(px, py), 30, radPaint);

    // Trajectory arc
    final trajPaint = Paint()
      ..color = isCrash ? const Color(0xFFEF4444) : const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    for (double x = 10; x < size.width - 10; x += 4) {
      final dx = x - px;
      final curve = (periapsis * 14.0) / (1.0 + (dx * dx) / (velocity * 120.0));
      final y = py + curve;
      if (x == 10) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, trajPaint);
  }

  @override
  bool shouldRepaint(covariant _FlybyTrajectoryPainter oldDelegate) => true;
}
