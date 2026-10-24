import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../models/campaign_data.dart';
import '../services/vault_service.dart';
import '../services/audio_service.dart';
import '../puzzles/puzzles_modal.dart';
import '../dialogs/vault_dialog.dart';
import '../dialogs/solar_system_map_dialog.dart';
import '../dialogs/nasa_timeline_dialog.dart';
import '../dialogs/student_guide_dialog.dart';
import '../shuttle/shuttle_flight_view.dart';
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
  Key _modelViewerKey = UniqueKey();
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
  bool _showShuttleFlight = false;

  // Hotspot Inspection Modal
  Map<String, String>? _inspectedHotspot;

  // Victory Dialog State
  bool _showVictoryDialog = false;
  String _victoryMessage = "";

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
      "text": "Tap 'Investigate Subsystem' or the glowing reticles to solve the calibration cipher!",
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
    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();

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
      _inspectedHotspot = null;
      _activePuzzleType = type;
    });
  }

  void _onPuzzleSolved(List<String> clueIds, String message) {
    widget.vault.unlockClues(clueIds);
    bool allWorldLevelsCompleted = false;
    if (widget.campaignLevel != null) {
      widget.vault.completeCampaignLevel(widget.campaignLevel!.id, 3);
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
      _activePuzzleType = null;
      _showVictoryDialog = true;
      _victoryMessage = message;
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
    setState(() {
      _rotX = 0.3;
      _rotY = 0.5;
      _modelViewerKey = UniqueKey();
    });
  }

  String _resolveGlbModelPath(String modelName) {
    return CampaignLevel.resolveGlbPath(modelName);
  }

  @override
  Widget build(BuildContext context) {
    final mission = widget.vault.currentMission;
    final missionTitle = widget.campaignLevel?.title ?? mission.title;
    final missionEra = widget.campaignLevel != null
        ? "${widget.campaignLevel!.code} // ${widget.campaignLevel!.subsystem}"
        : mission.era.toUpperCase();
    final hardware = widget.campaignLevel?.spacecraft ?? mission.hardware;
    final objective = widget.campaignLevel?.objective ?? mission.objective;
    final modelName = widget.campaignLevel?.modelName ?? mission.modelName;
    final glbPath = widget.campaignLevel?.glbModelPath ?? _resolveGlbModelPath(modelName);
    final puzzleType = widget.campaignLevel?.puzzleType ?? "signal";
    final hardwareImage = widget.campaignLevel?.hardwareImagePath;

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

            // 2. Center 3D Model Viewer OR Archival Photographic Viewer
            Positioned.fill(
              child: hardwareImage != null
                  ? _buildArchivalImageViewer(hardwareImage, hardware)
                  : (_supportsNativeModelViewer
                      ? ModelViewer(
                          key: _modelViewerKey,
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

            // 3. Interactive Subsystem Hotspots on Spacecraft
            ..._buildHotspots(puzzleType, hardware),

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

                        // Hardware Badge Pill
                        Flexible(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF38BDF8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Tooltip(
                              message: "$hardware // $missionTitle",
                              child: Text(
                                "${hardware.toUpperCase()} // ${missionTitle.toUpperCase()}",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 9.5,
                                  letterSpacing: 0.6,
                                  fontFamily: NotionTheme.pixelFont,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Mission Era / Level Code
                        Flexible(
                          child: Text(
                            missionEra,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 9.5,
                              fontFamily: NotionTheme.pixelFont,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const Spacer(),

                        // Right: Grouped Action Console
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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

                            // Shuttle Pilot
                            _buildTacticalBtn(
                              icon: LucideIcons.rocket,
                              tooltip: "Pilot Space Shuttle Orbiter",
                              accentColor: const Color(0xFF38BDF8),
                              onTap: () => setState(() => _showShuttleFlight = true),
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

            // 6. Bottom-Left HUD: Subsystem & Objective Briefing
            Positioned(
              left: 14,
              bottom: 12,
              child: SafeArea(
                top: false,
                right: false,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 320),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xEE090F1D),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
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
                            _formatClock(_now),
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: NotionTheme.pixelFont,
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "STATUS: INSPECTING",
                            style: TextStyle(
                              color: const Color(0xFF38BDF8),
                              fontFamily: NotionTheme.pixelFont,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        objective,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 9.5,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 7. Bottom-Right HUD: Primary Investigation Action Button
            Positioned(
              right: 14,
              bottom: 12,
              child: SafeArea(
                top: false,
                left: false,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Companion Mischief Pill
                    if (_mischiefExpanded)
                      GestureDetector(
                        onTap: _cycleMischief,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 240),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xF00B111E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(int.parse(_mischiefMessages[_mischiefIndex]["color"]!)),
                              width: 1.0,
                            ),
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
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Companion Avatar Button
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
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xDD090F1D),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.8),
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(LucideIcons.sparkles, color: Color(0xFF38BDF8), size: 16),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // PRIMARY ACTION: INVESTIGATE SUBSYSTEM
                    ElevatedButton.icon(
                      onPressed: () => _openPuzzle(puzzleType),
                      icon: const Icon(LucideIcons.searchCode, size: 16),
                      label: Text(
                        "INVESTIGATE SUBSYSTEM",
                        style: TextStyle(
                          fontFamily: NotionTheme.pixelFont,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Color(0xFF4ADE80), width: 1.2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 8. Hotspot Subsystem Inspection Overlay Modal
            if (_inspectedHotspot != null)
              Positioned(
                left: 20,
                right: 20,
                bottom: 60,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    decoration: BoxDecoration(
                      color: const Color(0xF50B1220),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                          blurRadius: 18,
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.cpu, size: 16, color: Color(0xFF38BDF8)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _inspectedHotspot!["title"]!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: NotionTheme.pixelFont,
                                    fontSize: 9.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(LucideIcons.x, color: Colors.white54, size: 15),
                                onPressed: () => setState(() => _inspectedHotspot = null),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _inspectedHotspot!["desc"]!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  _openPuzzle(_inspectedHotspot!["puzzleType"]!);
                                },
                                icon: const Icon(LucideIcons.play, size: 12),
                                label: Text(
                                  "ENGAGE ${_inspectedHotspot!['puzzleName']!}",
                                  style: TextStyle(
                                    fontFamily: NotionTheme.pixelFont,
                                    fontSize: 9,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF22C55E),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

            // 9. Victory Celebratory Modal
            if (_showVictoryDialog)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.82),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 440),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C1322),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF22C55E), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                            blurRadius: 24,
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.award, color: Color(0xFF22C55E), size: 40),
                          const SizedBox(height: 10),
                          Text(
                            "SUBSYSTEM RESTORED // 3 STARS",
                            style: TextStyle(
                              color: const Color(0xFF22C55E),
                              fontFamily: NotionTheme.pixelFont,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (index) => const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(LucideIcons.star, color: Color(0xFFF59E0B), size: 24),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _victoryMessage.isNotEmpty
                                ? _victoryMessage
                                : "Authentic physical telemetry validated and unsealed in Evidence Vault.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() => _showVictoryDialog = false);
                                  widget.onReturnToArchive();
                                },
                                icon: const Icon(LucideIcons.chevronLeft, size: 14),
                                label: Text(
                                  "RETURN TO ARCHIVE",
                                  style: TextStyle(
                                    fontFamily: NotionTheme.pixelFont,
                                    fontSize: 9,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  side: const BorderSide(color: Colors.white24),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() => _showVictoryDialog = false);
                                  widget.onReturnToArchive();
                                },
                                icon: const Icon(LucideIcons.check, size: 14),
                                label: Text(
                                  "CONTINUE",
                                  style: TextStyle(
                                    fontFamily: NotionTheme.pixelFont,
                                    fontSize: 9,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF22C55E),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

            // 15. SHUTTLE FLIGHT SIMULATOR
            if (_showShuttleFlight)
              ShuttleFlightView(
                onExitFlight: () => setState(() => _showShuttleFlight = false),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHotspots(String puzzleType, String hardware) {
    if (_showVault || _showSolarMap || _showTimeline || _showStudentGuide || _showShuttleFlight || _activePuzzleType != null || _showVictoryDialog) {
      return [];
    }

    final primaryName = puzzleType.toUpperCase();

    return [
      Positioned(
        top: 110,
        left: 230,
        child: _buildReticle(
          title: "PRIMARY SENSOR // $hardware",
          desc: "Calibrate and verify physical NASA scientific instruments.",
          puzzleType: puzzleType,
          puzzleName: primaryName,
        ),
      ),
      Positioned(
        top: 180,
        left: 310,
        child: _buildReticle(
          title: "TRAJECTORY DYNAMICS",
          desc: "Analyze planetary approach geometry and orbital lines.",
          puzzleType: "flyby",
          puzzleName: "SLINGSHOT TRAJECTORY",
        ),
      ),
      Positioned(
        bottom: 90,
        left: 200,
        child: _buildReticle(
          title: "CHRONOLOGICAL LOG",
          desc: "Examine chronological telemetry packets transmitted from deep space.",
          puzzleType: "telemetry",
          puzzleName: "TELEMETRY CHRONOLOGY",
        ),
      ),
    ];
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

  Widget _buildReticle({
    required String title,
    required String desc,
    required String puzzleType,
    required String puzzleName,
  }) {
    return GestureDetector(
      onTap: () {
        AudioService.playCardSelect();
        setState(() {
          _inspectedHotspot = {
            "title": title,
            "desc": desc,
            "puzzleType": puzzleType,
            "puzzleName": puzzleName,
          };
        });
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xDD090F1D),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 1,
            )
          ],
        ),
        child: const Icon(LucideIcons.crosshair, color: Color(0xFF38BDF8), size: 14),
      ),
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

