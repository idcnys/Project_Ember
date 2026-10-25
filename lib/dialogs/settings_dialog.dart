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
  late bool _bgmEnabled;
  late String _bgmTrack;
  late double _sfxVolume;
  late double _bgmVolume;

  @override
  void initState() {
    super.initState();
    _soundMuted = widget.vault.isSoundMuted;
    _hapticEnabled = widget.vault.isHapticEnabled;
    _bgmEnabled = widget.vault.isBgmEnabled;
    _bgmTrack = widget.vault.bgmTrack;
    _sfxVolume = widget.vault.sfxVolume;
    _bgmVolume = widget.vault.bgmVolume;
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
                title: "Sound & Music Master",
                subtitle: "Tactile audio feedback, telemetry tones & ambient cosmic BGM",
                value: !_soundMuted,
                onChanged: (val) {
                  setState(() => _soundMuted = !val);
                  widget.vault.setSoundMuted(!val);
                },
              ),
              const SizedBox(height: 12),

              // Setting: SFX Volume Slider (50% Default)
              Row(
                children: [
                  const Icon(LucideIcons.volume2, color: NotionTheme.textSecondary, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sound Effects (SFX): ${(_sfxVolume * 100).round()}%",
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
                            value: _sfxVolume,
                            min: 0.0,
                            max: 1.0,
                            onChanged: (val) {
                              setState(() => _sfxVolume = val);
                              widget.vault.setSfxVolume(val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Setting: BGM On/Off Toggle
              _buildSwitchRow(
                icon: _bgmEnabled ? LucideIcons.music : LucideIcons.volumeX,
                title: "Background Music (BGM)",
                subtitle: "Looping sci-fi atmosphere & detective soundtracks",
                value: _bgmEnabled,
                onChanged: (val) {
                  setState(() => _bgmEnabled = val);
                  widget.vault.setBgmEnabled(val);
                },
              ),
              const SizedBox(height: 10),

              if (_bgmEnabled) ...[
                // Setting: BGM Volume Slider (40% Default)
                Row(
                  children: [
                    const Icon(LucideIcons.volume1, color: NotionTheme.pastelPurple, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "BGM Music Volume: ${(_bgmVolume * 100).round()}%",
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
                              activeTrackColor: NotionTheme.pastelPurple,
                              inactiveTrackColor: NotionTheme.surfaceElevated,
                              thumbColor: NotionTheme.pastelPurple,
                            ),
                            child: Slider(
                              value: _bgmVolume,
                              min: 0.0,
                              max: 1.0,
                              onChanged: (val) {
                                setState(() => _bgmVolume = val);
                                widget.vault.setBgmVolume(val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // BGM Track Selection Cards
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 30, bottom: 6),
                      child: Text(
                        "SOUNDTRACK SELECTOR",
                        style: TextStyle(
                          color: NotionTheme.textTertiary,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTrackOption(
                              title: "Space Ambient",
                              subtitle: "Deep sci-fi tone",
                              trackFile: AudioService.trackAmbient,
                              icon: LucideIcons.disc,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTrackOption(
                              title: "Detective Theme",
                              subtitle: "Mystery noir mood",
                              trackFile: AudioService.trackDetective,
                              icon: LucideIcons.search,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

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

  Widget _buildTrackOption({
    required String title,
    required String subtitle,
    required String trackFile,
    required IconData icon,
  }) {
    final bool isSelected = _bgmTrack == trackFile;
    return InkWell(
      onTap: () {
        AudioService.playClick();
        setState(() => _bgmTrack = trackFile);
        widget.vault.setBgmTrack(trackFile);
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? NotionTheme.pastelPurpleBg : NotionTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? NotionTheme.pastelPurple : NotionTheme.borderMuted,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? NotionTheme.pastelPurple : NotionTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? NotionTheme.pastelPurple : NotionTheme.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: NotionTheme.textTertiary,
                      fontSize: 9,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(LucideIcons.check, size: 14, color: NotionTheme.pastelPurple),
          ],
        ),
      ),
    );
  }
}
