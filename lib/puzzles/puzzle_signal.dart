import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/audio_service.dart';
import '../theme/notion_theme.dart';

class PuzzleSignalWidget extends StatefulWidget {
  final String missionId;
  final Function(List<String> clueIds, String message) onSolved;

  const PuzzleSignalWidget({
    super.key,
    required this.missionId,
    required this.onSolved,
  });

  @override
  State<PuzzleSignalWidget> createState() => _PuzzleSignalWidgetState();
}

class _PuzzleSignalWidgetState extends State<PuzzleSignalWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  double _freq = 1.8;
  double _mod = 25.0;
  double _gain = 12.0;

  // Target values (Pioneer 10 S-band)
  final double _targetFreq = 2.29;
  final double _targetMod = 64.0;
  final double _targetGain = 24.0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  double get _accuracy {
    final diffF = (_freq - _targetFreq).abs() / 3.0;
    final diffM = (_mod - _targetMod).abs() / 80.0;
    final diffG = (_gain - _targetGain).abs() / 30.0;
    final score = 1.0 - (diffF + diffM + diffG) / 3.0;
    return (score.clamp(0.0, 1.0) * 100).roundToDouble();
  }

  bool get _isLocked => _accuracy >= 85.0;

  void _lockSignal() {
    if (_isLocked) {
      AudioService.playSuccess();
      final prefix = widget.missionId.replaceAll("mission-", "m");
      widget.onSolved(
        ["$prefix-c01", "$prefix-c02"],
        "SIGNAL RESTORED: Carrier lock verified! Telemetry frame and scientific measurements decoded!",
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
        // Science Guidance Field Tip
        NotionTheme.callout(
          icon: LucideIcons.graduationCap,
          title: "STUDENT FIELD GUIDE",
          message:
              "Deep-space radio signals travel 12 billion km. Move Carrier Frequency to ~2.3 GHz and adjust Modulation until your cyan wave overlaps the green target!",
          accentColor: NotionTheme.pastelBlue,
          bgColor: NotionTheme.pastelBlueBg,
        ),
        const SizedBox(height: 10),

        // Oscilloscope Canvas
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
                painter: _SignalScopePainter(
                  time: _anim.value * math.pi * 4,
                  playerFreq: _freq,
                  playerMod: _mod,
                  playerGain: _gain,
                  targetFreq: _targetFreq,
                  targetMod: _targetMod,
                  targetGain: _targetGain,
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
                label: "CARRIER: ${_freq.toStringAsFixed(1)} GHz",
                value: _freq,
                min: 1.0,
                max: 4.0,
                onChanged: (v) => setState(() => _freq = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDial(
                label: "MODULATION: ${_mod.round()} kHz",
                value: _mod,
                min: 10.0,
                max: 90.0,
                onChanged: (v) => setState(() => _mod = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDial(
                label: "RF GAIN: ${_gain.round()} dB",
                value: _gain,
                min: 5.0,
                max: 35.0,
                onChanged: (v) => setState(() => _gain = v),
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
                _isLocked
                    ? "SIGNAL LOCK ACQUIRED: ${_accuracy.round()}%"
                    : "TUNING SIGNAL LOCK: ${_accuracy.round()}%",
                style: TextStyle(
                  color: _isLocked ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0),
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
              onPressed: _isLocked ? _lockSignal : null,
              icon: const Icon(LucideIcons.radio, size: 14),
              label: const Text("LOCK SIGNAL CARRIER"),
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
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
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

class _SignalScopePainter extends CustomPainter {
  final double time;
  final double playerFreq;
  final double playerMod;
  final double playerGain;
  final double targetFreq;
  final double targetMod;
  final double targetGain;

  _SignalScopePainter({
    required this.time,
    required this.playerFreq,
    required this.playerMod,
    required this.playerGain,
    required this.targetFreq,
    required this.targetMod,
    required this.targetGain,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0x1F22C55E)
      ..strokeWidth = 1.0;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Target wave (Dashed green)
    final targetPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final targetPath = Path();
    for (double x = 0; x < size.width; x += 2) {
      final y = centerY +
          math.sin(x * 0.04 * targetFreq + time) * (targetGain * 1.5) +
          math.cos(x * 0.01 * targetMod) * 12;
      if (x == 0) {
        targetPath.moveTo(x, y);
      } else {
        targetPath.lineTo(x, y);
      }
    }
    canvas.drawPath(targetPath, targetPaint);

    // Player wave (Cyan)
    final playerPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final playerPath = Path();
    for (double x = 0; x < size.width; x += 2) {
      final y = centerY +
          math.sin(x * 0.04 * playerFreq + time) * (playerGain * 1.5) +
          math.cos(x * 0.01 * playerMod) * 12;
      if (x == 0) {
        playerPath.moveTo(x, y);
      } else {
        playerPath.lineTo(x, y);
      }
    }
    canvas.drawPath(playerPath, playerPaint);
  }

  @override
  bool shouldRepaint(covariant _SignalScopePainter oldDelegate) => true;
}
