import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/audio_service.dart';
import '../theme/notion_theme.dart';

class PuzzleTelemetryWidget extends StatefulWidget {
  final String missionId;
  final Function(List<String> clueIds, String message) onSolved;

  const PuzzleTelemetryWidget({
    super.key,
    required this.missionId,
    required this.onSolved,
  });

  @override
  State<PuzzleTelemetryWidget> createState() => _PuzzleTelemetryWidgetState();
}

class _PuzzleTelemetryWidgetState extends State<PuzzleTelemetryWidget> {
  late List<_SeqStep> _steps;
  int? _selectedIdx;

  @override
  void initState() {
    super.initState();
    _initSteps();
  }

  void _initSteps() {
    List<_SeqStep> baseSteps = [];

    if (widget.missionId == "mission-02") {
      baseSteps = [
        _SeqStep("Saturn V Launch & Trans-Lunar Injection (TLI)", 0),
        _SeqStep("Translunar Coast & Lunar Orbit Insertion (LOI)", 1),
        _SeqStep("Lunar Module Descent & Powered Lunar Landing", 2),
        _SeqStep("Extravehicular Activity & EASEP Seismic Setup", 3),
        _SeqStep("Ascent Engine Firing & Earth Return Injection", 4),
      ];
    } else if (widget.missionId == "mission-03") {
      baseSteps = [
        _SeqStep("Delta II Launch & Mars Gravity Assist Slingshot", 0),
        _SeqStep("Ion Engine Interplanetary Cruise to Asteroid Belt", 1),
        _SeqStep("Vesta Orbit Insertion & Basaltic Core Spectroscopy", 2),
        _SeqStep("Departure from Vesta & Heliocentric Cruise to Ceres", 3),
        _SeqStep("Ceres Low-Altitude Orbit & GRaND Subsurface Ice Mapping", 4),
      ];
    } else if (widget.missionId == "mission-04") {
      baseSteps = [
        _SeqStep("Interplanetary Launch & Mars Atmospheric Entry (EDL)", 0),
        _SeqStep("Supersonic Parachute & Powered Descent Landing", 1),
        _SeqStep("Surface Deployment & Rocker-Bogie Soil Sampling", 2),
        _SeqStep("Ingenuity Helicopter Release & Historic 1st Flight", 3),
        _SeqStep("Sedimentary Hematite Mapping & Groundwater Evidence", 4),
      ];
    } else if (widget.missionId == "mission-05") {
      baseSteps = [
        _SeqStep("Delta II Heliocentric Earth-Trailing Launch", 0),
        _SeqStep("Optical Dust Cover Ejection & First Sky Calibration", 1),
        _SeqStep("Continuous 95-Megapixel CCD Stellar Photometry", 2),
        _SeqStep("Transit Light-Curve Signature Analysis (Kepler-452b)", 3),
        _SeqStep("Solar Radiation Balance Repointing & Extended K2 Survey", 4),
      ];
    } else {
      baseSteps = [
        _SeqStep("Launch & Trans-Jupiter Planetary Injection", 0),
        _SeqStep("Heliocentric Cruise & Asteroid Belt Transit", 1),
        _SeqStep("Jupiter Gravity Encounter & Closest Approach", 2),
        _SeqStep("Radiation Belt & Magnetic Field Science Measurement", 3),
        _SeqStep("Deep Space Telemetry Burst & Solar Escape Cruise", 4),
      ];
    }

    _steps = List.from(baseSteps)..shuffle();
  }

  void _onTapStep(int index) {
    AudioService.playClick();
    if (_selectedIdx == null) {
      setState(() => _selectedIdx = index);
    } else {
      setState(() {
        final temp = _steps[_selectedIdx!];
        _steps[_selectedIdx!] = _steps[index];
        _steps[index] = temp;
        _selectedIdx = null;
      });
    }
  }

  void _verifySequence() {
    bool isCorrect = true;
    for (int i = 0; i < _steps.length; i++) {
      if (_steps[i].correctIndex != i) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) {
      AudioService.playSuccess();
      final prefix = widget.missionId.replaceAll("mission-", "m");
      widget.onSolved(
        ["$prefix-c03", "$prefix-c04"],
        "CHRONOLOGY RESTORED: All 5 mission flight phases confirmed in chronological sequence!",
      );
    } else {
      AudioService.playAlert();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sequence incomplete. Arrange phases from Launch to final mission objective."),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
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
              "Tap any two cards to swap their positions until the flight profile follows chronological order from Launch to Mission Target!",
          accentColor: NotionTheme.pastelBlue,
          bgColor: NotionTheme.pastelBlueBg,
        ),
        const SizedBox(height: 10),

        // Steps List
        ...List.generate(_steps.length, (idx) {
          final isSelected = _selectedIdx == idx;
          final step = _steps[idx];

          return GestureDetector(
            onTap: () => _onTapStep(idx),
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF334155),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${idx + 1}",
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Color(0xFF38BDF8), size: 16),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),

        // Verify button
        ElevatedButton.icon(
          onPressed: _verifySequence,
          icon: const Icon(LucideIcons.listOrdered, size: 15),
          label: const Text("VERIFY SEQUENCE"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF22C55E),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 10),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _SeqStep {
  final String text;
  final int correctIndex;
  _SeqStep(this.text, this.correctIndex);
}
