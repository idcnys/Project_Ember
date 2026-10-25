import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/campaign_data.dart';
import '../services/vault_service.dart';
import '../services/audio_service.dart';
import '../theme/notion_theme.dart';
import '../dialogs/settings_dialog.dart';
import '../dialogs/about_dialog.dart';
import '../dialogs/vault_dialog.dart';
import '../dialogs/nasa_timeline_dialog.dart';
import '../dialogs/solar_system_map_dialog.dart';

class MainMenuScreen extends StatefulWidget {
  final VaultService vault;
  final VoidCallback onOpenWorldSelect;
  final VoidCallback onOpenSpaceMissions;
  final VoidCallback? onOpenModelMuseum;
  final ValueChanged<CampaignLevel>? onContinueLevel;
  final VoidCallback? onOpenOnboarding;

  const MainMenuScreen({
    super.key,
    required this.vault,
    required this.onOpenWorldSelect,
    required this.onOpenSpaceMissions,
    this.onOpenModelMuseum,
    this.onContinueLevel,
    this.onOpenOnboarding,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  // Active Modals
  bool _showSettings = false;
  bool _showAbout = false;
  bool _showVault = false;
  bool _showTimeline = false;
  bool _showSolarMap = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 30))
      ..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = widget.vault.unlockedCluesCount;
    final totalClues = widget.vault.totalCluesCount;
    final completedLevels = widget.vault.completedLevelsCount;
    final totalLevels = widget.vault.totalLevelsCount;
    final progressPct = totalLevels > 0 ? (completedLevels / totalLevels * 100).round() : 0;
    final playerName = widget.vault.playerName;

