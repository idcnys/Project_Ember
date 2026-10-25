import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/space_detective_data.dart';
import '../services/vault_service.dart';
import '../services/audio_service.dart';
import '../theme/notion_theme.dart';

class SpaceDetectiveDossierPanel extends StatefulWidget {
  final SpaceDetectiveCase caseData;
  final VaultService vault;
  final VoidCallback? onClose;
  final Function? onVerdictSolved;
  final VoidCallback? onOpenSubsystemPuzzle;
  final bool isSubsystemDiagnosed;
  final int initialTab;

  const SpaceDetectiveDossierPanel({
    super.key,
    required this.caseData,
    required this.vault,
    this.onClose,
    this.onVerdictSolved,
    this.onOpenSubsystemPuzzle,
    this.isSubsystemDiagnosed = false,
    this.initialTab = 0,
  });

  @override
  State<SpaceDetectiveDossierPanel> createState() => _SpaceDetectiveDossierPanelState();
}

class _SpaceDetectiveDossierPanelState extends State<SpaceDetectiveDossierPanel> {
  int _selectedTab = 0; // 0: BRIEFING, 1: MEMORY CARD, 2: CLUES, 3: VERDICT
  int _unlockedClues = 1; // Default 1 clue open
  bool _recallMode = false;
  final Set<int> _revealedCards = {};

  final ScrollController _scrollController = ScrollController();

  // Debrief & Verdict state
  int? _selectedOptionIndex;
  String _selectedConfidence = "LIKELY";
  bool _isSubmitted = false;
  int _finalScore = 0;
  int _starsAwarded = 0;
  String _rankTitle = "";
  Color _rankColor = const Color(0xFF38BDF8);

  @override
  void initState() {
    super.initState();
    if (widget.initialTab != 0) {
      _selectedTab = widget.initialTab;
    }
    // Check if this level is already completed
    final level = widget.vault.getLevelById(widget.caseData.levelId);
    if (level != null && level.isCompleted) {
      _unlockedClues = 3;
      _isSubmitted = true;
      _finalScore = (level.stars == 3) ? 10 : (level.stars == 2 ? 8 : 6);
      _starsAwarded = level.stars;
      _evaluateRank(_finalScore);
    } else if (widget.isSubsystemDiagnosed) {
      _unlockedClues = 3;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTab(int index) {
    setState(() => _selectedTab = index);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
    }
  }

  @override
  void didUpdateWidget(covariant SpaceDetectiveDossierPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      _scrollToTab(widget.initialTab);
    }
    if (widget.isSubsystemDiagnosed && !oldWidget.isSubsystemDiagnosed) {
      setState(() {
        _unlockedClues = 3;
      });
    }
  }

  void _evaluateRank(int score) {
    if (score >= 9) {
      _rankTitle = "MISSION DETECTIVE";
      _rankColor = const Color(0xFFFBBF24); // Gold
    } else if (score >= 7) {
      _rankTitle = "FIELD INVESTIGATOR";
      _rankColor = const Color(0xFF22C55E); // Green
    } else if (score >= 4) {
      _rankTitle = "JUNIOR ANALYST";
      _rankColor = const Color(0xFF38BDF8); // Cyan
    } else {
      _rankTitle = "SIGNAL LOST";
      _rankColor = const Color(0xFFEF4444); // Red
    }
  }

  Color get _worldAccentColor {
    switch (widget.caseData.worldId) {
      case "world-1":
        return const Color(0xFF38BDF8); // Moon Cyan
      case "world-2":
        return const Color(0xFFFB923C); // Mars Warm Orange
      case "world-3":
        return const Color(0xFF818CF8); // Deep Space Indigo
      case "world-4":
        return const Color(0xFFA855F7); // Convergence Purple
      default:
        return const Color(0xFF38BDF8);
    }
  }

  void _revealNextClue() {
    if (_unlockedClues < 3) {
      AudioService.playSuccess();
      setState(() {
        _unlockedClues++;
      });
      // Also register clues in vault
      final prefix = widget.caseData.levelId;
      widget.vault.unlockClues(["$prefix-c0$_unlockedClues"]);
    }
  }

