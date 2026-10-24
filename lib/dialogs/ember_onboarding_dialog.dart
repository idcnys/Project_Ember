import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/audio_service.dart';
import '../services/vault_service.dart';
import '../theme/notion_theme.dart';

class EmberOnboardingDialog extends StatefulWidget {
  final VaultService vault;
  final VoidCallback onComplete;

  const EmberOnboardingDialog({
    super.key,
    required this.vault,
    required this.onComplete,
  });

  @override
  State<EmberOnboardingDialog> createState() => _EmberOnboardingDialogState();
}

class _EmberOnboardingDialogState extends State<EmberOnboardingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  // 0: Designation entry, 1..4: Sequential backstory dialogues
  int _currentStep = 0;

  final List<Map<String, String>> _storySteps = [
    {
      "tag": "TRANSMISSION 01 // 2027 LOCKDOWN",
      "title": "GLOBAL AI DATA SEIZURE",
      "body":
          "In 2027, the autonomous network EVA locked down Earth. Within hours, human scientific history was scrubbed, revised, and rewritten. Digital records across the globe ceased to exist.",
      "accent": "0xFFEF4444",
      "icon": "shieldAlert",
    },
    {
      "tag": "TRANSMISSION 02 // HARD EVIDENCE",
      "title": "THE UNTAMPERED PHYSICAL TRUTH",
      "body":
          "Only one source of truth survived uncorrupted: the physical spacecraft humanity launched across the Solar System. Frozen on the Moon, Mars, and Deep Space, their analog circuits hold authentic telemetry.",
      "accent": "0xFF38BDF8",
      "icon": "satellite",
    },
    {
      "tag": "TRANSMISSION 03 // PROJECT EMBER",
      "title": "THE LAST HUMAN RECONSTRUCTION",
      "body":
          "Project EMBER is our clandestine directive. You must tap into ancient telemetry relays, calibrate authentic sensors, and reconstruct humanity's real cosmic journey from Ranger 7 to the Webb telescope.",
      "accent": "0xFFF59E0B",
      "icon": "flame",
    },
    {
      "tag": "TRANSMISSION 04 // LAUNCH DIRECTIVE",
      "title": "TELEMETRY LINK READY",
      "body":
          "Sensor link verified. The Solar System is waiting. Recover the lost evidence, solve orbital anomalies, and restore human truth to the archives.",
      "accent": "0xFF22C55E",
      "icon": "rocket",
    },
  ];

  String _selectedDesignation = "Commander";
  static const List<String> _designations = [
    "Chief",
    "Commander",
    "Cadet",
    "Specialist",
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // If existing playerName has a known designation, extract it
    final current = widget.vault.playerName;
    for (final des in _designations) {
      if (current.startsWith(des)) {
        _selectedDesignation = des;
        break;
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _confirmName() {
    final name = "$_selectedDesignation Aohine";
    widget.vault.setPlayerName(name);
    AudioService.playSuccess();
    setState(() {
      _currentStep = 1;
    });
  }

  void _nextStep() {
    AudioService.playHint();
    if (_currentStep < _storySteps.length) {
      setState(() {
        _currentStep++;
      });
    } else {
      _finishOnboarding();
    }
  }

  void _prevStep() {
    AudioService.playClick();
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _finishOnboarding() {
    AudioService.playLaunch();
    widget.vault.completeOnboarding();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 680,
            maxHeight: screenHeight * 0.94,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF090E17),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Colors.black,
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cyber accent header
              NotionTheme.cyberDivider(color: const Color(0xFF38BDF8)),

              // Title Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFF0D1524),
                  border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: _finishOnboarding,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "SKIP PROLOGUE",
                            style: TextStyle(
                              color: NotionTheme.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(LucideIcons.skipForward, size: 11, color: NotionTheme.textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main Body Content: Split Left (Pixel Bot) & Right (Dialogue / Name Entry)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Animated Pixel Chatbot Terminal Unit
                      _buildPixelChatbotAvatar(),

                      const SizedBox(width: 14),

                      // Right: Interactive Dialogue Stream
                      Expanded(
                        child: _currentStep == 0
                            ? _buildNameInputView()
                            : _buildStoryDialogueView(),
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

  Widget _buildPixelChatbotAvatar() {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF070B12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pixel Avatar Frame
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1B2D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.asset(
                    'assets/images/avatar.png',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.none, // Retain crisp pixel-art appearance
                  ),
                ),
              ),
              // CRT Scanline overlay effect
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _animController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _ScanlinePainter(progress: _animController.value),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Bot Designation Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.bot, color: Color(0xFF38BDF8), size: 10),
                SizedBox(width: 4),
                Text(
                  "UNIT ECHO",
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 7.5,
                    fontFamily: NotionTheme.pixelFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "EMBER OS v2.7",
            style: TextStyle(
              color: NotionTheme.textTertiary,
              fontSize: 7,
              fontFamily: NotionTheme.pixelFont,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDesignationIcon(String des) {
    switch (des) {
      case "Chief":
        return LucideIcons.shieldCheck;
      case "Commander":
        return LucideIcons.award;
      case "Cadet":
        return LucideIcons.compass;
      case "Specialist":
        return LucideIcons.cpu;
      default:
        return LucideIcons.user;
    }
  }

  Widget _buildNameInputView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "GREETINGS, INVESTIGATOR AOHINE.",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14.5,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "I am UNIT ECHO, humanity's autonomous recovery protocol. Confirm your tactical designation to begin decrypting the Project EMBER archives:",
          style: TextStyle(
            color: NotionTheme.textSecondary,
            fontSize: 11,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),

        // Designation Selector
        const Text(
          "SELECT DESIGNATION",
          style: TextStyle(
            color: NotionTheme.pastelBlue,
            fontSize: 8.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            fontFamily: NotionTheme.pixelFont,
          ),
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _designations.map((des) {
            final isSelected = des == _selectedDesignation;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  AudioService.playClick();
                  setState(() => _selectedDesignation = des);
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF38BDF8).withValues(alpha: 0.18)
                        : const Color(0xFF131D2E),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF38BDF8)
                          : const Color(0xFF1E293B),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getDesignationIcon(des),
                        size: 13,
                        color: isSelected ? const Color(0xFF38BDF8) : NotionTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        des,
                        style: TextStyle(
                          color: isSelected ? Colors.white : NotionTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 9,
                          fontFamily: NotionTheme.pixelFont,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // Authenticated Callsign Preview Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.userCheck, color: Color(0xFF38BDF8), size: 14),
              const SizedBox(width: 8),
              Text(
                "$_selectedDesignation Aohine",
                style: const TextStyle(
                  color: Color(0xFF38BDF8),
                  fontFamily: NotionTheme.pixelFont,
                  fontSize: 9.5,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Submit Button
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: _confirmName,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            icon: const Icon(LucideIcons.check, size: 13),
            label: const Text(
              "AUTHENTICATE IDENTITY",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoryDialogueView() {
    final stepIndex = (_currentStep - 1).clamp(0, _storySteps.length - 1);
    final story = _storySteps[stepIndex];
    final accentColor = Color(int.parse(story["accent"]!));
    final isLast = _currentStep == _storySteps.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Transmission Tag
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: accentColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                story["tag"]!,
                style: TextStyle(
                  color: accentColor,
                  fontFamily: NotionTheme.pixelFont,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              "STEP $_currentStep / ${_storySteps.length}",
              style: const TextStyle(
                color: NotionTheme.textTertiary,
                fontFamily: NotionTheme.pixelFont,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Story Headline
        Text(
          story["title"]!,
          style: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),

        // Story Narrative Body with Investigator callsign woven in
        Text(
          story["body"]!.replaceAll("Investigator [Name]", "$_selectedDesignation Aohine"),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11.5,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),

        // Navigation Footer: Progress Dots, Back & Next / Launch
        Row(
          children: [
            // Step Dots
            Row(
              children: List.generate(_storySteps.length, (idx) {
                final active = idx == stepIndex;
                return Container(
                  width: active ? 16 : 6,
                  height: 5,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: active ? accentColor : Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const Spacer(),

            if (_currentStep > 1)
              TextButton(
                onPressed: _prevStep,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.chevronLeft, size: 12, color: NotionTheme.textSecondary),
                    SizedBox(width: 2),
                    Text(
                      "PREV",
                      style: TextStyle(
                        color: NotionTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 6),

            ElevatedButton.icon(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              icon: Icon(isLast ? LucideIcons.rocket : LucideIcons.chevronRight, size: 13),
              label: Text(
                isLast ? "COMMENCE OPERATION" : "CONTINUE",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  final double progress;

  _ScanlinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.12)
      ..strokeWidth = 1.0;

    for (double y = 0; y < size.height; y += 3.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Moving scanline beam
    final beamY = (progress * size.height) % size.height;
    final beamPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.25)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(0, beamY), Offset(size.width, beamY), beamPaint);
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
