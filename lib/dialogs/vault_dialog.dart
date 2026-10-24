import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/clue_data.dart';
import '../services/vault_service.dart';
import '../services/audio_service.dart';
import '../theme/notion_theme.dart';

class VaultDialog extends StatefulWidget {
  final VaultService vault;
  final VoidCallback onClose;

  const VaultDialog({
    super.key,
    required this.vault,
    required this.onClose,
  });

  @override
  State<VaultDialog> createState() => _VaultDialogState();
}

class _VaultDialogState extends State<VaultDialog> {
  String _filter = "ALL";

  @override
  Widget build(BuildContext context) {
    final missions = widget.vault.missions;
    final totalClues = widget.vault.totalCluesCount;
    final unlockedClues = widget.vault.unlockedCluesCount;
    final progress = totalClues > 0 ? (unlockedClues / totalClues) : 0.0;

    // Filter clues
    final allClues = <Map<String, dynamic>>[];
    for (var m in missions) {
      for (var c in m.clues) {
        if (_filter == "ALL") {
          allClues.add({"clue": c, "mission": m});
        } else if (_filter == "UNLOCKED" && c.unlocked) {
          allClues.add({"clue": c, "mission": m});
        } else if (_filter == "MASTER" && c.rarity == ClueRarity.master) {
          allClues.add({"clue": c, "mission": m});
        }
      }
    }

    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          width: 650,
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
              // Tactical hazard stripe header
              // Cyber accent header
              NotionTheme.cyberDivider(color: NotionTheme.pastelTeal),

              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18, top: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        const Icon(LucideIcons.database, color: NotionTheme.pastelTeal, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "Evidence Vault • Physical Scientific Archives",
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
                            widget.onClose();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Progress Bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 5,
                              backgroundColor: NotionTheme.surfaceElevated,
                              valueColor: const AlwaysStoppedAnimation<Color>(NotionTheme.pastelGreen),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "$unlockedClues / $totalClues RECOVERED (${(progress * 100).round()}%)",
                          style: const TextStyle(
                            color: NotionTheme.pastelGreen,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Filter Tabs
                    Row(
                      children: [
                        _buildTab("ALL", "All Clues"),
                        const SizedBox(width: 8),
                        _buildTab("UNLOCKED", "Recovered ($unlockedClues)"),
                        const SizedBox(width: 8),
                        _buildTab("MASTER", "Master Signals"),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Clues Grid / List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: ListView.builder(
                  itemCount: allClues.length,
                  itemBuilder: (context, idx) {
                    final item = allClues[idx];
                    final ClueData clue = item["clue"];
                    final mission = item["mission"];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: clue.unlocked
                            ? NotionTheme.surfaceElevated
                            : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: clue.unlocked
                              ? (clue.rarity == ClueRarity.master
                                  ? NotionTheme.pastelAmber.withValues(alpha: 0.5)
                                  : NotionTheme.borderMuted)
                              : NotionTheme.borderLight,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(right: 8, top: 1),
                            alignment: Alignment.center,
                            child: Icon(
                              clue.unlocked ? LucideIcons.unlock : LucideIcons.lock,
                              size: 15,
                              color: clue.unlocked
                                  ? (clue.rarity == ClueRarity.master
                                      ? NotionTheme.pastelAmber
                                      : NotionTheme.pastelGreen)
                                  : NotionTheme.textTertiary,
                            ),
                          ),
                          NotionTheme.badge(
                            text: clue.code,
                            textColor: clue.unlocked
                                ? (clue.rarity == ClueRarity.master
                                    ? NotionTheme.pastelAmber
                                    : NotionTheme.pastelGreen)
                                : NotionTheme.textTertiary,
                            bgColor: clue.unlocked
                                ? (clue.rarity == ClueRarity.master
                                    ? NotionTheme.pastelAmberBg
                                    : NotionTheme.pastelGreenBg)
                                : Colors.white.withValues(alpha: 0.04),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      clue.unlocked ? LucideIcons.checkCircle2 : LucideIcons.lock,
                                      size: 13,
                                      color: clue.unlocked
                                          ? (clue.rarity == ClueRarity.master
                                              ? NotionTheme.pastelAmber
                                              : NotionTheme.pastelGreen)
                                          : NotionTheme.textTertiary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        clue.unlocked ? clue.title : "Encrypted Telemetry Frame",
                                        style: TextStyle(
                                          color: clue.unlocked ? NotionTheme.textPrimary : NotionTheme.textTertiary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11.5,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      mission.hardware,
                                      style: const TextStyle(
                                        color: NotionTheme.textTertiary,
                                        fontSize: 9.5,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  clue.unlocked
                                      ? clue.desc
                                      : "Evidence corrupted by AI EVA network sweep. Recover by completing scientific puzzle in 3D reconstruction mode.",
                                  style: TextStyle(
                                    color: clue.unlocked
                                        ? NotionTheme.textSecondary
                                        : NotionTheme.textTertiary.withValues(alpha: 0.6),
                                    fontSize: 10.5,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildTab(String key, String label) {
    final isSelected = _filter == key;
    return GestureDetector(
      onTap: () {
        AudioService.playClick();
        setState(() => _filter = key);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? NotionTheme.pastelTealBg : NotionTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? NotionTheme.pastelTeal.withValues(alpha: 0.4) : NotionTheme.borderLight,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? NotionTheme.pastelTeal : NotionTheme.textSecondary,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