  void _submitVerdict() {
    if (_selectedOptionIndex == null) {
      AudioService.playAlert();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a scientific hypothesis before submitting verdict."),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    AudioService.playLevelComplete();

    // Calculate score based on Page 2 rubric (Max 10 points):
    // 2 — identify the anomaly
    // 3 — connect at least two clues
    // 2 — reject an unsupported explanation (correct hypothesis)
    // 2 — suggest a useful verification test
    // 1 — express uncertainty honestly when evidence is incomplete
    int score = 0;

    // +2 for identifying the anomaly (reading briefing & engaging investigation)
    score += 2;

    // +3 for connecting clues (at least 2 clues unlocked or subsystem diagnosed)
    if (_unlockedClues >= 2 || widget.isSubsystemDiagnosed) {
      score += 3;
    } else {
      score += 1;
    }

    final selected = widget.caseData.challengeOptions[_selectedOptionIndex!];
    if (selected.isCorrect) {
      // +2 for rejecting unsupported explanation & finding correct cause
      score += 2;
    }

    // +2 for verification test consideration
    score += 2;

    // +1 for expressing honest uncertainty when evidence is incomplete
    if (widget.caseData.confidenceLevel == "Unresolved" || widget.caseData.confidenceLevel == "Possible") {
      if (_selectedConfidence == "UNRESOLVED" || _selectedConfidence == "POSSIBLE") {
        score += 1;
      }
    } else {
      if (_selectedConfidence == widget.caseData.confidenceLevel.toUpperCase()) {
        score += 1;
      }
    }

    int stars = 1;
    if (score >= 9) {
      stars = 3;
    } else if (score >= 7) {
      stars = 2;
    }

    setState(() {
      _finalScore = score;
      _starsAwarded = stars;
      _isSubmitted = true;
      _evaluateRank(score);
    });

    _notifyVerdictSolved(score, stars, _rankTitle);
  }

  void _notifyVerdictSolved(int score, int stars, String rank) {
    if (widget.onVerdictSolved == null) return;
    try {
      (widget.onVerdictSolved as dynamic)(score, stars, rank);
    } catch (_) {
      try {
        (widget.onVerdictSolved as dynamic)(score, stars);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _worldAccentColor;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xF2080D1A), // Deep high-tech sci-fi slate
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top High-Tech Accent Bar
            NotionTheme.cyberDivider(color: accent),

            // Scrollable Viewport: Title & Tab options scroll with active tab content to give extra viewspace
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Scrollable Dossier Header (Title, Scenario, Code Badge, Close Button)
                    _buildHeader(accent),

                    // Scrollable Tab Options Bar (1. BRIEFING / 2. MEMORY / 3. CLUES / 4. VERDICT)
                    _buildTabBar(accent),

                    // Active Tab Content (Focused Tab View)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: _buildTabBody(accent),
                    ),
                  ],
                ),
              ),
            ),

            // Pinned Bottom Status Strip
            _buildBottomStatus(accent),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB BODY ROUTER (FOCUSED TAB VIEW)
  // ==========================================
  Widget _buildTabBody(Color accent) {
    switch (_selectedTab) {
      case 0:
        return _buildBriefingTab(accent);
      case 1:
        return _buildMemoryCardTab(accent);
      case 2:
        return _buildEvidenceLockTab(accent);
      case 3:
        return _buildVerdictTab(accent);
      default:
        return const SizedBox.shrink();
    }
  }

  // ==========================================
  // HEADER
  // ==========================================
  Widget _buildHeader(Color accent) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        border: Border(bottom: BorderSide(color: accent.withValues(alpha: 0.2))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Code Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.caseData.code,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    fontFamily: NotionTheme.pixelFont,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // World Tagline
              Expanded(
                child: Text(
                  widget.caseData.worldTitle.toUpperCase(),
                  style: TextStyle(
                    color: accent,
                    fontSize: 9,
                    fontFamily: NotionTheme.pixelFont,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Close / Collapse Button
              if (widget.onClose != null)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  icon: const Icon(LucideIcons.x, size: 16, color: Colors.white70),
                  tooltip: "Collapse Dossier Beside Viewer",
                  onPressed: () {
                    AudioService.playBack();
                    widget.onClose!();
                  },
                ),
            ],
          ),
          const SizedBox(height: 4),

          // Title
          Text(
            widget.caseData.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Scenario
          Row(
            children: [
              Icon(LucideIcons.telescope, size: 11, color: accent.withValues(alpha: 0.8)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  "SCENARIO: ${widget.caseData.scenario}",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 9.5,
                    fontFamily: NotionTheme.pixelFont,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB BAR
  // ==========================================
  Widget _buildTabBar(Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF060A14),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          _buildTabBtn(0, "1. BRIEFING", LucideIcons.radio, accent),
          const SizedBox(width: 4),
          _buildTabBtn(1, "2. MEMORY", LucideIcons.layers, accent),
          const SizedBox(width: 4),
          _buildTabBtn(2, "3. CLUES ($_unlockedClues/3)", LucideIcons.key, accent),
          const SizedBox(width: 4),
          _buildTabBtn(3, _isSubmitted ? "4. DEBRIEF" : "4. VERDICT", LucideIcons.award, accent),
        ],
      ),
    );
  }

  Widget _buildTabBtn(int index, String label, IconData icon, Color accent) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          AudioService.playClick();
          _scrollToTab(index);
        },
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? accent.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? accent : Colors.white12,
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 12,
                color: isSelected ? accent : Colors.white54,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 7.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontFamily: NotionTheme.pixelFont,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: BRIEFING (STORY SETUP)
  // ==========================================
  Widget _buildBriefingTab(Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // World Guideline Motto
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: accent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.shieldAlert, size: 13, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.caseData.worldTagline,
                    style: TextStyle(
                      color: accent,
                      fontSize: 9.5,
                      fontFamily: NotionTheme.pixelFont,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Mission Control Teletype Box
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF030712),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.4)),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "MISSION CONTROL BRIEFING // SECURE CHAT",
                      style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontFamily: NotionTheme.pixelFont,
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.caseData.briefing,
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Pedagogical Directive
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.compass, size: 13, color: Color(0xFF38BDF8)),
                    SizedBox(width: 6),
                    Text(
                      "INVESTIGATOR DIRECTIVE",
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontFamily: NotionTheme.pixelFont,
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "1. Rotate and examine the spacecraft in the 3D viewer beside this console.\n"
                  "2. Study the Six-Field Mission Memory Card to learn the operational science.\n"
                  "3. Open clues sequentially in Evidence Lock.\n"
                  "4. Formulate your hypothesis and submit your verdict.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Button to Memory Card
          ElevatedButton.icon(
            onPressed: () {
              AudioService.playClick();
              _scrollToTab(1);
            },
            icon: const Icon(LucideIcons.arrowRight, size: 14),
            label: Text(
              "STUDY 6-FIELD MEMORY CARD",
              style: TextStyle(
                fontFamily: NotionTheme.pixelFont,
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      );
  }

  // ==========================================
  // TAB 2: SIX-FIELD MISSION MEMORY CARD
  // ==========================================
  Widget _buildMemoryCardTab(Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header description
          Row(
            children: [
              Expanded(
                child: Text(
                  "THE SIX-FIELD MISSION MEMORY SYSTEM",
                  style: TextStyle(
                    color: accent,
                    fontFamily: NotionTheme.pixelFont,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  AudioService.playClick();
                  setState(() {
                    _recallMode = !_recallMode;
                    if (!_recallMode) _revealedCards.clear();
                  });
                },
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: _recallMode ? const Color(0xFFF59E0B).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _recallMode ? const Color(0xFFF59E0B) : Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _recallMode ? LucideIcons.eyeOff : LucideIcons.eye,
                        size: 11,
                        color: _recallMode ? const Color(0xFFF59E0B) : Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _recallMode ? "RECALL ON" : "RECALL TEST",
                        style: TextStyle(
                          color: _recallMode ? const Color(0xFFF59E0B) : Colors.white70,
                          fontFamily: NotionTheme.pixelFont,
                          fontSize: 7.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Six Interactive Fields
          _buildMemoryFieldCard(1, "1. MISSION SCIENCE", "What question was investigated?", widget.caseData.missionScience, LucideIcons.telescope, const Color(0xFF38BDF8)),
          const SizedBox(height: 6),
          _buildMemoryFieldCard(2, "2. OUTCOMES", "What did it measure, discover, or demonstrate?", widget.caseData.outcomes, LucideIcons.barChart2, const Color(0xFF22C55E)),
          const SizedBox(height: 6),
          _buildMemoryFieldCard(3, "3. WHY ENDED / ABANDONED", "Impact, completed, power limit, or failure?", widget.caseData.whyEnded, LucideIcons.clock, const Color(0xFFF59E0B)),
          const SizedBox(height: 6),
          _buildMemoryFieldCard(4, "4. CONTRIBUTION", "How it changed future science & engineering?", widget.caseData.contribution, LucideIcons.sparkles, const Color(0xFFA855F7)),
          const SizedBox(height: 6),
          _buildMemoryFieldCard(5, "5. DEVICE TECHNOLOGY", "Instruments, mobility, propulsion, telemetry?", widget.caseData.deviceTechnology, LucideIcons.cpu, const Color(0xFFEC4899)),
          const SizedBox(height: 6),
          _buildMemoryFieldCard(6, "6. CHIEF GUIDELINES", "Priorities, safety margins, decision rules?", widget.caseData.missionChiefGuidelines, LucideIcons.shieldCheck, const Color(0xFF14B8A6)),

          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              AudioService.playClick();
              _scrollToTab(2);
            },
            icon: const Icon(LucideIcons.arrowRight, size: 14),
            label: Text(
              "INSPECT EVIDENCE LOCK ($_unlockedClues/3)",
              style: TextStyle(
                fontFamily: NotionTheme.pixelFont,
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      );
  }

  Widget _buildMemoryFieldCard(int id, String title, String subtitle, String text, IconData icon, Color color) {
    final isHidden = _recallMode && !_revealedCards.contains(id);

    return InkWell(
      onTap: () {
        if (_recallMode) {
          AudioService.playClick();
          setState(() {
            if (_revealedCards.contains(id)) {
              _revealedCards.remove(id);
            } else {
              _revealedCards.add(id);
            }
          });
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontFamily: NotionTheme.pixelFont,
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_recallMode)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isHidden ? Colors.white10 : color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isHidden ? "TAP TO REVEAL" : "SHOWN",
                      style: TextStyle(
                        color: isHidden ? Colors.white60 : color,
                        fontSize: 7,
                        fontFamily: NotionTheme.pixelFont,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            if (isHidden)
              Container(
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "[$subtitle] • Tap to recall from memory",
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 9.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  height: 1.35,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 3: EVIDENCE LOCK (SEQUENTIAL CLUES)
  // ==========================================
  Widget _buildEvidenceLockTab(Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
            children: [
              const Icon(LucideIcons.lock, size: 14, color: Color(0xFFFBBF24)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  "EVIDENCE LOCK • REVEAL IN SEQUENCE",
                  style: TextStyle(
                    color: Color(0xFFFBBF24),
                    fontFamily: NotionTheme.pixelFont,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _unlockedClues == 3 ? const Color(0xFF22C55E) : const Color(0xFFFBBF24),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "$_unlockedClues / 3 UNLOCKED",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 7.5,
                    fontFamily: NotionTheme.pixelFont,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Clue 1
          _buildClueCard(1, "CLUE 01 // INITIAL OBSERVATION", widget.caseData.clue1, isUnlocked: true, accent: accent),
          const SizedBox(height: 8),

          // Clue 2
          _buildClueCard(2, "CLUE 02 // SENSOR CROSS-CHECK", widget.caseData.clue2, isUnlocked: _unlockedClues >= 2, accent: accent),
          const SizedBox(height: 8),

          // Clue 3
          _buildClueCard(3, "CLUE 03 // PHYSICAL SIGNATURE & CONTEXT", widget.caseData.clue3, isUnlocked: _unlockedClues >= 3, accent: accent),
          const SizedBox(height: 10),

          // Subsystem Interactive Diagnostic Hardware Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.isSubsystemDiagnosed ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.isSubsystemDiagnosed ? LucideIcons.cpu : LucideIcons.wrench,
                  size: 16,
                  color: widget.isSubsystemDiagnosed ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SUBSYSTEM HARDWARE TELEMETRY",
                        style: TextStyle(
                          color: widget.isSubsystemDiagnosed ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                          fontFamily: NotionTheme.pixelFont,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.isSubsystemDiagnosed
                            ? "Hardware calibrated & physical evidence decoded."
                            : "Diagnostic required to retrieve raw telemetry.",
                        style: const TextStyle(color: Colors.white70, fontSize: 9.5),
                      ),
                    ],
                  ),
                ),
                if (!widget.isSubsystemDiagnosed && widget.onOpenSubsystemPuzzle != null)
                  ElevatedButton.icon(
                    onPressed: () {
                      AudioService.playGear();
                      widget.onOpenSubsystemPuzzle!();
                    },
                    icon: const Icon(LucideIcons.searchCode, size: 12),
                    label: const Text(
                      "DIAGNOSE",
                      style: TextStyle(
                        fontFamily: NotionTheme.pixelFont,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    ),
                  )
                else if (widget.isSubsystemDiagnosed)
                  const Icon(LucideIcons.checkCircle2, size: 16, color: Color(0xFF22C55E)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Unlock Next Clue Action Button
          if (_unlockedClues < 3)
            ElevatedButton.icon(
              onPressed: _revealNextClue,
              icon: const Icon(LucideIcons.unlock, size: 14),
              label: Text(
                "REVEAL CLUE ${_unlockedClues + 1} FROM TELEMETRY",
                style: TextStyle(
                  fontFamily: NotionTheme.pixelFont,
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFBBF24),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF22C55E)),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.checkCircle2, size: 14, color: Color(0xFF22C55E)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "ALL EVIDENCE CHANNELS REVEALED (+3 PTS EARNED)",
                      style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        fontFamily: NotionTheme.pixelFont,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              AudioService.playClick();
              _scrollToTab(3);
            },
            icon: const Icon(LucideIcons.award, size: 14),
            label: Text(
              _isSubmitted ? "VIEW DEBRIEF & RANK" : "PROCEED TO VERDICT & DEBRIEF",
              style: TextStyle(
                fontFamily: NotionTheme.pixelFont,
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      );
  }

  Widget _buildClueCard(int index, String title, String text, {required bool isUnlocked, required Color accent}) {
    return Container(
      decoration: BoxDecoration(
        color: isUnlocked ? const Color(0xFF0F172A) : Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUnlocked ? accent.withValues(alpha: 0.4) : Colors.white12,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isUnlocked ? LucideIcons.fileCheck : LucideIcons.lock,
                size: 13,
                color: isUnlocked ? accent : Colors.white38,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isUnlocked ? accent : Colors.white38,
                    fontFamily: NotionTheme.pixelFont,
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isUnlocked ? accent.withValues(alpha: 0.15) : Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isUnlocked ? "UNLOCKED" : "LOCKED",
                  style: TextStyle(
                    color: isUnlocked ? accent : Colors.white38,
                    fontSize: 7,
                    fontFamily: NotionTheme.pixelFont,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (isUnlocked)
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                height: 1.4,
              ),
            )
          else
            const Text(
              "Evidence locked. Examine hardware in viewer and reveal clue to decode telemetry.",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 4: CASE VERDICT & DEBRIEF
  // ==========================================
  Widget _buildVerdictTab(Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Player Challenge Banner
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.target, size: 14, color: Color(0xFF38BDF8)),
                    SizedBox(width: 6),
                    Text(
                      "PLAYER INVESTIGATION CHALLENGE",
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontFamily: NotionTheme.pixelFont,
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.caseData.playerChallenge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Interactive Hypotheses / Options
          const Text(
            "SELECT BEST EVIDENCE-BASED HYPOTHESIS:",
            style: TextStyle(
              color: Colors.white70,
              fontFamily: NotionTheme.pixelFont,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),

          ...List.generate(widget.caseData.challengeOptions.length, (idx) {
            final opt = widget.caseData.challengeOptions[idx];
            final isSelected = _selectedOptionIndex == idx;
            final isSubmitted = _isSubmitted;

            Color borderColor = Colors.white12;
            Color bgColor = Colors.white.withValues(alpha: 0.03);

            if (isSelected) {
              borderColor = accent;
              bgColor = accent.withValues(alpha: 0.15);
            }

            if (isSubmitted) {
              if (opt.isCorrect) {
                borderColor = const Color(0xFF22C55E);
                bgColor = const Color(0xFF22C55E).withValues(alpha: 0.2);
              } else if (isSelected && !opt.isCorrect) {
                borderColor = const Color(0xFFEF4444);
                bgColor = const Color(0xFFEF4444).withValues(alpha: 0.2);
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: isSubmitted
                    ? null
                    : () {
                        AudioService.playClick();
                        setState(() => _selectedOptionIndex = idx);
                      },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor, width: isSelected ? 1.4 : 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isSubmitted
                                ? (opt.isCorrect
                                    ? LucideIcons.checkCircle2
                                    : (isSelected ? LucideIcons.xCircle : LucideIcons.circle))
                                : (isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle),
                            size: 14,
                            color: isSubmitted
                                ? (opt.isCorrect ? const Color(0xFF22C55E) : (isSelected ? const Color(0xFFEF4444) : Colors.white30))
                                : (isSelected ? accent : Colors.white38),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              opt.text,
                              style: TextStyle(
                                color: isSelected || (isSubmitted && opt.isCorrect) ? Colors.white : Colors.white70,
                                fontSize: 10.5,
                                height: 1.35,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isSubmitted && isSelected) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            opt.feedback,
                            style: TextStyle(
                              color: opt.isCorrect ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                              fontSize: 9.5,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 6),

          // Scientific Thinking Checklist (From Page 26)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.listCheck, size: 12, color: Color(0xFF38BDF8)),
                    SizedBox(width: 5),
                    Text(
                      "SCIENTIFIC THINKING CHECKLIST",
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontFamily: NotionTheme.pixelFont,
                        fontSize: 7.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _buildChecklistItem("Observation", widget.caseData.observation),
                _buildChecklistItem("Verification", widget.caseData.verificationTest),
                _buildChecklistItem("Alternative Rejected", widget.caseData.alternativeRejected),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Confidence Selector (Page 26 Checklist)
          Row(
            children: [
              const Text(
                "CONFIDENCE:",
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: NotionTheme.pixelFont,
                  fontSize: 7.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: ["CONFIRMED", "LIKELY", "POSSIBLE", "UNRESOLVED"].map((conf) {
                    final isSel = _selectedConfidence == conf;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: InkWell(
                          onTap: _isSubmitted
                              ? null
                              : () {
                                  AudioService.playClick();
                                  setState(() => _selectedConfidence = conf);
                                },
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSel ? accent.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: isSel ? accent : Colors.white24, width: 0.8),
                            ),
                            child: Text(
                              conf,
                              style: TextStyle(
                                color: isSel ? Colors.white : Colors.white60,
                                fontSize: 6.5,
                                fontFamily: NotionTheme.pixelFont,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Submit Button or Solved Debrief
          if (!_isSubmitted) ...[
            if (!widget.isSubsystemDiagnosed)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertTriangle, size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Subsystem diagnostic pending. Complete subsystem investigation to decode full forensic telemetry (+3 Pts).",
                        style: TextStyle(
                          color: Color(0xFFFCD34D),
                          fontSize: 9,
                          fontFamily: NotionTheme.pixelFont,
                        ),
                      ),
                    ),
                    if (widget.onOpenSubsystemPuzzle != null)
                      TextButton(
                        onPressed: () {
                          AudioService.playGear();
                          widget.onOpenSubsystemPuzzle!();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text(
                          "DIAGNOSE",
                          style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            fontFamily: NotionTheme.pixelFont,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ElevatedButton.icon(
              onPressed: _submitVerdict,
              icon: const Icon(LucideIcons.check, size: 14),
              label: Text(
                "SUBMIT MISSION VERDICT & DEBRIEF",
                style: TextStyle(
                  fontFamily: NotionTheme.pixelFont,
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ]
          else ...[
            // Score & Rank Debrief Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF030712),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _rankColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: _rankColor.withValues(alpha: 0.2),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.award, color: _rankColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "DETECTIVE RANK: $_rankTitle",
                              style: TextStyle(
                                color: _rankColor,
                                fontFamily: NotionTheme.pixelFont,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Score: $_finalScore / 10 Points • $_starsAwarded Stars Earned",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: List.generate(3, (starIdx) {
                          return Icon(
                            starIdx < _starsAwarded ? LucideIcons.star : LucideIcons.starOff,
                            size: 14,
                            color: starIdx < _starsAwarded ? const Color(0xFFFBBF24) : Colors.white24,
                          );
                        }),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 16),

                  // Official Solution
                  const Text(
                    "OFFICIAL CASE SOLUTION & VERDICT:",
                    style: TextStyle(
                      color: Color(0xFF38BDF8),
                      fontFamily: NotionTheme.pixelFont,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.caseData.caseSolution,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Memory Recall Spaced Prompt (From PDF)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "MEMORY RECALL CHECK:",
                          style: TextStyle(
                            color: Color(0xFFFBBF24),
                            fontFamily: NotionTheme.pixelFont,
                            fontSize: 7.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.caseData.memoryRecall,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 9.5,
                            fontStyle: FontStyle.italic,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Replay Button
            OutlinedButton.icon(
              onPressed: () {
                AudioService.playClick();
                setState(() {
                  _isSubmitted = false;
                  _selectedOptionIndex = null;
                });
                _scrollToTab(0);
              },
              icon: const Icon(LucideIcons.rotateCcw, size: 12),
              label: Text(
                "REPLAY INVESTIGATION FOR MASTERY",
                style: TextStyle(
                  fontFamily: NotionTheme.pixelFont,
                  fontSize: 8.5,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
              ),
            ),
          ],
        ],
      );
  }

  Widget _buildChecklistItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• $label: ",
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 9,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BOTTOM STATUS BAR
  // ==========================================
  Widget _buildBottomStatus(Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _isSubmitted ? const Color(0xFF22C55E) : accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _isSubmitted ? "VERDICT VERIFIED // DATA SECURED" : "DOSSIER ACTIVE BESIDE VIEWER",
              style: TextStyle(
                color: _isSubmitted ? const Color(0xFF22C55E) : accent,
                fontFamily: NotionTheme.pixelFont,
                fontSize: 8,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.onOpenSubsystemPuzzle != null)
            InkWell(
              onTap: () {
                AudioService.playGear();
                widget.onOpenSubsystemPuzzle!();
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (widget.isSubsystemDiagnosed ? const Color(0xFF22C55E) : const Color(0xFFF59E0B)).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: (widget.isSubsystemDiagnosed ? const Color(0xFF22C55E) : const Color(0xFFF59E0B)).withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.isSubsystemDiagnosed ? LucideIcons.cpu : LucideIcons.wrench, size: 10, color: widget.isSubsystemDiagnosed ? const Color(0xFF22C55E) : const Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text(
                      widget.isSubsystemDiagnosed ? "PUZZLE DIAGNOSED" : "PUZZLE",
                      style: TextStyle(
                        color: widget.isSubsystemDiagnosed ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                        fontFamily: NotionTheme.pixelFont,
                        fontSize: 7.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