    return Scaffold(
      backgroundColor: NotionTheme.bgDark,
      body: Stack(
        children: [
          // 1. Soft Minimal Ambient Cosmic Starfield Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.6, -0.4),
                  radius: 1.3,
                  colors: [
                    Color(0xFF1E2430),
                    Color(0xFF181C26),
                    NotionTheme.bgDark,
                  ],
                ),
              ),
            ),
          ),

          // Authentic Home Screen Sci-Fi Backdrop
          Positioned.fill(
            child: Opacity(
              opacity: 0.42,
              child: Image.asset(
                'assets/images/home_bg.webp',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),

          // Vignette Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    NotionTheme.bgDark.withValues(alpha: 0.85),
                    NotionTheme.bgDark.withValues(alpha: 0.68),
                    NotionTheme.bgDark.withValues(alpha: 0.90),
                  ],
                ),
              ),
            ),
          ),

          // Gentle particle drift
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, _) {
                return CustomPaint(
                  painter: _SoftStarfieldPainter(time: _anim.value * math.pi * 2),
                );
              },
            ),
          ),

          // 2. Main Split Content (Left: Story & Progress, Right: Interactive Actions)
          Positioned.fill(
            top: 24,
            bottom: 20,
            left: 32,
            right: 32,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Column: Clean Title, Callsign Bot & Progress
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Game Title: EMBER
                          const Text(
                            "Ember",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            "The Space Science Investigation // Physical Archive Recovery",
                            style: TextStyle(
                              color: NotionTheme.textSecondary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Pixel Bot Status & Briefing Card
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFF38BDF8), width: 1),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.asset(
                                      'assets/images/avatar.png',
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Expanded(
                                            child: Text(
                                              "UNIT ECHO // ONLINE",
                                              style: TextStyle(
                                                color: Color(0xFF38BDF8),
                                                fontSize: 8.5,
                                                fontFamily: NotionTheme.pixelFont,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            playerName,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 8.5,
                                              fontFamily: NotionTheme.pixelFont,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        "Earth networks locked. Telemetry links to historical spacecraft active.",
                                        style: TextStyle(
                                          color: NotionTheme.textSecondary,
                                          fontSize: 10,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () {
                                    AudioService.playClick();
                                    widget.onOpenOnboarding?.call();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF38BDF8),
                                    side: BorderSide(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    visualDensity: VisualDensity.compact,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                  child: const Text(
                                    "BRIEFING",
                                    style: TextStyle(fontSize: 8, fontFamily: NotionTheme.pixelFont, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Student Progress Box (Notion Database style with Facility Telemetry HUD)
                          Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: NotionTheme.surfaceCard,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: NotionTheme.borderMuted),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Cyber accent line
                                NotionTheme.cyberDivider(color: NotionTheme.pastelAmber),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            LucideIcons.activity,
                                            size: 14,
                                            color: NotionTheme.pastelAmber,
                                          ),
                                          const SizedBox(width: 8),
                                          const Expanded(
                                            child: Text(
                                              "TELEMETRY RECOVERY PROGRESS",
                                              style: TextStyle(
                                                color: NotionTheme.textSecondary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 9,
                                                letterSpacing: 0.5,
                                                fontFamily: NotionTheme.pixelFont,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "$progressPct% DECRYPTED",
                                            style: const TextStyle(
                                              color: NotionTheme.pastelGreen,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 9,
                                              fontFamily: NotionTheme.pixelFont,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(3),
                                        child: LinearProgressIndicator(
                                          value: totalLevels > 0 ? (completedLevels / totalLevels) : 0,
                                          minHeight: 5,
                                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                                          valueColor: const AlwaysStoppedAnimation<Color>(NotionTheme.pastelGreen),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              "Missions: $completedLevels/$totalLevels Completed",
                                              style: const TextStyle(color: NotionTheme.textSecondary, fontSize: 11),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Physical Clues: $unlocked/$totalClues",
                                            style: const TextStyle(color: NotionTheme.textSecondary, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Right Column: Notion Minimal Action Cards List
                Expanded(
                  flex: 5,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 390),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 0. Primary: Continue Last Played Level (Remembered by Vault)
                            _buildContinueLevelCard(
                              level: widget.vault.activeLevel,
                              onTap: () {
                                AudioService.playSuccess();
                                widget.onContinueLevel?.call(widget.vault.activeLevel);
                              },
                            ),
                            const SizedBox(height: 8),

                            // 1. Campaign: Select World
                            _buildNotionActionCard(
                              title: "Campaign: Select World",
                              subtitle: "4 Planetary Sectors • 24 Historical Spacecraft Anomalies",
                              icon: LucideIcons.compass,
                              accentColor: NotionTheme.pastelGreen,
                              onTap: () {
                                AudioService.playSuccess();
                                widget.onOpenWorldSelect();
                              },
                            ),
                            const SizedBox(height: 8),

                            // 2. Model Museum (Interactive 3D Hardware Archive)
                            _buildNotionActionCard(
                              title: "Model Museum",
                              subtitle: "Interactive 3D gallery of authentic NASA spacecraft, rovers & telescopes",
                              icon: LucideIcons.box,
                              accentColor: NotionTheme.pastelAmber,
                              onTap: () {
                                AudioService.playClick();
                                if (widget.onOpenModelMuseum != null) {
                                  widget.onOpenModelMuseum!();
                                } else {
                                  widget.onOpenSpaceMissions();
                                }
                              },
                            ),
                            const SizedBox(height: 8),

                            // Secondary Tools Row (Vault, Solar Map)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSmallNotionButton(
                                    title: "Evidence Vault",
                                    icon: LucideIcons.database,
                                    onTap: () {
                                      AudioService.playClick();
                                      setState(() => _showVault = true);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSmallNotionButton(
                                    title: "Solar Map",
                                    icon: LucideIcons.globe,
                                    onTap: () {
                                      AudioService.playClick();
                                      setState(() => _showSolarMap = true);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Utility Row: Settings, About, NASA Timeline
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSmallNotionButton(
                                    title: "NASA Timeline",
                                    icon: LucideIcons.history,
                                    onTap: () {
                                      AudioService.playClick();
                                      setState(() => _showTimeline = true);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSmallNotionButton(
                                    title: "Settings",
                                    icon: LucideIcons.settings,
                                    onTap: () {
                                      AudioService.playClick();
                                      setState(() => _showSettings = true);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSmallNotionButton(
                                    title: "About",
                                    icon: LucideIcons.info,
                                    onTap: () {
                                      AudioService.playClick();
                                      setState(() => _showAbout = true);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Modal Dialogs Overlay
          if (_showSettings)
            SettingsDialog(
              vault: widget.vault,
              onClose: () => setState(() => _showSettings = false),
            ),

          if (_showAbout)
            Positioned.fill(
              child: AboutDialogWidget(
                onClose: () => setState(() => _showAbout = false),
              ),
            ),

          if (_showVault)
            VaultDialog(
              vault: widget.vault,
              onClose: () => setState(() => _showVault = false),
            ),

          if (_showTimeline)
            NasaTimelineDialog(
              onClose: () => setState(() => _showTimeline = false),
            ),

          if (_showSolarMap)
            SolarSystemMapDialog(
              onSelectMission: (missionId) {
                widget.vault.setActiveMission(missionId);
                setState(() => _showSolarMap = false);
                widget.onOpenSpaceMissions();
              },
              onClose: () => setState(() => _showSolarMap = false),
            ),
        ],
      ),
    );
  }

  Widget _buildContinueLevelCard({
    required CampaignLevel level,
    required VoidCallback onTap,
  }) {
    const accentColor = Color(0xFF38BDF8); // High-tech Cyan
    final starsText = level.isCompleted ? "★" * level.stars : "IN PROGRESS";

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: accentColor.withValues(alpha: 0.15),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF0C1929),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: accentColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.22),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NotionTheme.cyberDivider(color: accentColor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(LucideIcons.play, size: 18, color: accentColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  level.code,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 8.5,
                                    fontFamily: NotionTheme.pixelFont,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "CONTINUE: ${level.spacecraft.toUpperCase()}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "${level.title} • $starsText",
                            style: const TextStyle(
                              color: Color(0xFF7DD3FC),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: accentColor,
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

  Widget _buildNotionActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color accentColor = NotionTheme.pastelBlue,
    bool isPrimary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: accentColor.withValues(alpha: 0.1),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isPrimary ? NotionTheme.surfaceElevated : NotionTheme.surfaceCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isPrimary ? accentColor : NotionTheme.borderMuted,
              width: isPrimary ? 1.5 : 1.0,
            ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.15),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isPrimary) NotionTheme.cyberDivider(color: accentColor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(icon, size: 18, color: accentColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: isPrimary ? Colors.white : NotionTheme.textPrimary,
                              fontWeight: isPrimary ? FontWeight.w800 : FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: NotionTheme.textSecondary,
                              fontSize: 10.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 15,
                      color: isPrimary ? accentColor : NotionTheme.textTertiary,
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

  Widget _buildSmallNotionButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: NotionTheme.surfaceCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: NotionTheme.borderMuted),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: NotionTheme.pastelBlue),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: NotionTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.5,
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

class _SoftStarfieldPainter extends CustomPainter {
  final double time;

  _SoftStarfieldPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(77);
    final starPaint = Paint()..color = Colors.white;

    for (int i = 0; i < 55; i++) {
      final bx = rand.nextDouble() * size.width;
      final by = rand.nextDouble() * size.height;
      final speed = 0.4 + rand.nextDouble() * 0.6;
      final dx = (bx + math.sin(time * speed + i) * 4.0) % size.width;
      final dy = (by + math.cos(time * speed + i) * 4.0) % size.height;
      final radius = 0.5 + rand.nextDouble() * 0.9;

      starPaint.color = Colors.white.withValues(alpha: 0.15 + math.sin(time + i) * 0.12);
      canvas.drawCircle(Offset(dx, dy), radius, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SoftStarfieldPainter oldDelegate) => true;
}
