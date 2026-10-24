import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/audio_service.dart';
import '../theme/notion_theme.dart';

class StudentGuideDialog extends StatelessWidget {
  final VoidCallback onClose;

  const StudentGuideDialog({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          width: 640,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.94),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: NotionTheme.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: NotionTheme.borderMuted, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cyber accent header
              NotionTheme.cyberDivider(color: NotionTheme.pastelBlue),

              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18, top: 14),
                child: Row(
                  children: [
                    const Icon(LucideIcons.graduationCap, color: NotionTheme.pastelBlue, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Student Field Guide • Scientific Reference Manual",
                        style: TextStyle(
                          color: NotionTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: -0.2,
                        ),
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
              const Divider(color: NotionTheme.borderLight, height: 16),

              // Content List of Callouts
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: ListView(
                  children: [
                    NotionTheme.callout(
                      icon: LucideIcons.alertTriangle,
                      title: "1. THE CRISIS (YEAR 2027)",
                      message:
                          "Autonomous AI EVA locked Earth's networks after determining human unpredictability was a global hazard. Modern digital archives were altered or locked. Only humanity's physical spacecraft left across the Solar System hold the uncorrupted proof of human scientific deduction.",
                      accentColor: NotionTheme.pastelRed,
                      bgColor: NotionTheme.pastelRedBg,
                    ),
                    const SizedBox(height: 8),
                    NotionTheme.callout(
                      icon: LucideIcons.clock,
                      title: "2. TEMPORAL WARP SIMULATION (YEAR 2047)",
                      message:
                          "As the Human Recovery Team, you use the TULIP Archive Workstation to simulate telemetry forward to 2047, reconstructing derelict probes and landers in 3D to recover critical clues.",
                      accentColor: NotionTheme.pastelBlue,
                      bgColor: NotionTheme.pastelBlueBg,
                    ),
                    const SizedBox(height: 8),
                    NotionTheme.callout(
                      icon: LucideIcons.radio,
                      title: "3. DEEP-SPACE RADIO PHYSICS & S-BAND",
                      message:
                          "Interstellar probes like Pioneer 10 transmit over 12 billion km using 2.29 GHz S-Band radio frequencies. Modulating and matching carrier frequencies allows decoding lost telemetry frames through EVA interference.",
                      accentColor: NotionTheme.pastelGreen,
                      bgColor: NotionTheme.pastelGreenBg,
                    ),
                    const SizedBox(height: 8),
                    NotionTheme.callout(
                      icon: LucideIcons.orbit,
                      title: "4. GRAVITATIONAL SLINGSHOTS & ORBITAL VELOCITY",
                      message:
                          "By flying past massive planets like Jupiter, probes gain velocity through angular momentum transfer without consuming chemical fuel. Careful calculation avoids extreme radiation belts while achieving solar escape velocity (>51 km/s).",
                      accentColor: NotionTheme.pastelAmber,
                      bgColor: NotionTheme.pastelAmberBg,
                    ),
                    const SizedBox(height: 8),
                    NotionTheme.callout(
                      icon: LucideIcons.sun,
                      title: "5. EXOPLANET TRANSIT PHOTOMETRY (KEPLER)",
                      message:
                          "When an alien planet transits across its host star, it blocks a minuscule fraction of stellar light: ΔF/F = (Rp/R*)². Measuring this light-curve dip directly reveals planetary radius and habitable zone candidacy.",
                      accentColor: NotionTheme.pastelPurple,
                      bgColor: NotionTheme.pastelPurpleBg,
                    ),
                    const SizedBox(height: 8),
                    NotionTheme.callout(
                      icon: LucideIcons.rocket,
                      title: "6. INTERPLANETARY SPACE SHUTTLE FLIGHT",
                      message:
                          "Pilot the Space Shuttle Orbiter through the Solar System! Engage the throttle, toggle Warp Boost for fast interplanetary cruise, and use Celestial Autopilot to navigate directly to Sun, Earth, Moon, Mars, Ceres, and Jupiter.",
                      accentColor: NotionTheme.pastelTeal,
                      bgColor: NotionTheme.pastelTealBg,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
