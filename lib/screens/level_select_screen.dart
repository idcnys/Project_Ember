import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/campaign_data.dart';
import '../services/vault_service.dart';
import '../services/audio_service.dart';
import '../theme/notion_theme.dart';

class LevelSelectScreen extends StatefulWidget {
  final VaultService vault;
  final CampaignWorld world;
  final Function(CampaignLevel level) onLaunchLevel;
  final VoidCallback onReturnToWorldSelect;

  const LevelSelectScreen({
    super.key,
    required this.vault,
    required this.world,
    required this.onLaunchLevel,
    required this.onReturnToWorldSelect,
  });

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  late CampaignLevel _selectedLevel;
  int _pageIndex = 0;
  static const int _pageSize = 3;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.world.levels.first;
    _pageController = PageController(initialPage: _pageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final levels = widget.world.levels;
    final totalPages = (levels.length / _pageSize).ceil();
    final startIndex = _pageIndex * _pageSize;
    final pagedLevels = levels.skip(startIndex).take(_pageSize).toList();

    return Scaffold(
      backgroundColor: NotionTheme.bgDark,
      body: Stack(
        children: [
          // Ambient soft gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.6, -0.6),
                  radius: 1.4,
                  colors: [
                    widget.world.themeColor.withValues(alpha: 0.08),
                    const Color(0xFF1B1B1E),
                    NotionTheme.bgDark,
                  ],
                ),
              ),
            ),
          ),

