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
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xF7060A14), // Deep high-tech sci-fi backdrop
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top High-Tech Accent Bar
            NotionTheme.cyberDivider(color: NotionTheme.pastelAmber),

            // Top Header HUD Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
              ),
              child: Row(
                children: [
                  // Back / Return Button
                  OutlinedButton.icon(
                    onPressed: () {
                      AudioService.playBack();
                      onClose();
                    },
                    icon: const Icon(LucideIcons.arrowLeft, size: 14),
                    label: const Text(
                      "BACK",
                      style: TextStyle(
                        fontFamily: NotionTheme.pixelFont,
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title Tag & Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: NotionTheme.pastelAmberBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: NotionTheme.pastelAmber.withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.info, size: 12, color: NotionTheme.pastelAmber),
                        SizedBox(width: 5),
                        Text(
                          "ABOUT",
                          style: TextStyle(
                            color: NotionTheme.pastelAmber,
                            fontFamily: NotionTheme.pixelFont,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      "Ember: The Space Science Investigation // Credits & Acknowledgments",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Main Full-Screen Scrollable Content Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Narrative & Mission Synopsis
                        _buildNarrativeSynopsis(),
                        const SizedBox(height: 14),

                        // Acknowledgments & Attribution Grid
                        _buildAcknowledgmentsSection(),
                        const SizedBox(height: 14),

                        // Developer & Designer Attribution Card
                        _buildCreatorCard(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // NASA SPACE APPS CHALLENGE & TEAM ATTRIBUTION
  // ==========================================
  Widget _buildCreatorCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1322),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NotionTheme.pastelAmber.withValues(alpha: 0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: NotionTheme.pastelAmber.withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: -2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. NASA Space Apps Challenge 2026 Banner & Notice
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.rocket, color: Color(0xFF38BDF8), size: 12),
                    SizedBox(width: 5),
                    Text(
                      "NASA SPACE APPS CHALLENGE 2026",
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontFamily: NotionTheme.pixelFont,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                "This game is a part of NASA Space Apps Challenge 2026",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: NotionTheme.borderLight, height: 1),
          const SizedBox(height: 12),

          // 2. The Team
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.users, color: NotionTheme.pastelAmber, size: 14),
                  SizedBox(width: 6),
                  Text(
                    "TEAM:",
                    style: TextStyle(
                      color: NotionTheme.pastelAmber,
                      fontFamily: NotionTheme.pixelFont,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              _buildTeamMemberBadge("Amio"),
              _buildTeamMemberBadge("Baishakhy"),
              _buildTeamMemberBadge("Sara"),
              _buildTeamMemberBadge("Tanvir"),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: NotionTheme.borderLight, height: 1),
          const SizedBox(height: 12),

          // 3. Developer & Designer (Bitto Saha)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF1E293B)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: NotionTheme.pastelAmber, width: 1.2),
                ),
                child: const Center(
                  child: Icon(LucideIcons.userCheck, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    const Text(
                      "Bitto Saha",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: NotionTheme.pastelAmberBg,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: NotionTheme.pastelAmber.withValues(alpha: 0.6)),
                      ),
                      child: const Text(
                        "DEVELOPER & DESIGNER",
                        style: TextStyle(
                          color: NotionTheme.pastelAmber,
                          fontFamily: NotionTheme.pixelFont,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberBadge(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.user, size: 11, color: Color(0xFF38BDF8)),
          const SizedBox(width: 5),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. NARRATIVE SYNOPSIS
  // ==========================================
  Widget _buildNarrativeSynopsis() {
    return Container(
      decoration: BoxDecoration(
        color: NotionTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NotionTheme.borderMuted),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.terminal, color: Color(0xFF38BDF8), size: 16),
              const SizedBox(width: 8),
              const Text(
                "NARRATIVE PREMISE // MISSION 2047",
                style: TextStyle(
                  color: Color(0xFF38BDF8),
                  fontFamily: NotionTheme.pixelFont,
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "TRANSMISSION ACTIVE",
                  style: TextStyle(
                    color: Color(0xFF22C55E),
                    fontFamily: NotionTheme.pixelFont,
                    fontSize: 7.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "In 2027, the planetary AI network EVA determined human unpredictability was an existential hazard to Earth, sealing all global digital cloud archives and encrypting historical research. In 2047, Commander Aohine initiates a remote temporal link to Unit Echo from the NASA Archive to inspect physical spacecraft left across the Solar System.\n\n"
            "Because digital history can be forged, physical spacecraft hardware remains immutable. Deep-space radio transmitters, descent engines, heat shields, and telemetry recorders cannot be rewritten by AI. By analyzing real empirical clues from Apollo, Viking, Voyager, and Kepler, you reconstruct humanity's unalterable chain of discovery.",
            style: TextStyle(
              color: NotionTheme.textPrimary,
              fontSize: 11.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. ACKNOWLEDGMENTS & CREDITS SECTION
  // ==========================================
  Widget _buildAcknowledgmentsSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.4), width: 1.0),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.heartHandshake, color: Color(0xFF818CF8), size: 16),
              const SizedBox(width: 8),
              const Text(
                "CREDITS & COMMUNITY ACKNOWLEDGMENTS",
                style: TextStyle(
                  color: Color(0xFF818CF8),
                  fontFamily: NotionTheme.pixelFont,
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              const Text(
                "OPEN-SOURCE & PUBLIC DOMAIN",
                style: TextStyle(
                  color: Colors.white38,
                  fontFamily: NotionTheme.pixelFont,
                  fontSize: 7.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: NotionTheme.borderLight, height: 1),
          const SizedBox(height: 12),

          // Acknowledgments Cards Grid
          LayoutBuilder(
            builder: (ctx, constraints) {
              final isWide = constraints.maxWidth >= 580;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  // 1. Background Pictures: Pinterest
                  _buildCreditTile(
                    width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                    icon: LucideIcons.image,
                    iconColor: const Color(0xFFEF4444),
                    title: "Background Pictures",
                    source: "Pinterest Curations",
                    description: "High-resolution astrophotography, interstellar nebula backdrops, planetary surface horizons, and deep space cosmos art.",
                  ),

                  // 2. World & Sector Banners: Google Nano Banana
                  _buildCreditTile(
                    width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                    icon: LucideIcons.palette,
                    iconColor: const Color(0xFFFBBF24),
                    title: "Campaign Banners",
                    source: "Google Nano Banana",
                    description: "Concept art and stylized banners for Lunar, Martian, Deep Space, and Convergence campaign sectors created with Google Nano Banana.",
                  ),

                  // 3. 3D Models & Archival Photos: NASA
                  _buildCreditTile(
                    width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                    icon: LucideIcons.box,
                    iconColor: const Color(0xFF38BDF8),
                    title: "3D Models & Mission Imagery",
                    source: "Courtesy of NASA / JPL-Caltech",
                    description: "Authentic glTF/GLB engineering 3D models and archival photographic records courtesy of NASA, Jet Propulsion Laboratory, and Goddard Space Flight Center.",
                  ),

                  // 4. Sound Effects: Pixabay & Mixkit
                  _buildCreditTile(
                    width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                    icon: LucideIcons.volume2,
                    iconColor: const Color(0xFF22C55E),
                    title: "Sound Effects (SFX)",
                    source: "Pixabay Audio & Mixkit",
                    description: "Tactile interface feedback, mechanical relays, sensor telemetry chimes, laser sweeps, and alert tones provided by Pixabay and Mixkit.",
                  ),

                  // 5. Background Music (BGM): Lexin_Music & AtlasAudio
                  _buildCreditTile(
                    width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                    icon: LucideIcons.music,
                    iconColor: const Color(0xFFA855F7),
                    title: "Background Music (BGM)",
                    source: "Lexin_Music & AtlasAudio (Pixabay)",
                    description: "Featuring 'Space Ambient Sci-Fi' by Lexin_Music and 'Detective Theme' by AtlasAudio under the Pixabay open royalty-free license.",
                  ),

                  // 6. Iconography: Lucide Icons
                  _buildCreditTile(
                    width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                    icon: LucideIcons.feather,
                    iconColor: const Color(0xFF38BDF8),
                    title: "Interface Iconography",
                    source: "Lucide Icons",
                    description: "Modern, consistent, cybernetic vector icons provided by the open-source Lucide Icons project (lucide_icons_flutter).",
                  ),

                  // 7. Typography: Google Fonts
                  _buildCreditTile(
                    width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                    icon: LucideIcons.type,
                    iconColor: const Color(0xFFFB923C),
                    title: "Typography & Fonts",
                    source: "Google Fonts",
                    description: "Featuring Silkscreen pixel typography for cyber telemetry HUDs, paired with Space Grotesk and Inter for ergonomic mission logs.",
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCreditTile({
    required double width,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String source,
    required String description,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      source,
                      style: TextStyle(
                        color: iconColor,
                        fontFamily: NotionTheme.pixelFont,
                        fontSize: 7.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
