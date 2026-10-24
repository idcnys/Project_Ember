import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/vault_service.dart';
import '../services/audio_service.dart';
import '../theme/notion_theme.dart';

class SettingsDialog extends StatefulWidget {
  final VaultService vault;
  final VoidCallback onClose;

  const SettingsDialog({
    super.key,
    required this.vault,
    required this.onClose,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool _soundMuted;
  late bool _hapticEnabled;
  late double _volume;

  @override
  void initState() {
    super.initState();
    _soundMuted = widget.vault.isSoundMuted;
    _hapticEnabled = widget.vault.isHapticEnabled;
    _volume = widget.vault.volume;
  }

  void _showResetConfirm() {
    AudioService.playAlert();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NotionTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: NotionTheme.pastelRed, width: 1.0),
        ),
        title: const Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: NotionTheme.pastelRed, size: 18),
            SizedBox(width: 8),
            Text(
              "Reset Archive Progress?",
              style: TextStyle(
                color: NotionTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
        content: const Text(
          "This will lock all recovered scientific clues and reset your mission progress back to Mission 01. This action cannot be undone.",
          style: TextStyle(color: NotionTheme.textSecondary, fontSize: 12, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: NotionTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              widget.vault.resetProgress();
              Navigator.pop(ctx);
              AudioService.playSuccess();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Mission progress has been reset."),
                  backgroundColor: NotionTheme.pastelRedBg,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NotionTheme.pastelRed,
              foregroundColor: Colors.black,
            ),
            child: const Text("Confirm Reset"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          width: 520,
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cyber accent header
              NotionTheme.cyberDivider(color: NotionTheme.pastelBlue),

              // Pinned Header
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                child: Row(
                  children: [
                    const Icon(LucideIcons.settings, color: NotionTheme.pastelBlue, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "System Settings & Telemetry",
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
              ),
              const Divider(color: NotionTheme.borderLight, height: 1),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

              // Setting: Sound FX Toggle
              _buildSwitchRow(
                icon: _soundMuted ? LucideIcons.volumeX : LucideIcons.volume2,
                title: "Sound Effects & Synthesizer",
                subtitle: "Tactile audio feedback for buttons, terminal, and engines",
                value: !_soundMuted,
                onChanged: (val) {
                  setState(() => _soundMuted = !val);
                  widget.vault.setSoundMuted(!val);
                },
              ),
              const SizedBox(height: 12),

              // Setting: Volume Slider
              Row(
                children: [
                  const Icon(LucideIcons.sliders, color: NotionTheme.textSecondary, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Audio Volume: ${(_volume * 100).round()}%",
                          style: const TextStyle(
                            color: NotionTheme.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            activeTrackColor: NotionTheme.pastelBlue,
                            inactiveTrackColor: NotionTheme.surfaceElevated,
                            thumbColor: NotionTheme.pastelBlue,
                          ),
                          child: Slider(
                            value: _volume,
                            min: 0.0,
                            max: 1.0,
                            onChanged: (val) {
                              setState(() => _volume = val);
                              widget.vault.setVolume(val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Setting: Haptic Vibrations
              _buildSwitchRow(
                icon: LucideIcons.vibrate,
                title: "Haptic Vibration Feedback",
                subtitle: "Mobile vibration pulses during puzzle locks & warp jumps",
                value: _hapticEnabled,
                onChanged: (val) {
                  setState(() => _hapticEnabled = val);
                  widget.vault.toggleHaptics();
                },
              ),
              const SizedBox(height: 12),

              // Setting: Display Orientation
              Row(
                children: [
                  const Icon(LucideIcons.compass, color: NotionTheme.pastelGreen, size: 18),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Orientation Mode",
                          style: TextStyle(
                            color: NotionTheme.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Strict Landscape (Optimized for Cockpit & Field Exploration)",
                          style: TextStyle(color: NotionTheme.textTertiary, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  NotionTheme.badge(
                    text: "LOCKED",
                    icon: LucideIcons.lock,
                    textColor: NotionTheme.pastelGreen,
                    bgColor: NotionTheme.pastelGreenBg,
                  ),
                ],
              ),
              const Divider(color: NotionTheme.borderLight, height: 24),

              // Danger Zone: Reset & Done
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _showResetConfirm,
                    icon: const Icon(LucideIcons.rotateCcw, color: NotionTheme.pastelRed, size: 13),
                    label: const Text(
                      "Reset Progress",
                      style: TextStyle(color: NotionTheme.pastelRed, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: NotionTheme.pastelRed.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      AudioService.playClick();
                      widget.onClose();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NotionTheme.surfaceElevated,
                      foregroundColor: NotionTheme.textPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: NotionTheme.borderMuted),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                    ),
                    child: const Text("Done"),
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

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: NotionTheme.textSecondary, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: NotionTheme.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: NotionTheme.textTertiary, fontSize: 10),
              ),
            ],
          ),
        ),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            onChanged: (v) {
              AudioService.playClick();
              onChanged(v);
            },
            activeThumbColor: NotionTheme.pastelBlue,
            activeTrackColor: NotionTheme.pastelBlueBg,
          ),
        ),
      ],
    );
  }
}