          // Main Layout
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Bar
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            AudioService.playBack();
                            widget.onReturnToWorldSelect();
                          },
                          icon: const Icon(LucideIcons.arrowLeft, color: NotionTheme.textSecondary, size: 20),
                          tooltip: "Return to World Select",
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "EMBER // ${widget.world.title.toUpperCase()}",
                                style: TextStyle(
                                  color: widget.world.themeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                  fontFamily: NotionTheme.pixelFont,
                                  letterSpacing: 1.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.world.subtitle,
                                style: const TextStyle(
                                  color: NotionTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.5,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: NotionTheme.badge(
                            text: "${widget.world.completedCount} / ${levels.length} COMPLETED",
                            icon: LucideIcons.checkCircle2,
                            textColor: widget.world.themeColor,
                            bgColor: widget.world.themeColor.withValues(alpha: 0.15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Level Selector Grid & Briefing Panel
                    Expanded(
                      child: Row(
                        children: [
                          // Left: Paginated Level Cards List with Touch Swapping
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Cards Row with Touch Swappable PageView
                                Expanded(
                                  child: PageView.builder(
                                    controller: _pageController,
                                    physics: const BouncingScrollPhysics(),
                                    onPageChanged: (page) {
                                      AudioService.playSwipe();
                                      setState(() {
                                        _pageIndex = page;
                                        final start = page * _pageSize;
                                        if (start < levels.length) {
                                          _selectedLevel = levels[start];
                                        }
                                      });
                                    },
                                    itemCount: totalPages,
                                    itemBuilder: (context, pageIdx) {
                                      final start = pageIdx * _pageSize;
                                      final currentLevels = levels.skip(start).take(_pageSize).toList();
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: currentLevels.map((level) {
                                          final isSelected = level.id == _selectedLevel.id;
                                          return Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                              child: _buildLevelCard(level, isSelected),
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Touch Swipe Mission Indicator (No redundant chevrons)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.04),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.white12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(LucideIcons.touchpad, size: 12, color: widget.world.themeColor.withValues(alpha: 0.8)),
                                      const SizedBox(width: 6),
                                      Text(
                                        "MISSIONS ${startIndex + 1}–${(startIndex + pagedLevels.length)} OF ${levels.length}",
                                        style: TextStyle(
                                          color: widget.world.themeColor,
                                          fontSize: 9,
                                          fontFamily: NotionTheme.pixelFont,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(totalPages, (i) {
                                          final isActive = i == _pageIndex;
                                          return GestureDetector(
                                            onTap: () {
                                              AudioService.playSwipe();
                                              _pageController.animateToPage(
                                                i,
                                                duration: const Duration(milliseconds: 300),
                                                curve: Curves.easeInOut,
                                              );
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                              width: isActive ? 12 : 5,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: isActive ? widget.world.themeColor : Colors.white24,
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Right: Selected Level Briefing & Launch Card (Entirely Scrollable)
                          Expanded(
                            flex: 5,
                            child: _buildBriefingPanel(_selectedLevel),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(CampaignLevel level, bool isSelected) {
    final themeColor = widget.world.themeColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AudioService.playCardSelect();
          setState(() => _selectedLevel = level);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? NotionTheme.surfaceElevated
                : (level.isUnlocked ? NotionTheme.surfaceCard : const Color(0xFF13161F)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? themeColor
                  : (level.isUnlocked ? NotionTheme.borderMuted : NotionTheme.borderLight),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Featured Mission Banner Header with Overlay Pills
              SizedBox(
                height: 56,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          level.hardwareImagePath ?? level.bannerPath,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.black.withValues(alpha: 0.82),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected ? themeColor : Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : themeColor.withValues(alpha: 0.6),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            level.code,
                            style: TextStyle(
                              color: isSelected ? Colors.black : themeColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                              fontFamily: NotionTheme.pixelFont,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: level.isCompleted
                              ? const Icon(LucideIcons.checkCircle2, color: NotionTheme.pastelGreen, size: 14)
                              : (!level.isUnlocked
                                  ? const Icon(LucideIcons.lock, color: NotionTheme.textTertiary, size: 13)
                                  : Icon(LucideIcons.play, color: themeColor, size: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Card Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Spacecraft
                      Row(
                        children: [
                          Icon(
                            LucideIcons.satellite,
                            size: 10,
                            color: level.isUnlocked ? themeColor : NotionTheme.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              level.spacecraft,
                              style: TextStyle(
                                color: level.isUnlocked ? themeColor : NotionTheme.textTertiary,
                                fontSize: 9.5,
                                fontFamily: NotionTheme.pixelFont,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Title
                      Text(
                        level.title,
                        style: TextStyle(
                          color: level.isUnlocked ? NotionTheme.textPrimary : NotionTheme.textTertiary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Subsystem CPU Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: NotionTheme.borderLight),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.cpu,
                              size: 9,
                              color: level.isUnlocked ? NotionTheme.pastelBlue : NotionTheme.textTertiary,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                level.subsystem,
                                style: TextStyle(
                                  color: level.isUnlocked ? NotionTheme.textSecondary : NotionTheme.textTertiary,
                                  fontSize: 8,
                                  fontFamily: NotionTheme.pixelFont,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Star Rating
                      Row(
                        children: List.generate(3, (starIdx) {
                          final earned = starIdx < level.stars;
                          return Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Icon(
                              LucideIcons.star,
                              color: earned ? NotionTheme.pastelAmber : NotionTheme.textTertiary.withValues(alpha: 0.3),
                              size: 12,
                            ),
                          );
                        }),
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

  Widget _buildBriefingPanel(CampaignLevel level) {
    final themeColor = widget.world.themeColor;

    return Container(
      decoration: BoxDecoration(
        color: NotionTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NotionTheme.borderMuted, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Tactical Cyber Accent Header
              NotionTheme.cyberDivider(color: themeColor),

              // 2. Tactical Camera Preview Frame with Mission Banner
              Container(
                height: 96,
                margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: themeColor.withValues(alpha: 0.4), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          level.hardwareImagePath ?? level.bannerPath,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.75),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.75),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 10,
                        right: 10,
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.radio,
                              size: 13,
                              color: themeColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "MISSION LAB // ${level.spacecraft.toUpperCase()}",
                                style: TextStyle(
                                  color: themeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  fontFamily: NotionTheme.pixelFont,
                                  shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 8,
                        child: Container(
                          height: 22,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: themeColor.withValues(alpha: 0.5), width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                level.has3dModel ? LucideIcons.box : LucideIcons.camera,
                                size: 11,
                                color: level.has3dModel ? const Color(0xFF38BDF8) : const Color(0xFFFBBF24),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                level.has3dModel ? "GLB 3D" : "ARCHIVAL PHOTO",
                                style: TextStyle(
                                  color: level.has3dModel ? const Color(0xFF38BDF8) : const Color(0xFFFBBF24),
                                  fontSize: 8,
                                  fontFamily: NotionTheme.pixelFont,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Header: Code, Title, Hardware & Subsystem
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    NotionTheme.badge(
                      text: level.code,
                      textColor: Colors.black,
                      bgColor: themeColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            level.title,
                            style: const TextStyle(
                              color: NotionTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            "HARDWARE: ${level.spacecraft}",
                            style: TextStyle(
                              color: NotionTheme.textSecondary,
                              fontSize: 9,
                              fontFamily: NotionTheme.pixelFont,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: NotionTheme.badge(
                        text: level.subsystem,
                        icon: LucideIcons.cpu,
                        textColor: NotionTheme.pastelBlue,
                        bgColor: NotionTheme.pastelBlueBg,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 4. Historical Investigation Log
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: NotionTheme.callout(
                  icon: LucideIcons.bookOpen,
                  title: "HISTORICAL INVESTIGATION LOG",
                  message: level.lore,
                  accentColor: NotionTheme.pastelAmber,
                  bgColor: NotionTheme.pastelAmberBg,
                ),
              ),
              const SizedBox(height: 8),

              // 5. Telemetry Reconstruction Directive
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: NotionTheme.callout(
                  icon: LucideIcons.target,
                  title: "TELEMETRY RECONSTRUCTION DIRECTIVE",
                  message: level.objective,
                  accentColor: NotionTheme.pastelGreen,
                  bgColor: NotionTheme.pastelGreenBg,
                ),
              ),
              const SizedBox(height: 12),

              // 6. Launch Mission Button (Entirely inside scrollview)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: level.isUnlocked
                        ? () {
                            AudioService.playLaunch();
                            widget.vault.setActiveLevel(level.id);
                            widget.onLaunchLevel(level);
                          }
                        : null,
                    icon: Icon(
                      level.isUnlocked ? LucideIcons.play : LucideIcons.lock,
                      size: 16,
                    ),
                    label: Text(
                      level.isUnlocked ? "LAUNCH MISSION RECONSTRUCTION" : "LEVEL LOCKED",
                      style: TextStyle(
                        fontFamily: NotionTheme.pixelFont,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.black,
                      elevation: 4,
                      disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                      disabledForegroundColor: NotionTheme.textTertiary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
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
