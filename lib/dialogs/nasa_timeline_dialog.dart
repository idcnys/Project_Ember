import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/nasa_timeline_data.dart';
import '../services/audio_service.dart';
import '../theme/notion_theme.dart';

class NasaTimelineDialog extends StatefulWidget {
  final VoidCallback onClose;

  const NasaTimelineDialog({
    super.key,
    required this.onClose,
  });

  @override
  State<NasaTimelineDialog> createState() => _NasaTimelineDialogState();
}

class _NasaTimelineDialogState extends State<NasaTimelineDialog> {
  final List<TimelineEra> _eras = NasaTimelineCatalog.getEras();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          width: 660,
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
                    const Icon(LucideIcons.history, color: NotionTheme.pastelAmber, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "NASA Historical Hardware Directory (1960–Present)",
                        style: TextStyle(
                          color: NotionTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Search Box
                    Container(
                      width: 160,
                      height: 28,
                      decoration: BoxDecoration(
                        color: NotionTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: NotionTheme.borderLight),
                      ),
                      child: TextField(
                        style: const TextStyle(color: NotionTheme.textPrimary, fontSize: 11),
                        decoration: const InputDecoration(
                          hintText: "Search hardware...",
                          hintStyle: TextStyle(color: NotionTheme.textTertiary, fontSize: 10.5),
                          prefixIcon: Icon(LucideIcons.search, color: NotionTheme.textTertiary, size: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 6),
                        ),
                        onChanged: (val) {
                          setState(() => _searchQuery = val.toLowerCase());
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
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
              ),
              const Divider(color: NotionTheme.borderLight, height: 16),

              // Timeline List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: ListView.builder(
                  itemCount: _eras.length,
                  itemBuilder: (context, eraIdx) {
                    final era = _eras[eraIdx];
                    final filteredItems = era.items.where((item) {
                      if (_searchQuery.isEmpty) return true;
                      return item.name.toLowerCase().contains(_searchQuery) ||
                          item.target.toLowerCase().contains(_searchQuery) ||
                          item.details.toLowerCase().contains(_searchQuery) ||
                          item.year.contains(_searchQuery);
                    }).toList();

                    if (filteredItems.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Era Title
                        Container(
                          margin: const EdgeInsets.only(top: 8, bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: NotionTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: NotionTheme.borderLight),
                          ),
                          child: Row(
                            children: [
                              Text(
                                era.title,
                                style: const TextStyle(
                                  color: NotionTheme.pastelAmber,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "• ${era.subtitle}",
                                  style: const TextStyle(
                                    color: NotionTheme.textTertiary,
                                    fontSize: 10,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Era Items
                        ...filteredItems.map((item) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B1B1D),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: NotionTheme.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    NotionTheme.badge(
                                      text: item.year,
                                      textColor: NotionTheme.pastelBlue,
                                      bgColor: NotionTheme.pastelBlueBg,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: const TextStyle(
                                          color: NotionTheme.textPrimary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ),
                                    NotionTheme.badge(
                                      text: item.status,
                                      textColor: NotionTheme.pastelGreen,
                                      bgColor: NotionTheme.pastelGreenBg,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "TARGET: ${item.target}  •  TYPE: ${item.type}",
                                        style: const TextStyle(
                                          color: NotionTheme.textSecondary,
                                          fontSize: 9.5,
                                          fontFamily: 'monospace',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.details,
                                  style: const TextStyle(
                                    color: NotionTheme.textSecondary,
                                    fontSize: 10.5,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
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
}
