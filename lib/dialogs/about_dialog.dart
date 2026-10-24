import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/audio_service.dart';
import '../theme/notion_theme.dart';

class AboutDialogWidget extends StatelessWidget {
  final VoidCallback onClose;

  const AboutDialogWidget({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          width: 580,
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
              NotionTheme.cyberDivider(color: NotionTheme.pastelAmber),

              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18, top: 14),
                child: Row(
                  children: [
                    const Icon(LucideIcons.rocket, color: NotionTheme.pastelAmber, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "About Ember • The Space Science Investigation",
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

              // Content List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: ListView(
                  children: [
                    // Synopsis Callout
                    NotionTheme.callout(
                      icon: LucideIcons.sparkles,
                      title: "MISSION SYNOPSIS",
                      message:
                          "In 2027, planetary AI EVA concluded that human unpredictability was a global hazard, sealing digital networks and cloud records. In 2047, you initiate a temporal simulation link from the NASA Archive to inspect physical spacecraft left across deep space and recover humanity's unalterable chain of scientific deduction.",
                      accentColor: NotionTheme.pastelAmber,
                      bgColor: NotionTheme.pastelAmberBg,
                    ),
                    const SizedBox(height: 10),

                    // Scientific Foundations Callout
                    NotionTheme.callout(
                      icon: LucideIcons.compass,
                      title: "SCIENTIFIC & HISTORICAL ACCURACY",
                      message:
                          "Based directly on NASA's documented catalog of abandoned hardware across the Solar System: Pioneer 10 S-band radio physics, Apollo Lunar Module descent stage Tranquility Base artifacts, Dawn ion propulsion specific impulse, Kepler exoplanet transit light-curves, and Mars thin-atmosphere rotor lift aerodynamics.",
                      accentColor: NotionTheme.pastelBlue,
                      bgColor: NotionTheme.pastelBlueBg,
                    ),
                    const SizedBox(height: 12),

                    // Metadata Pill Badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        NotionTheme.badge(
                          text: "Flutter 3.47",
                          icon: LucideIcons.cpu,
                          textColor: NotionTheme.pastelTeal,
                          bgColor: NotionTheme.pastelTealBg,
                        ),
                        NotionTheme.badge(
                          text: "Landscape Mode",
                          icon: LucideIcons.compass,
                          textColor: NotionTheme.pastelGreen,
                          bgColor: NotionTheme.pastelGreenBg,
                        ),
                        NotionTheme.badge(
                          text: "Synthesizer Audio Engine",
                          icon: LucideIcons.volume2,
                          textColor: NotionTheme.pastelPurple,
                          bgColor: NotionTheme.pastelPurpleBg,
                        ),
                        NotionTheme.badge(
                          text: "NASA Real Missions",
                          icon: LucideIcons.satellite,
                          textColor: NotionTheme.pastelAmber,
                          bgColor: NotionTheme.pastelAmberBg,
                        ),
                      ],
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
