import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/campaign_data.dart';
import '../models/space_detective_data.dart';
import '../services/audio_service.dart';
import '../services/vault_service.dart';
import '../theme/notion_theme.dart';

class ModelMuseumScreen extends StatefulWidget {
  final VaultService vault;
  final Function(CampaignLevel) onSelectModel;
  final VoidCallback onReturnToMenu;

  const ModelMuseumScreen({
    super.key,
    required this.vault,
    required this.onSelectModel,
    required this.onReturnToMenu,
  });

  @override
  State<ModelMuseumScreen> createState() => _ModelMuseumScreenState();
}

class _ModelMuseumScreenState extends State<ModelMuseumScreen> {
  String _selectedFilter = "3D"; // "3D", "ALL", "MOON", "MARS", "DEEP", "ORBITAL"
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CampaignLevel> get _allLevels {
    final List<CampaignLevel> list = [];
    for (var world in widget.vault.worlds) {
      list.addAll(world.levels);
    }
    return list;
  }

  List<CampaignLevel> get _filteredLevels {
    return _allLevels.where((level) {
      // Filter category
      if (_selectedFilter == "3D" && !level.has3dModel) return false;
      if (_selectedFilter == "MOON" && level.worldId != "world-1") return false;
      if (_selectedFilter == "MARS" && level.worldId != "world-2") return false;
      if (_selectedFilter == "DEEP" && level.worldId != "world-3") return false;
      if (_selectedFilter == "ORBITAL" && level.worldId != "world-4") return false;

      // Filter search
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchSpacecraft = level.spacecraft.toLowerCase().contains(q);
        final matchTitle = level.title.toLowerCase().contains(q);
        final matchCode = level.code.toLowerCase().contains(q);
        final matchTarget = level.targetBody.toLowerCase().contains(q);
        final matchSubsystem = level.subsystem.toLowerCase().contains(q);
        if (!matchSpacecraft && !matchTitle && !matchCode && !matchTarget && !matchSubsystem) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Color _getWorldColor(String worldId) {
    switch (worldId) {
      case "world-1":
        return const Color(0xFF38BDF8); // Moon Cyan
      case "world-2":
        return const Color(0xFFFB923C); // Mars Orange
      case "world-3":
        return const Color(0xFF818CF8); // Deep Space Indigo
      case "world-4":
        return const Color(0xFFA855F7); // Convergence Purple
      default:
        return const Color(0xFF38BDF8);
    }
  }

  String _getWorldName(String worldId) {
    switch (worldId) {
      case "world-1":
        return "THE MOON";
      case "world-2":
        return "MARS";
      case "world-3":
        return "DEEP SPACE";
      case "world-4":
        return "OBSERVATORIES";
      default:
        return "SPACE SECTOR";
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredLevels;
    final total3dCount = _allLevels.where((l) => l.has3dModel).length;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Stack(
        children: [
          // 1. Subtle High-Tech Deep Space Gradient & Grid
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.4),
                  radius: 1.2,
                  colors: [
                    Color(0xFF111827),
                    Color(0xFF090D1A),
                    Color(0xFF030712),
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Content Column
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header HUD Bar
                _buildHeaderBar(total3dCount),

                // Category & Search Filter Strip
                _buildFilterStrip(total3dCount),

                // Vertical Cards Gallery
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (ctx, idx) => const SizedBox(height: 10),
                          itemBuilder: (ctx, idx) {
                            final level = filtered[idx];
                            return _buildModelCard(level);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TOP HEADER HUD BAR
  // ==========================================
  Widget _buildHeaderBar(int total3dCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          // Back Button to Main Menu
          OutlinedButton.icon(
            onPressed: () {
              AudioService.playBack();
              widget.onReturnToMenu();
            },
            icon: const Icon(LucideIcons.arrowLeft, size: 14),
            label: const Text(
              "MAIN MENU",
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
          const SizedBox(width: 12),

          // Museum Title & Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.box, size: 13, color: Color(0xFFF59E0B)),
                SizedBox(width: 6),
                Text(
                  "MODEL MUSEUM",
                  style: TextStyle(
                    color: Color(0xFFF59E0B),
                    fontFamily: NotionTheme.pixelFont,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              "NASA 3D Spacecraft, Rovers & Telescopes Gallery",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Total 3D Models Loaded Counter Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "$total3dCount 3D GLB MODELS READY",
                  style: const TextStyle(
                    color: Color(0xFF22C55E),
                    fontFamily: NotionTheme.pixelFont,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FILTER STRIP (CATEGORIES & SEARCH)
  // ==========================================
  Widget _buildFilterStrip(int total3dCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1D),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: Row(
        children: [
          // Filter Chips
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip("3D", "3D GLB MODELS ($total3dCount)", LucideIcons.box, const Color(0xFF38BDF8)),
                  const SizedBox(width: 6),
                  _buildFilterChip("ALL", "ALL HARDWARE (24)", LucideIcons.layers, Colors.white70),
                  const SizedBox(width: 6),
                  _buildFilterChip("MOON", "THE MOON (7)", LucideIcons.moon, const Color(0xFF38BDF8)),
                  const SizedBox(width: 6),
                  _buildFilterChip("MARS", "MARS (7)", LucideIcons.flame, const Color(0xFFFB923C)),
                  const SizedBox(width: 6),
                  _buildFilterChip("DEEP", "DEEP SPACE (7)", LucideIcons.telescope, const Color(0xFF818CF8)),
                  const SizedBox(width: 6),
                  _buildFilterChip("ORBITAL", "OBSERVATORIES (3)", LucideIcons.eye, const Color(0xFFA855F7)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Search Input Field
          SizedBox(
            width: 180,
            height: 32,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              style: const TextStyle(color: Colors.white, fontSize: 11),
              decoration: InputDecoration(
                hintText: "Search spacecraft...",
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                prefixIcon: const Icon(LucideIcons.search, size: 13, color: Colors.white54),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 12, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = "");
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, IconData icon, Color color) {
    final bool isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () {
        AudioService.playClick();
        setState(() => _selectedFilter = key);
      },
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color : Colors.white12,
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: isSelected ? color : Colors.white54),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 8.5,
                fontFamily: NotionTheme.pixelFont,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // VERTICAL MODEL CARD
  // ==========================================
  Widget _buildModelCard(CampaignLevel level) {
    final Color worldColor = _getWorldColor(level.worldId);
    final String worldName = _getWorldName(level.worldId);
    final SpaceDetectiveCase? detectiveCase = SpaceDetectiveCatalog.getCaseByCode(level.code);

    return InkWell(
      onTap: () {
        AudioService.playSuccess();
        widget.onSelectModel(level);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1322),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: worldColor.withValues(alpha: 0.35), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Spacecraft Banner Thumbnail with 3D format overlay badge
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Image.asset(
                    level.hardwareImagePath ?? level.bannerPath,
                    width: 120,
                    height: 82,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      width: 120,
                      height: 82,
                      color: const Color(0xFF1E293B),
                      child: const Icon(LucideIcons.box, color: Colors.white38, size: 28),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: level.has3dModel ? const Color(0xFF22C55E) : const Color(0xFFFBBF24),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            level.has3dModel ? LucideIcons.box : LucideIcons.camera,
                            size: 9,
                            color: level.has3dModel ? const Color(0xFF22C55E) : const Color(0xFFFBBF24),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            level.has3dModel ? "3D GLB" : "PHOTO",
                            style: TextStyle(
                              color: level.has3dModel ? const Color(0xFF22C55E) : const Color(0xFFFBBF24),
                              fontFamily: NotionTheme.pixelFont,
                              fontSize: 7,
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
            const SizedBox(width: 14),

            // Center: Hardware Metadata & Science Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: worldColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "${level.code} • $worldName",
                          style: TextStyle(
                            color: worldColor,
                            fontFamily: NotionTheme.pixelFont,
                            fontSize: 7.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          level.targetBody.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontFamily: NotionTheme.pixelFont,
                            fontSize: 7.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (level.isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.checkCheck, size: 10, color: Color(0xFF22C55E)),
                              SizedBox(width: 3),
                              Text(
                                "SOLVED",
                                style: TextStyle(
                                  color: Color(0xFF22C55E),
                                  fontFamily: NotionTheme.pixelFont,
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Spacecraft Name
                  Text(
                    level.spacecraft,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),

                  // Mission Title
                  Text(
                    level.title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // Subsystem & Physical Evidence Tag
                  Row(
                    children: [
                      Icon(LucideIcons.cpu, size: 11, color: worldColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "SUBSYSTEM: ${level.subsystem.toUpperCase()}",
                          style: TextStyle(
                            color: worldColor,
                            fontFamily: NotionTheme.pixelFont,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Mission Science snippet if available
                  if (detectiveCase != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      detectiveCase.missionScience,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 9.5,
                        height: 1.25,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Right: Inspect in 3D Action Button
            ElevatedButton.icon(
              onPressed: () {
                AudioService.playSuccess();
                widget.onSelectModel(level);
              },
              icon: Icon(level.has3dModel ? LucideIcons.box : LucideIcons.eye, size: 13),
              label: Text(
                level.has3dModel ? "INSPECT 3D" : "VIEW HUD",
                style: const TextStyle(
                  fontFamily: NotionTheme.pixelFont,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: worldColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.searchX, size: 36, color: Colors.white30),
          const SizedBox(height: 10),
          const Text(
            "No spacecraft found matching filter",
            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            "Try clearing your search keyword or switching categories",
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = "";
                _selectedFilter = "3D";
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF38BDF8),
              side: const BorderSide(color: Color(0xFF38BDF8)),
            ),
            child: const Text("Reset Filters", style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
