import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/campaign_data.dart';
import '../services/vault_service.dart';
import '../services/audio_service.dart';
import '../theme/notion_theme.dart';

class WorldSelectScreen extends StatefulWidget {
  final VaultService vault;
  final Function(CampaignWorld world) onSelectWorld;
  final VoidCallback onReturnToMenu;

  const WorldSelectScreen({
    super.key,
    required this.vault,
    required this.onSelectWorld,
    required this.onReturnToMenu,
  });

  @override
  State<WorldSelectScreen> createState() => _WorldSelectScreenState();
}

class _WorldSelectScreenState extends State<WorldSelectScreen> {
  // Pagination: 2 worlds per page (Page 0: Moon & Mars; Page 1: Deep Space & Convergence)
  int _pageIndex = 0;
  static const int _pageSize = 2;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getWorldBackdrop(String id) {
    switch (id) {
      case "world-1":
        return "assets/images/banner/moon_world.jpg";
      case "world-2":
        return "assets/images/banner/mars-world.jpg";
      case "world-3":
        return "assets/images/banner/deepspace_world.jpg";
      case "world-4":
        return "assets/images/banner/the_coverngence_world.jpg";
      default:
        return "assets/images/banner/moon_world.jpg";
    }
  }

  IconData _getWorldIcon(String id) {
    switch (id) {
      case "world-1":
        return LucideIcons.moon;
      case "world-2":
        return LucideIcons.compass;
      case "world-3":
        return LucideIcons.orbit;
      case "world-4":
        return LucideIcons.sparkles;
      default:
        return LucideIcons.globe;
    }
  }

  @override
  Widget build(BuildContext context) {
    final worlds = widget.vault.worlds;
    final totalLevels = widget.vault.totalLevelsCount;
    final completedLevels = widget.vault.completedLevelsCount;
    final totalPages = (worlds.length / _pageSize).ceil();


    return Scaffold(
      backgroundColor: NotionTheme.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Breadcrumbs & Progress Row
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      AudioService.playBack();
                      widget.onReturnToMenu();
                    },
                    icon: const Icon(LucideIcons.arrowLeft, color: NotionTheme.textSecondary, size: 20),
                    tooltip: "Back to Hub",
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          const TextSpan(
                            children: [
                              TextSpan(
                                text: "Ember Protocol / ",
                                style: TextStyle(
                                  color: NotionTheme.textTertiary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: "Planetary Sectors",
                                style: TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          "SELECT SECTOR FOR INVESTIGATION",
                          style: TextStyle(
                            color: NotionTheme.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Sector Indicator Badge (Touch swipe enabled, no chevrons)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.touchpad, size: 12, color: Color(0xFF38BDF8)),
                        const SizedBox(width: 6),
                        Text(
                          "SECTOR ${_pageIndex + 1} / $totalPages",
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 9.5,
                            fontFamily: NotionTheme.pixelFont,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            totalPages,
                            (idx) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: idx == _pageIndex ? 10 : 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: idx == _pageIndex ? const Color(0xFF38BDF8) : Colors.white24,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  Flexible(
                    child: NotionTheme.badge(
                      text: "Progress: $completedLevels / $totalLevels Solved",
                      icon: LucideIcons.checkCircle2,
                      textColor: NotionTheme.pastelGreen,
                      bgColor: NotionTheme.pastelGreenBg,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Touch Swappable Worlds Row using PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (page) {
                    AudioService.playSwipe();
                    setState(() => _pageIndex = page);
                  },
                  itemCount: totalPages,
                  itemBuilder: (context, pageIdx) {
                    final start = pageIdx * _pageSize;
                    final currentWorlds = worlds.skip(start).take(_pageSize).toList();
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: currentWorlds.map((world) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: _buildNotionWorldCard(world),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),

              // Bottom Sector Step Indicator (with touch navigation)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalPages, (index) {
                  final isActive = index == _pageIndex;
                  return GestureDetector(
                    onTap: () {
                      AudioService.playSwipe();
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: isActive ? 24 : 8,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF38BDF8) : Colors.white24,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotionWorldCard(CampaignWorld world) {
    final completed = world.completedCount;
    final total = world.levels.length;
    final progress = world.progress;
    final backdropPath = _getWorldBackdrop(world.id);
    final worldIcon = _getWorldIcon(world.id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AudioService.playCardSelect();
          widget.onSelectWorld(world);
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: world.themeColor.withValues(alpha: 0.15),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: NotionTheme.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NotionTheme.borderMuted, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Tactical Cyber Accent
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                child: NotionTheme.cyberDivider(color: world.themeColor),
              ),

              // Visual Environment Backdrop
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        child: Image.asset(
                          backdropPath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Ambient Vignette Gradient
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              world.themeColor.withValues(alpha: 0.25),
                              NotionTheme.surfaceCard,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    // Sector Sign / Badge Overlay
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: world.themeColor.withValues(alpha: 0.6), width: 0.8),
                        ),
                        child: Icon(worldIcon, size: 14, color: world.themeColor),
                      ),
                    ),
                    // Status Beacon Glow
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.radio,
                            size: 12,
                            color: world.themeColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            world.id.toUpperCase(),
                            style: TextStyle(
                              color: world.themeColor,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              shadows: const [
                                Shadow(color: Colors.black, blurRadius: 4),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Title & Info with Increased Font Size and Concise Mystery Vibe
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              world.title,
                              style: const TextStyle(
                                color: NotionTheme.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: world.themeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: world.themeColor.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              "$total Missions",
                              style: TextStyle(
                                color: world.themeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 8.5,
                                fontFamily: NotionTheme.pixelFont,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        world.subtitle,
                        style: const TextStyle(
                          color: NotionTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Description
                      Text(
                        world.description,
                        style: const TextStyle(
                          color: NotionTheme.textSecondary,
                          fontSize: 10.5,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Progress Bar & Action Row
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: Colors.white.withValues(alpha: 0.08),
                                valueColor: AlwaysStoppedAnimation<Color>(world.themeColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "$completed / $total",
                            style: TextStyle(
                              color: world.themeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 9.5,
                              fontFamily: NotionTheme.pixelFont,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: world.themeColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "ENTER",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 9.5,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(LucideIcons.arrowRight, size: 10, color: Colors.black),
                              ],
                            ),
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
