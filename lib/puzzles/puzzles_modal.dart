import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/audio_service.dart';
import '../theme/notion_theme.dart';
import 'puzzle_signal.dart';
import 'puzzle_flyby.dart';
import 'puzzle_telemetry.dart';
import 'puzzle_transit.dart';
import 'puzzle_aerodynamics.dart';

class PuzzlesModal extends StatelessWidget {
  final String missionId;
  final String puzzleType; // "signal", "flyby", "telemetry", "transit", "aerodynamics"
  final VoidCallback onClose;
  final Function(List<String> clueIds, String message) onSolved;

  const PuzzlesModal({
    super.key,
    required this.missionId,
    required this.puzzleType,
    required this.onClose,
    required this.onSolved,
  });

  String get _title {
    switch (puzzleType) {
      case "signal":
        return "Puzzle 01 • Radio Signal Reconstruction";
      case "flyby":
        return "Puzzle 02 • Jupiter Slingshot Trajectory";
      case "telemetry":
        return "Puzzle 03 • Mission Timeline Chronology";
      case "transit":
        return "Puzzle 04 • Exoplanet Transit Photometry";
      case "aerodynamics":
        return "Puzzle 05 • Mars Atmospheric Aerodynamics";
      default:
        return "Scientific Recovery Puzzle";
    }
  }

  IconData get _icon {
    switch (puzzleType) {
      case "signal":
        return LucideIcons.radio;
      case "flyby":
        return LucideIcons.orbit;
      case "telemetry":
        return LucideIcons.listOrdered;
      case "transit":
        return LucideIcons.sun;
      case "aerodynamics":
        return LucideIcons.wind;
      default:
        return LucideIcons.sparkles;
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.94;

    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          width: 580,
          constraints: BoxConstraints(maxHeight: maxHeight),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: NotionTheme.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: NotionTheme.borderMuted, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 24,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cyber accent header
              NotionTheme.cyberDivider(color: NotionTheme.pastelAmber),

              // Header Bar (Pinned)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Icon(_icon, color: NotionTheme.pastelAmber, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _title,
                        style: const TextStyle(
                          color: NotionTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: NotionTheme.textSecondary, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        AudioService.playClick();
                        onClose();
                      },
                    ),
                  ],
                ),
              ),
              const Divider(color: NotionTheme.borderLight, height: 1),

              // Scrollable Puzzle Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: _buildPuzzleBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPuzzleBody() {
    if (puzzleType == "signal") {
      return PuzzleSignalWidget(missionId: missionId, onSolved: onSolved);
    } else if (puzzleType == "flyby") {
      return PuzzleFlybyWidget(missionId: missionId, onSolved: onSolved);
    } else if (puzzleType == "telemetry") {
      return PuzzleTelemetryWidget(missionId: missionId, onSolved: onSolved);
    } else if (puzzleType == "transit") {
      return PuzzleTransitWidget(missionId: missionId, onSolved: onSolved);
    } else if (puzzleType == "aerodynamics") {
      return PuzzleAerodynamicsWidget(missionId: missionId, onSolved: onSolved);
    }
    return const SizedBox();
  }
}
