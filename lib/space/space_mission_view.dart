import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../models/campaign_data.dart';
import '../models/space_detective_data.dart';
import 'space_detective_dossier_panel.dart';

import '../services/vault_service.dart';
import '../services/audio_service.dart';
import '../puzzles/puzzles_modal.dart';
import '../dialogs/vault_dialog.dart';
import '../dialogs/solar_system_map_dialog.dart';
import '../dialogs/nasa_timeline_dialog.dart';
import '../dialogs/student_guide_dialog.dart';
import '../theme/notion_theme.dart';

class SpaceMissionView extends StatefulWidget {
  final VaultService vault;
  final VoidCallback onReturnToArchive;
  final VoidCallback? onReturnToMenu;
  final CampaignLevel? campaignLevel;

  const SpaceMissionView({
    super.key,
    required this.vault,
    required this.onReturnToArchive,
    this.onReturnToMenu,
    this.campaignLevel,
  });

  @override
  State<SpaceMissionView> createState() => _SpaceMissionViewState();
}

class _SpaceMissionViewState extends State<SpaceMissionView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;

  // 3D Model Viewer Controls
  bool _autoRotate = true;
  bool _isDossierOpen = true;
  // Held as dynamic: webview_flutter is only a transitive dependency of model_viewer_plus
  dynamic _modelWebViewController;
  final TransformationController _imageTransformController = TransformationController();

  // Desktop Fallback 3D Angles
  double _rotX = 0.3;
  double _rotY = 0.5;
  final double _scale = 1.0;

  // Mission Timer (5 minutes)
  int _timerSeconds = 300;
  Timer? _countdownTimer;

  // Real-time Live Clock
  DateTime _now = DateTime.now();
  Timer? _liveClockTimer;

  // Active Puzzle Modal
  String? _activePuzzleType;

  // Dialog Overlays
  bool _showVault = false;
  bool _showSolarMap = false;
  bool _showTimeline = false;
  bool _showStudentGuide = false;

  // Victory Dialog State
  bool _showVictoryDialog = false;
  bool _showWorldCompleteDialog = false;
  String _victoryMessage = "";

  // Space Detective Lifecycle & Subsystem State
  bool _isSubsystemDiagnosed = false;
  bool _isVerdictSubmitted = false;
  int _verdictScore = 0;
  int _verdictStars = 0;
  String _verdictRank = "";
  int _dossierTab = 0;

  // Mission Mischief State
  int _mischiefIndex = 0;
  bool _mischiefExpanded = false;

  final List<Map<String, String>> _mischiefMessages = [
    {
      "tag": "HARDWARE TELEMETRY",
      "text": "3D glTF/GLB telemetry active. Rotate and inspect subsystems to locate physical evidence.",
      "color": "0xFF38BDF8",
    },
    {
      "tag": "TACTICAL TIP",
      "text": "Tap 'Investigate Subsystem' or the Story Dossier to solve the calibration cipher!",
      "color": "0xFF22C55E",
    },
    {
      "tag": "EVIDENCE SEAL",
      "text": "Solving this hardware puzzle secures authentic NASA scientific data in the Vault.",
      "color": "0xFFF59E0B",
    },
    {
      "tag": "MISSION OVERRIDE",
      "text": "Physical hardware is immutable. AI EVA cannot alter hardware-embedded records.",
      "color": "0xFFA855F7",
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.campaignLevel != null) {
      widget.vault.setActiveLevel(widget.campaignLevel!.id);
    }
    final isAlreadyCompleted = widget.campaignLevel?.isCompleted ?? false;
    _isSubsystemDiagnosed = isAlreadyCompleted;
    _isVerdictSubmitted = isAlreadyCompleted;
    if (isAlreadyCompleted) {
      _verdictStars = widget.campaignLevel?.stars ?? 3;
      _verdictScore = _verdictStars == 3 ? 10 : (_verdictStars == 2 ? 8 : 6);
      _verdictRank = _verdictStars == 3
          ? "MISSION DETECTIVE"
          : (_verdictStars == 2 ? "FIELD INVESTIGATOR" : "JUNIOR ANALYST");
    }

    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();

    // Warm the asset cache so the viewer's local proxy serves the GLB instantly
    if (_supportsNativeModelViewer) {
      final glbPath = widget.campaignLevel?.glbModelPath;
      if (glbPath != null) {
        rootBundle.load(glbPath).catchError((_) => ByteData(0));
      }
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0 && mounted) {
        setState(() => _timerSeconds--);
      }
    });

    _liveClockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _imageTransformController.dispose();
    _countdownTimer?.cancel();
    _liveClockTimer?.cancel();
    super.dispose();
  }

  bool get _supportsNativeModelViewer {
    if (kIsWeb) return true;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _rotY += details.delta.dx * 0.01;
      _rotX += details.delta.dy * 0.01;
      _rotX = _rotX.clamp(-1.2, 1.2);
    });
  }

  void _cycleMischief() {
    AudioService.playHint();
    setState(() {
      _mischiefIndex = (_mischiefIndex + 1) % _mischiefMessages.length;
      _mischiefExpanded = true;
    });
  }

  void _openPuzzle(String type) {
    AudioService.playCardSelect();
    setState(() {
      _activePuzzleType = type;
    });
  }

  void _onPuzzleSolved(List<String> clueIds, String message) {
    widget.vault.unlockClues(clueIds);

    setState(() {
      _activePuzzleType = null;
      _isSubsystemDiagnosed = true;
      _isDossierOpen = true; // Automatically open Story Dossier beside the viewer
      _dossierTab = 3; // Focus directly on the Verdict & Debrief tab
      _victoryMessage = message;
    });

    AudioService.playSuccess();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF22C55E), width: 1.2),
        ),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            const Icon(LucideIcons.checkCircle2, color: Color(0xFF22C55E), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SUBSYSTEM DIAGNOSED // EVIDENCE UNLOCKED",
                    style: TextStyle(
                      color: Color(0xFF22C55E),
                      fontFamily: NotionTheme.pixelFont,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.isNotEmpty
                        ? message
                        : "Diagnostic telemetry decoded. Proceed to Case Verdict & Debrief to conclude the mission.",
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onVerdictSolved(int score, int stars, [String rank = ""]) {
    bool allWorldLevelsCompleted = false;
    if (widget.campaignLevel != null) {
      widget.vault.completeCampaignLevel(widget.campaignLevel!.id, stars);
      final currentWorld = widget.vault.worlds.cast<CampaignWorld?>().firstWhere(
        (w) => w?.levels.any((l) => l.id == widget.campaignLevel!.id) ?? false,
        orElse: () => null,
      );
      if (currentWorld != null && currentWorld.isCompleted) {
        allWorldLevelsCompleted = true;
      }
    }

    if (allWorldLevelsCompleted) {
      AudioService.playWorldComplete();
    } else {
      AudioService.playLevelComplete();
    }

    setState(() {
      _isVerdictSubmitted = true;
      _verdictScore = score;
      _verdictStars = stars;
      _verdictRank = rank.isNotEmpty
          ? rank
          : (stars == 3 ? "MISSION DETECTIVE" : (stars == 2 ? "FIELD INVESTIGATOR" : "JUNIOR ANALYST"));
      _showWorldCompleteDialog = allWorldLevelsCompleted;
      _showVictoryDialog = true;
    });
  }

  void _toggleAutoRotate() {
    AudioService.playGear();
    setState(() {
      _autoRotate = !_autoRotate;
    });
  }

  void _resetCamera() {
    AudioService.playZoom();
    // Reset the live WebView camera instead of rebuilding the ModelViewer
    // widget, which would tear down the WebView and reload the model.
    if (_supportsNativeModelViewer && _modelWebViewController != null) {
      _modelWebViewController.runJavaScript(
        "const v = document.querySelector('model-viewer');"
        "if (v && v.resetCameraAtRoot) v.resetCameraAtRoot();",
      );
    }
    setState(() {
      _rotX = 0.3;
      _rotY = 0.5;
    });
  }

  String _resolveGlbModelPath(String modelName) {
    return CampaignLevel.resolveGlbPath(modelName);
  }

  @override
  Widget build(BuildContext context) {
    final mission = widget.vault.currentMission;
    final missionTitle = widget.campaignLevel?.title ?? mission.title;
    final hardware = widget.campaignLevel?.spacecraft ?? mission.hardware;
    final objective = widget.campaignLevel?.objective ?? mission.objective;
    final modelName = widget.campaignLevel?.modelName ?? mission.modelName;
    final glbPath = widget.campaignLevel?.glbModelPath ?? _resolveGlbModelPath(modelName);
    final puzzleType = widget.campaignLevel?.puzzleType ?? "signal";
    final hardwareImage = widget.campaignLevel?.hardwareImagePath;

    final String levelCode = widget.campaignLevel?.code ?? "M1";
    final SpaceDetectiveCase detectiveCase = SpaceDetectiveCatalog.getCaseByCode(levelCode) ??
        SpaceDetectiveCatalog.getCaseByLevelId(widget.campaignLevel?.id ?? "") ??
        SpaceDetectiveCatalog.allCases.first;

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 920;
    final dossierWidth = isWide
        ? (screenWidth * 0.38).clamp(380.0, 480.0)
        : (screenWidth * 0.90).clamp(320.0, 440.0);
    final viewerRightBound = (isWide && _isDossierOpen) ? dossierWidth + 12 : 0.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          widget.onReturnToArchive();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF070B14),
        body: Stack(
          children: [
            // 1. Sleek sci-fi laboratory backdrop
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, -0.2),
                    radius: 1.1,
                    colors: [
                      Color(0xFF141C2B),
                      Color(0xFF0A0F19),
                      Color(0xFF04060B),
                    ],
                  ),
                ),
              ),
            ),

            // Subtle cybernetic inspection grid
            Positioned.fill(
              child: CustomPaint(
                painter: _InspectionGridPainter(),
              ),
            ),

            // 2. Main Spacecraft / Hardware Viewer Bay (Sits beside Story Dossier)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              right: viewerRightBound,
              child: Stack(
                children: [
                  // 2. Center 3D Model Viewer OR Archival Photographic Viewer
            Positioned.fill(
              child: hardwareImage != null
                  ? _buildArchivalImageViewer(hardwareImage, hardware)
                  : (_supportsNativeModelViewer
                      ? ModelViewer(
                          onWebViewCreated: (controller) => _modelWebViewController = controller,
                          src: glbPath,
                          alt: "$hardware 3D Hardware Model",
                          ar: false,
                          autoRotate: _autoRotate,
                          autoRotateDelay: 1000,
                          rotationPerSecond: "25deg",
                          cameraControls: true,
                          backgroundColor: Colors.transparent,
                          shadowIntensity: 0.85,
                          exposure: 1.15,
                          loading: Loading.eager,
                        )
                      : GestureDetector(
                          onPanUpdate: _onPanUpdate,
                          child: CustomPaint(
                            painter: _SpaceInspectorPainter(
                              rotX: _rotX,
                              rotY: _rotY,
                              scale: _scale,
                              modelName: modelName,
                            ),
                          ),
                        )),
            ),

            // 4. Floating Viewport Controls (Bottom-Center)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xEE090F1E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (hardwareImage != null ? const Color(0xFFFBBF24) : const Color(0xFF38BDF8)).withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hardwareImage != null) ...[
                        // Archival Photo Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.camera, color: Color(0xFFFBBF24), size: 12),
                              const SizedBox(width: 5),
                              Text(
                                "NASA ARCHIVAL PHOTO",
                                style: TextStyle(
                                  color: const Color(0xFFFBBF24),
                                  fontFamily: NotionTheme.pixelFont,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Reset Image Zoom Button
                        InkWell(
                          onTap: () {
                            AudioService.playZoom();
                            _imageTransformController.value = Matrix4.identity();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.maximize2, size: 11, color: Colors.white70),
                                SizedBox(width: 4),
                                Text(
                                  "RESET ZOOM",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontFamily: NotionTheme.pixelFont,
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // GLB Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.box, color: Color(0xFF38BDF8), size: 12),
                              const SizedBox(width: 5),
                              Text(
                                "GLB/glTF 3D",
                                style: TextStyle(
                                  color: const Color(0xFF38BDF8),
                                  fontFamily: NotionTheme.pixelFont,
                                  fontSize: 8.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Auto-Rotate Button
                        InkWell(
                          onTap: _toggleAutoRotate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _autoRotate
                                  ? const Color(0xFF22C55E).withValues(alpha: 0.2)
                                  : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _autoRotate
                                    ? const Color(0xFF22C55E).withValues(alpha: 0.6)
                                    : Colors.white24,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.rotateCcw,
                                  size: 11,
                                  color: _autoRotate ? const Color(0xFF22C55E) : Colors.white60,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _autoRotate ? "ROTATING" : "PAUSED",
                                  style: TextStyle(
                                    color: _autoRotate ? const Color(0xFF22C55E) : Colors.white60,
                                    fontFamily: NotionTheme.pixelFont,
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Reset Camera View Button
                        InkWell(
                          onTap: _resetCamera,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.crosshair, size: 11, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  "RESET",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontFamily: NotionTheme.pixelFont,
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

                  // Top-Left: Companion Tip Icon & Expandable Tip Pill
            Positioned(
              top: 58,
              left: 14,
              child: SafeArea(
                top: false,
                right: false,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tip Icon Button
                    GestureDetector(
                      onTap: () {
                        if (_mischiefExpanded) {
                          _cycleMischief();
                        } else {
                          setState(() => _mischiefExpanded = true);
                          AudioService.playClick();
                        }
                      },
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xEE090F1D),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.8),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                              blurRadius: 8,
                            )
                          ],
                        ),
                        child: const Icon(LucideIcons.sparkles, color: Color(0xFF38BDF8), size: 15),
                      ),
                    ),

                    // Companion Tip Pill
                    if (_mischiefExpanded) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _cycleMischief,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 260),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xF50B111E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(int.parse(_mischiefMessages[_mischiefIndex]["color"]!)),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _mischiefMessages[_mischiefIndex]["tag"]!,
                                    style: TextStyle(
                                      color: Color(int.parse(_mischiefMessages[_mischiefIndex]["color"]!)),
                                      fontFamily: NotionTheme.pixelFont,
                                      fontSize: 7.5,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () => setState(() => _mischiefExpanded = false),
                                    child: const Icon(LucideIcons.x, color: Colors.white38, size: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _mischiefMessages[_mischiefIndex]["text"]!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  height: 1.25,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom-Right: Primary Action Button (Obeys Story Dossier Debrief Lifecycle)
            Positioned(
              right: 14,
              bottom: 12,
              child: SafeArea(
                top: false,
                left: false,
                child: _buildBottomRightActionButton(detectiveCase, puzzleType),
              ),
            ),                ],
              ),
            ),

            // 5. Top Tactical HUD Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xEE090F1D),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.35), width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Left: Return Button
                        _buildTacticalBtn(
                          icon: LucideIcons.arrowLeft,
                          tooltip: "Return to Level Selection",
                          accentColor: const Color(0xFF38BDF8),
                          onTap: () {
                            AudioService.playBack();
                            widget.onReturnToArchive();
                          },
                        ),
                        const SizedBox(width: 10),

                        // Level Banner Thumbnail
                        if (widget.campaignLevel != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.asset(
                              widget.campaignLevel!.bannerPath,
                              width: 30,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Hardware Badge, Title & Brief Objective (Docked in Top HUD with zero viewer overlap)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${hardware.toUpperCase()} // ${missionTitle.toUpperCase()}",
                                style: const TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 9,
                                  letterSpacing: 0.5,
                                  fontFamily: NotionTheme.pixelFont,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                objective,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 8.5,
                                  fontFamily: NotionTheme.fontFamily,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Live Telemetry Clock & Status Badge (Cleanly docked in top bar)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatClock(_now),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: NotionTheme.pixelFont,
                                  fontSize: 8,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "LIVE",
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
                        const SizedBox(width: 8),

                        const Spacer(),

                        // Right: Grouped Action Console
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Detective Story Dossier Button
                            _buildTacticalBtn(
                              icon: LucideIcons.bookOpen,
                              tooltip: _isDossierOpen ? "Collapse Story Dossier" : "Open Story Dossier",
                              accentColor: _isDossierOpen ? const Color(0xFFFBBF24) : Colors.white70,
                              onTap: () {
                                AudioService.playClick();
                                setState(() => _isDossierOpen = !_isDossierOpen);
                              },
                            ),
                            const SizedBox(width: 6),

                            // Evidence Vault Button
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                _buildTacticalBtn(
                                  icon: LucideIcons.database,
                                  tooltip: "Evidence Vault",
                                  accentColor: const Color(0xFF22C55E),
                                  onTap: () => setState(() => _showVault = true),
                                ),
                                Positioned(
                                  top: -3,
                                  right: -3,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "${widget.vault.unlockedCluesCount}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 7.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 6),

                            // Solar System Map
                            _buildTacticalBtn(
                              icon: LucideIcons.compass,
                              tooltip: "Solar System Map",
                              onTap: () => setState(() => _showSolarMap = true),
                            ),
                            const SizedBox(width: 6),

                            // NASA Timeline
                            _buildTacticalBtn(
                              icon: LucideIcons.bookMarked,
                              tooltip: "NASA Historical Timeline",
                              onTap: () => setState(() => _showTimeline = true),
                            ),
                            const SizedBox(width: 6),

                            // Student Guide
                            _buildTacticalBtn(
                              icon: LucideIcons.helpCircle,
                              tooltip: "Student Field Guide",
                              onTap: () => setState(() => _showStudentGuide = true),
                            ),
                            const SizedBox(width: 6),

                            // Sound Mute Toggle
                            _buildTacticalBtn(
                              icon: widget.vault.isSoundMuted ? LucideIcons.volumeX : LucideIcons.volume2,
                              tooltip: "Toggle Audio",
                              onTap: () {
                                widget.vault.toggleSound();
                                AudioService.isMuted = widget.vault.isSoundMuted;
                                setState(() {});
                              },
                            ),
                            if (widget.onReturnToMenu != null) ...[
                              const SizedBox(width: 6),
                              _buildTacticalBtn(
                                icon: LucideIcons.home,
                                tooltip: "Main Menu",
                                accentColor: const Color(0xFFF59E0B),
                                onTap: widget.onReturnToMenu!,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 6. Space Detective Storytelling Dossier Console (Beside the Viewer)
            if (_isDossierOpen)
              Positioned(
                top: 56,
                bottom: 10,
                right: 10,
                width: dossierWidth,
                child: SpaceDetectiveDossierPanel(
                  caseData: detectiveCase,
                  vault: widget.vault,
                  initialTab: _dossierTab,
                  isSubsystemDiagnosed: _isSubsystemDiagnosed,
                  onClose: () {
                    AudioService.playBack();
                    setState(() => _isDossierOpen = false);
                  },
                  onVerdictSolved: _onVerdictSolved,
                  onOpenSubsystemPuzzle: () => _openPuzzle(puzzleType),
                ),
              ),

            // Collapsed Dossier Toggle Handle
            if (!_isDossierOpen)
              Positioned(
                top: 66,
                right: 12,
                child: _buildDossierToggleBadge(detectiveCase),
              ),

            // 9. Space Detective Case Resolution Celebratory Modal
            if (_showVictoryDialog)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.85),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 460),
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C1322),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFBBF24), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFBBF24).withValues(alpha: 0.25),
                            blurRadius: 28,
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.award, color: Color(0xFFFBBF24), size: 40),
                          const SizedBox(height: 10),
                          Text(
                            "SPACE DETECTIVE CASE SOLVED // ${widget.campaignLevel?.code ?? 'MISSION'}",
                            style: const TextStyle(
                              color: Color(0xFFFBBF24),
                              fontFamily: NotionTheme.pixelFont,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            missionTitle.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          // Rank Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFFBBF24)),
                            ),
                            child: Text(
                              "RANK: $_verdictRank",
                              style: const TextStyle(
                                color: Color(0xFFFBBF24),
                                fontFamily: NotionTheme.pixelFont,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Star Rating
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  index < _verdictStars ? LucideIcons.star : LucideIcons.starOff,
                                  color: index < _verdictStars ? const Color(0xFFFBBF24) : Colors.white24,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Rubric Score: $_verdictScore / 10 Points • $_verdictStars Stars Secured",
                            style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontFamily: NotionTheme.pixelFont,
                              fontSize: 8.5,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Case Solution Summary
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Text(
                              _victoryMessage.isNotEmpty
                                  ? "$_victoryMessage\n\n${detectiveCase.caseSolution}"
                                  : detectiveCase.caseSolution,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                height: 1.4,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showVictoryDialog = false;
                                    _isDossierOpen = true;
                                    _dossierTab = 3;
                                  });
                                },
                                icon: const Icon(LucideIcons.bookOpen, size: 14),
                                label: const Text(
                                  "REVIEW DOSSIER",
                                  style: TextStyle(
                                    fontFamily: NotionTheme.pixelFont,
                                    fontSize: 8.5,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF38BDF8),
                                  side: const BorderSide(color: Color(0xFF38BDF8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() => _showVictoryDialog = false);
                                  widget.onReturnToArchive();
                                },
                                icon: const Icon(LucideIcons.check, size: 14),
                                label: Text(
                                  _showWorldCompleteDialog ? "SECTOR ARCHIVED" : "CONTINUE",
                                  style: const TextStyle(
                                    fontFamily: NotionTheme.pixelFont,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF22C55E),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

            // 10. ACTIVE PUZZLE MODAL
            if (_activePuzzleType != null)
              PuzzlesModal(
                missionId: mission.id,
                puzzleType: _activePuzzleType!,
                onClose: () => setState(() => _activePuzzleType = null),
                onSolved: _onPuzzleSolved,
              ),

            // 11. EVIDENCE VAULT DIALOG
            if (_showVault)
              VaultDialog(
                vault: widget.vault,
                onClose: () => setState(() => _showVault = false),
              ),

            // 12. SOLAR SYSTEM MAP DIALOG
            if (_showSolarMap)
              SolarSystemMapDialog(
                onSelectMission: (missionId) {
                  widget.vault.setActiveMission(missionId);
                  setState(() => _showSolarMap = false);
                },
                onClose: () => setState(() => _showSolarMap = false),
              ),

            // 13. NASA TIMELINE DIALOG
            if (_showTimeline)
              NasaTimelineDialog(
                onClose: () => setState(() => _showTimeline = false),
              ),

            // 14. STUDENT FIELD GUIDE DIALOG
            if (_showStudentGuide)
              StudentGuideDialog(
                onClose: () => setState(() => _showStudentGuide = false),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchivalImageViewer(String imagePath, String hardware) {
    return Stack(
      children: [
        // Interactive Zoomable / Pannable Archival Hardware Image
        Positioned.fill(
          child: InteractiveViewer(
            transformationController: _imageTransformController,
            minScale: 0.6,
            maxScale: 4.0,
            boundaryMargin: const EdgeInsets.all(150),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 820, maxHeight: 580),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Text("Error loading archival photograph", style: TextStyle(color: Colors.white54)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Cybernetic Telemetry Reticle Frame Overlay
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ArchivalScanGridPainter(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTacticalBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color accentColor = const Color(0xFF38BDF8),
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AudioService.playClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 0.8),
            ),
            child: Icon(icon, color: Colors.white, size: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildDossierToggleBadge(SpaceDetectiveCase caseData) {
    return InkWell(
      onTap: () {
        AudioService.playClick();
        setState(() => _isDossierOpen = true);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xEE090F1E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFBBF24), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFBBF24).withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.bookOpen, size: 14, color: Color(0xFFFBBF24)),
            const SizedBox(width: 6),
            Text(
              "STORY DOSSIER [${caseData.code}]",
              style: const TextStyle(
                color: Color(0xFFFBBF24),
                fontFamily: NotionTheme.pixelFont,
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(LucideIcons.chevronLeft, size: 13, color: Color(0xFFFBBF24)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomRightActionButton(SpaceDetectiveCase detectiveCase, String puzzleType) {
    if (_isVerdictSubmitted) {
      return ElevatedButton.icon(
        onPressed: () {
          AudioService.playCardSelect();
          setState(() {
            _isDossierOpen = true;
            _dossierTab = 3;
          });
        },
        icon: const Icon(LucideIcons.checkCircle2, size: 15),
        label: Text(
          "CASE RESOLVED [${_verdictStars > 0 ? '★' * _verdictStars : 'VERIFIED'}]",
          style: const TextStyle(
            fontFamily: NotionTheme.pixelFont,
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF22C55E),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFF4ADE80), width: 1.2),
          ),
        ),
      );
    }

    if (_isSubsystemDiagnosed) {
      return ElevatedButton.icon(
        onPressed: () {
          AudioService.playCardSelect();
          setState(() {
            _isDossierOpen = true;
            _dossierTab = 3;
          });
        },
        icon: const Icon(LucideIcons.fileCheck2, size: 15),
        label: const Text(
          "PROCEED TO CASE DEBRIEF",
          style: TextStyle(
            fontFamily: NotionTheme.pixelFont,
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF59E0B),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFFBBF24), width: 1.4),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _openPuzzle(puzzleType),
      icon: const Icon(LucideIcons.searchCode, size: 15),
      label: const Text(
        "INVESTIGATE SUBSYSTEM",
        style: TextStyle(
          fontFamily: NotionTheme.pixelFont,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF22C55E),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF4ADE80), width: 1.2),
        ),
      ),
    );
  }

  String _formatClock(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return "$h:$m:$s";
  }
}

class _InspectionGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.035)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SpaceInspectorPainter extends CustomPainter {
  final double rotX;
  final double rotY;
  final double scale;
  final String modelName;

  _SpaceInspectorPainter({
    required this.rotX,
    required this.rotY,
    required this.scale,
    required this.modelName,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);
    _drawSpacecraftModel(canvas, modelName, rotX, rotY);
    canvas.restore();
  }

  void _drawSpacecraftModel(Canvas canvas, String model, double rx, double ry) {
    final bodyPaint = Paint()..color = const Color(0xFFF1F5F9);
    final goldPaint = Paint()..color = const Color(0xFFF59E0B);
    final darkPaint = Paint()..color = const Color(0xFF0F172A);
    final wirePaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final cosY = math.cos(ry);
    final sinY = math.sin(ry);
    final cosX = math.cos(rx);
    final sinX = math.sin(rx);

    if (model == "pioneer10") {
      final dishW = 100.0 * cosY;
      final dishH = 80.0 * cosX;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(sinY * 10, -sinX * 10), width: dishW.abs(), height: dishH.abs()),
        bodyPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(sinY * 10, -sinX * 10), width: dishW.abs(), height: dishH.abs()),
        wirePaint,
      );
      canvas.drawLine(
        Offset(sinY * 10, -sinX * 10),
        Offset(sinY * 10, -sinX * 10 - 24),
        Paint()..color = Colors.white..strokeWidth = 2,
      );
      canvas.drawRect(
        Rect.fromCenter(center: Offset(sinY * 10, 16), width: 32 * cosY.abs(), height: 24),
        goldPaint,
      );
    } else if (model == "apollo_lunar_module") {
      canvas.drawRect(
        Rect.fromCenter(center: const Offset(0, 15), width: 55 * cosY.abs(), height: 28),
        goldPaint,
      );
      canvas.drawRect(
        Rect.fromCenter(center: const Offset(0, -12), width: 44 * cosY.abs(), height: 26),
        bodyPaint,
      );
      final winPaint = Paint()..color = const Color(0xFF0284C7);
      canvas.drawRect(Rect.fromCenter(center: const Offset(-8, -14), width: 6, height: 6), winPaint);
      canvas.drawRect(Rect.fromCenter(center: const Offset(8, -14), width: 6, height: 6), winPaint);
      final legPaint = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 2;
      canvas.drawLine(const Offset(-25, 25), Offset(-50 * cosY, 48), legPaint);
      canvas.drawLine(const Offset(25, 25), Offset(50 * cosY, 48), legPaint);
      canvas.drawCircle(Offset(-50 * cosY, 48), 5, goldPaint);
      canvas.drawCircle(Offset(50 * cosY, 48), 5, goldPaint);
    } else if (model == "dawn") {
      canvas.drawRect(
        Rect.fromCenter(center: const Offset(0, 0), width: 34 * cosY.abs(), height: 34),
        darkPaint,
      );
      final solarPaint = Paint()..color = const Color(0xFF1E3A8A);
      canvas.drawRect(Rect.fromCenter(center: Offset(-65 * cosY, 0), width: 60 * cosY.abs(), height: 20), solarPaint);
      canvas.drawRect(Rect.fromCenter(center: Offset(65 * cosY, 0), width: 60 * cosY.abs(), height: 20), solarPaint);
      final ionPaint = Paint()..color = const Color(0xFF38BDF8);
      canvas.drawCircle(const Offset(0, 20), 6, ionPaint);
    } else {
      canvas.drawRect(
        Rect.fromCenter(center: const Offset(0, 0), width: 45 * cosY.abs(), height: 45),
        bodyPaint,
      );
      canvas.drawRect(
        Rect.fromCenter(center: const Offset(0, 0), width: 45 * cosY.abs(), height: 45),
        wirePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpaceInspectorPainter oldDelegate) => true;
}

class _ArchivalScanGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bracketPaint = Paint()
      ..color = const Color(0x66FBBF24)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const cornerSize = 24.0;
    const margin = 30.0;

    // Top-left
    canvas.drawLine(const Offset(margin, margin), const Offset(margin + cornerSize, margin), bracketPaint);
    canvas.drawLine(const Offset(margin, margin), const Offset(margin, margin + cornerSize), bracketPaint);

    // Top-right
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin - cornerSize, margin), bracketPaint);
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin, margin + cornerSize), bracketPaint);

    // Bottom-left
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin + cornerSize, size.height - margin), bracketPaint);
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin, size.height - margin - cornerSize), bracketPaint);

    // Bottom-right
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin - cornerSize, size.height - margin), bracketPaint);
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin, size.height - margin - cornerSize), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
