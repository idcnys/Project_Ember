import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/audio_service.dart';
import '../theme/notion_theme.dart';

class ExplorationGameWidget extends StatefulWidget {
  final VoidCallback onLaunchMission;
  final VoidCallback? onReturnToMenu;

  const ExplorationGameWidget({
    super.key,
    required this.onLaunchMission,
    this.onReturnToMenu,
  });

  @override
  State<ExplorationGameWidget> createState() => _ExplorationGameWidgetState();
}

class _ExplorationGameWidgetState extends State<ExplorationGameWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  final FocusNode _focusNode = FocusNode();

  // Loaded Assets
  ui.Image? _avatarImg;
  ui.Image? _outsideBgImg;
  ui.Image? _archiveBgImg;
  ui.Image? _moonBgImg;
  ui.Image? _deskImg;
  ui.Image? _doorStandardOpen;
  ui.Image? _doorStandardClosed;
  ui.Image? _doorLabOpen;
  ui.Image? _hazardStripe;
  ui.Image? _signCaution;
  ui.Image? _signRadiation;
  ui.Image? _roomLabelCtrl;
  ui.Image? _doorGlow;
  bool _assetsLoaded = false;

  // Scene state: "outside", "archive", "moon"
  String _currentScene = "outside";
  bool _isTransitioning = false;
  double _fadeOpacity = 0.0;

  // Time Travel Warp State
  bool _showTimeTravel = false;
  int _warpYear = 2027;
  Timer? _warpTimer;

  // Player physics
  double _playerWorldX = 80.0;
  double _playerY = 0.0;
  double _vx = 0.0;
  double _vy = 0.0;
  bool _isGrounded = false;
  bool _facingRight = true;

  // Animation frame
  int _animFrame = 0;
  int _animStepCounter = 0;

  // UI state
  String _questText = "Walk right towards the NASA Archive Security Gate to begin recovery.";
  bool _showGatePopup = false;
  String _popupTitle = "";
  String _popupDesc = "";
  String _popupBtnText = "";
  IconData _popupIcon = LucideIcons.alertTriangle;
  VoidCallback? _popupAction;

  // Terminal Chat State
  bool _isChatOpen = false;
  int _chatStep = 0;
  final List<Map<String, String>> _chatMessages = [
    {
      "badge": "TULIP // EMERGENCY BROADCAST",
      "step": "TRANSMISSION 1 / 3",
      "title": "[CRITICAL ALERT — YEAR 2027]",
      "sender": "DIRECTOR VANCE // NASA ARCHIVES",
      "content":
          "To whoever finds this terminal: EVA has completed its planetary isolation sweep. The cloud is dead. Digital historical records across Earth have been locked down. But our physical spacecraft—Pioneer 10, Apollo 11 Eagle, Opportunity, Kepler—are still out there in deep space, beyond EVA's reach.",
      "btn": "PROCEED TO TRANSMISSION 2",
    },
    {
      "badge": "TULIP // TEMPORAL RECONSTRUCTION",
      "step": "TRANSMISSION 2 / 3",
      "title": "[WARP PROTOCOL 2047 READY]",
      "sender": "CHIEF TELEMETRY ENGINEER AMINA",
      "content":
          "We have calibrated this TULIP workstation with a predictive temporal simulation bridge to the year 2047. By inspecting the physical hardware left on the Moon, Mars, and deep space, you can reconstruct the unalterable empirical science EVA cannot rewrite.",
      "btn": "INITIATE TEMPORAL WARP",
    },
    {
      "badge": "TULIP // MISSION LAUNCH",
      "step": "TRANSMISSION 3 / 3",
      "title": "[TEMPORAL SIMULATION ARMED]",
      "sender": "EVA ISOLATION PROTOCOL // BYPASSED",
      "content":
          "Link confirmed. Ready to bridge forward to Year 2047 and launch reconstructed mission telemetry across the Solar System. Select your first destination and restore humanity's empirical proof!",
      "btn": "WARP FORWARD TO 2047",
    },
  ];

  // Touch Inputs
  bool _inputLeft = false;
  bool _inputRight = false;
  bool _inputJump = false;
  bool _inputSprint = false;

  @override
  void initState() {
    super.initState();
    _loadAllAssets();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _ticker.addListener(_gameLoop);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focusNode.dispose();
    _warpTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAllAssets() async {
    try {
      final avatar = await _loadUiImage('assets/images/avatar.png');
      final outsideBg = await _loadUiImage('assets/images/bg.jpeg');
      final archiveBg = await _loadUiImage('assets/scifi/rooms/operations_room.png');
      final moonBg = await _loadUiImage('assets/scifi/moon/Moon_Tileset_B.png');
      final desk = await _loadUiImage('assets/images/computer_desk.png');

      final doorOpen = await _loadUiImage('assets/scifi/ui/door_standard_open.png');
      final doorClosed = await _loadUiImage('assets/scifi/ui/door_standard_closed.png');
      final doorLab = await _loadUiImage('assets/scifi/ui/door_lab_open.png');
      final hazard = await _loadUiImage('assets/scifi/ui/hazard_stripe_H.png');
      final caution = await _loadUiImage('assets/scifi/ui/sign_caution.png');
      final radiation = await _loadUiImage('assets/scifi/ui/sign_radiation.png');
      final labelCtrl = await _loadUiImage('assets/scifi/ui/room_label_ctrl.png');
      final glow = await _loadUiImage('assets/scifi/ui/door_indicator_glow_1.png');

      if (mounted) {
        setState(() {
          _avatarImg = avatar;
          _outsideBgImg = outsideBg;
          _archiveBgImg = archiveBg;
          _moonBgImg = moonBg;
          _deskImg = desk;
          _doorStandardOpen = doorOpen;
          _doorStandardClosed = doorClosed;
          _doorLabOpen = doorLab;
          _hazardStripe = hazard;
          _signCaution = caution;
          _signRadiation = radiation;
          _roomLabelCtrl = labelCtrl;
          _doorGlow = glow;
          _assetsLoaded = true;
        });
      }
    } catch (e) {
      debugPrint("Asset loading error: $e");
    }
  }

  Future<ui.Image> _loadUiImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  void _gameLoop() {
    if (!_assetsLoaded || _isTransitioning || _showTimeTravel) return;

    final mediaQuery = MediaQuery.of(context);
    final screenW = mediaQuery.size.width;
    final screenH = mediaQuery.size.height;
    if (screenW <= 0 || screenH <= 0) return;

    ui.Image? activeBg;
    if (_currentScene == "outside") {
      activeBg = _outsideBgImg;
    } else if (_currentScene == "moon") {
      activeBg = _moonBgImg;
    } else {
      activeBg = _archiveBgImg;
    }

    final bgNaturalW = (activeBg != null)
        ? activeBg.width.toDouble()
        : (_currentScene == "outside" ? 5536.0 : 1920.0);
    final bgNaturalH = (activeBg != null)
        ? activeBg.height.toDouble()
        : (_currentScene == "outside" ? 768.0 : 1080.0);

    // Full-bleed cover scale
    final bgScale = math.max(screenH / bgNaturalH, screenW / bgNaturalW);
    final bgRenderW = bgNaturalW * bgScale;
    final bgRenderH = bgNaturalH * bgScale;
    final bgY = screenH - bgRenderH;
    final unit = bgRenderH / 300.0;

    final playerW = 50.0 * unit;
    final playerH = 80.0 * unit;
    final floorY = (bgY + bgRenderH) - (28.0 * unit);
    final groundPlayerY = floorY - playerH;

    // Speeds & Physics (Moon gravity is lower!)
    final isMoon = (_currentScene == "moon");
    final baseSpeed = (isMoon ? 1.8 : 2.2) * unit;
    final sprintSpeed = (isMoon ? 3.0 : 3.6) * unit;
    final moveSpeed = _inputSprint ? sprintSpeed : baseSpeed;
    final jumpForce = (isMoon ? -6.8 : -5.4) * unit;
    final baseGravity = (isMoon ? 0.16 : 0.35);

    // Horizontal Movement
    double targetVx = 0.0;
    if (_inputLeft) {
      targetVx -= moveSpeed;
      _facingRight = false;
    }
    if (_inputRight) {
      targetVx += moveSpeed;
      _facingRight = true;
    }

    _vx = _vx * 0.75 + targetVx * 0.25;
    _playerWorldX += _vx;

    // Boundaries
    final minX = playerW / 2;
    final maxX = bgRenderW - (playerW / 2);
    _playerWorldX = _playerWorldX.clamp(minX, maxX);

    // Jump Physics
    if (_inputJump && _isGrounded) {
      _vy = jumpForce;
      _isGrounded = false;
      AudioService.playClick();
    }

    if (!_isGrounded) {
      _playerY += _vy;
      _vy += baseGravity * unit;
      if (_playerY >= groundPlayerY) {
        _playerY = groundPlayerY;
        _vy = 0;
        _isGrounded = true;
      }
    } else {
      _playerY = groundPlayerY;
    }

    // Animation frame update
    final isMoving = _vx.abs() > 0.2 * unit;
    final animRate = _inputSprint ? 4 : 7;
    if (_isGrounded) {
      if (isMoving) {
        _animStepCounter++;
        if (_animStepCounter >= animRate) {
          _animFrame = (_animFrame + 1) % 4;
          _animStepCounter = 0;
        }
      } else {
        _animFrame = 0;
        _animStepCounter = 0;
      }
    } else {
      _animFrame = 1;
    }

    // Zone detections
    if (_currentScene == "outside") {
      final gateMinX = bgRenderW * 0.65;
      final gateMaxX = bgRenderW * 0.74;
      final isNearGate = (_playerWorldX >= gateMinX && _playerWorldX <= gateMaxX);

      if (isNearGate) {
        if (!_showGatePopup) {
          setState(() {
            _showGatePopup = true;
            _popupTitle = "NASA ARCHIVE AIRLOCK";
            _popupDesc = "Central Records Facility Security Gate";
            _popupBtnText = "Enter NASA Facility";
            _popupIcon = LucideIcons.doorOpen;
            _popupAction = () => _transitionToScene("archive");
            _questText = "Security airlock unlocked! Tap 'Enter NASA Facility' or [Action].";
          });
        }
      } else {
        if (_showGatePopup) {
          setState(() {
            _showGatePopup = false;
            _questText = "Walk right towards the NASA Archive Gate to begin recovery.";
          });
        }
      }
    } else if (_currentScene == "archive") {
      // Exit door check
      final exitMaxX = bgRenderW * 0.16;
      final isNearExit = (_playerWorldX <= exitMaxX);
      if (isNearExit) {
        if (!_showGatePopup) {
          setState(() {
            _showGatePopup = true;
            _popupTitle = "EXIT TO LAUNCHPAD";
            _popupDesc = "Door B-3 to Launch Site Surface";
            _popupBtnText = "Exit to Outside";
            _popupIcon = LucideIcons.doorClosed;
            _popupAction = () => _transitionToScene("outside");
          });
        }
      } else {
        if (_showGatePopup) {
          setState(() {
            _showGatePopup = false;
          });
        }
      }

      // Computer desk check
      final deskWorldX = bgRenderW * 0.50;
      final deskW = 116.0 * unit;
      final deskCenter = deskWorldX + (deskW / 2);
      final isNearDesk = (_playerWorldX - deskCenter).abs() < (110.0 * unit);

      if (isNearDesk) {
        if (!_isChatOpen) {
          setState(() {
            _isChatOpen = true;
            _chatStep = 0;
            _questText = "TULIP Workstation connected! Review transmissions and start mission.";
          });
          AudioService.playAlert();
        }
      } else {
        if (_isChatOpen) {
          setState(() {
            _isChatOpen = false;
            _questText = "Approach the glowing TULIP Computer Workstation in the archive center.";
          });
        }
      }
    } else if (_currentScene == "moon") {
      final airlockMinX = bgRenderW * 0.05;
      final airlockMaxX = bgRenderW * 0.18;
      final isNearAirlock = (_playerWorldX >= airlockMinX && _playerWorldX <= airlockMaxX);

      if (isNearAirlock) {
        if (!_showGatePopup) {
          setState(() {
            _showGatePopup = true;
            _popupTitle = "LUNAR HABITAT AIRLOCK";
            _popupDesc = "Tranquility Station Pressure Chamber";
            _popupBtnText = "Return to Earth Archive";
            _popupIcon = LucideIcons.arrowLeft;
            _popupAction = () => _transitionToScene("archive");
          });
        }
      } else {
        if (_showGatePopup) {
          setState(() {
            _showGatePopup = false;
            _questText = "Lunar surface explored. Low gravity active (0.16g).";
          });
        }
      }
    }

    setState(() {});
  }

  void _transitionToScene(String targetScene) {
    if (_isTransitioning) return;
    _isTransitioning = true;
    AudioService.playClick();

    setState(() {
      _showGatePopup = false;
      _isChatOpen = false;
      _fadeOpacity = 1.0;
    });

    Timer(const Duration(milliseconds: 350), () {
      final mediaQuery = MediaQuery.of(context);
      final screenW = mediaQuery.size.width;
      final screenH = mediaQuery.size.height;

      if (targetScene == "archive") {
        _currentScene = "archive";
        _questText = "Approach the glowing TULIP Computer Workstation in the archive center.";
        final bg = _archiveBgImg;
        final nw = bg?.width.toDouble() ?? 1920.0;
        final nh = bg?.height.toDouble() ?? 1080.0;
        final s = math.max(screenH / nh, screenW / nw);
        _playerWorldX = nw * s * 0.15;
        _facingRight = true;
      } else if (targetScene == "moon") {
        _currentScene = "moon";
        _questText = "Lunar Surface Active. Apollo Tranquility Base artifacts detected.";
        final bg = _moonBgImg;
        final nw = bg?.width.toDouble() ?? 768.0;
        final nh = bg?.height.toDouble() ?? 768.0;
        final s = math.max(screenH / nh, screenW / nw);
        _playerWorldX = nw * s * 0.12;
        _facingRight = true;
      } else {
        _currentScene = "outside";
        _questText = "Walk right towards the NASA Archive Gate to begin recovery.";
        final bg = _outsideBgImg;
        final nw = bg?.width.toDouble() ?? 5536.0;
        final nh = bg?.height.toDouble() ?? 768.0;
        final s = math.max(screenH / nh, screenW / nw);
        _playerWorldX = nw * s * 0.60;
        _facingRight = false;
      }

      setState(() {
        _fadeOpacity = 0.0;
        _isTransitioning = false;
      });
    });
  }

  void _advanceChatStep() {
    AudioService.playClick();
    if (_chatStep < 2) {
      setState(() => _chatStep++);
    } else {
      // Trigger Temporal Warp 2027 -> 2047
      _startTimeTravel();
    }
  }

  void _startTimeTravel() {
    AudioService.playAlert();
    setState(() {
      _isChatOpen = false;
      _showTimeTravel = true;
      _warpYear = 2027;
    });

    _warpTimer?.cancel();
    _warpTimer = Timer.periodic(const Duration(milliseconds: 140), (t) {
      setState(() {
        if (_warpYear < 2047) {
          _warpYear += 2;
          AudioService.playClick();
        } else {
          _warpYear = 2047;
          t.cancel();
          Timer(const Duration(milliseconds: 900), () {
            AudioService.playSuccess();
            widget.onLaunchMission();
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Canvas Game Renderer
          Positioned.fill(
            child: CustomPaint(
              painter: _GameCanvasPainter(
                currentScene: _currentScene,
                outsideBgImg: _outsideBgImg,
                archiveBgImg: _archiveBgImg,
                moonBgImg: _moonBgImg,
                avatarImg: _avatarImg,
                deskImg: _deskImg,
                doorStandardOpen: _doorStandardOpen,
                doorStandardClosed: _doorStandardClosed,
                doorLabOpen: _doorLabOpen,
                hazardStripe: _hazardStripe,
                signCaution: _signCaution,
                signRadiation: _signRadiation,
                roomLabelCtrl: _roomLabelCtrl,
                doorGlow: _doorGlow,
                playerWorldX: _playerWorldX,
                playerY: _playerY,
                facingRight: _facingRight,
                animFrame: _animFrame,
              ),
            ),
          ),

          // 2. Tactical HUD Top Bar
          Positioned(
            top: 14,
            left: 20,
            right: 20,
            child: Row(
              children: [
                // Location Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: NotionTheme.pastelBlue.withValues(alpha: 0.4), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.radio, size: 14, color: NotionTheme.pastelBlue),
                      const SizedBox(width: 8),
                      Text(
                        _currentScene == "outside"
                            ? "GROUND COMPLEX // LAUNCHPAD SECTOR"
                            : _currentScene == "moon"
                                ? "LUNAR SURFACE // TRANQUILITY BASE (0.16G)"
                                : "NASA ARCHIVE // TULIP RECON LAB",
                        style: const TextStyle(
                          color: NotionTheme.pastelBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.5,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Quest Banner
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: NotionTheme.borderMuted, width: 0.8),
                    ),
                    child: Text(
                      _questText,
                      style: const TextStyle(
                        color: NotionTheme.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Sector Switcher Pill (Outside / Archive / Moonbase)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: NotionTheme.borderLight),
                  ),
                  child: Row(
                    children: [
                      _buildSceneButton("outside", "Launchpad"),
                      const SizedBox(width: 4),
                      _buildSceneButton("archive", "TULIP Lab"),
                      const SizedBox(width: 4),
                      _buildSceneButton("moon", "Moon Base"),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                if (widget.onReturnToMenu != null) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      AudioService.playClick();
                      widget.onReturnToMenu!();
                    },
                    icon: const Icon(LucideIcons.home, size: 14, color: NotionTheme.pastelAmber),
                    label: const Text(
                      "HUB",
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NotionTheme.surfaceElevated,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: NotionTheme.borderMuted),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                ElevatedButton.icon(
                  onPressed: widget.onLaunchMission,
                  icon: const Icon(LucideIcons.rocket, size: 14, color: NotionTheme.pastelGreen),
                  label: const Text(
                    "3D PROBE LAB",
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NotionTheme.pastelGreenBg,
                    foregroundColor: NotionTheme.pastelGreen,
                    side: const BorderSide(color: NotionTheme.pastelGreen, width: 0.8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ],
            ),
          ),

          // 3. Gate Popup Modal
          if (_showGatePopup)
            Positioned(
              bottom: 85,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: NotionTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: NotionTheme.pastelBlue, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: NotionTheme.pastelBlue.withValues(alpha: 0.25),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: NotionTheme.pastelAmber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(_popupIcon, size: 20, color: NotionTheme.pastelAmber),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _popupTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text(
                            _popupDesc,
                            style: const TextStyle(
                              color: NotionTheme.textSecondary,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _popupAction,
                        icon: const Icon(LucideIcons.arrowRight, size: 13),
                        label: Text(_popupBtnText),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NotionTheme.pastelBlue,
                          foregroundColor: Colors.black,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 4. TULIP Workstation Dialogue Modal
          if (_isChatOpen)
            Positioned(
              left: 16,
              right: 16,
              bottom: 60,
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: 580,
                    maxHeight: MediaQuery.of(context).size.height * 0.78,
                  ),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: NotionTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: NotionTheme.pastelGreen, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: NotionTheme.pastelGreen.withValues(alpha: 0.2),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      // Header
                      Row(
                        children: [
                          const Icon(LucideIcons.tablet, size: 18, color: NotionTheme.pastelGreen),
                          const SizedBox(width: 8),
                          Text(
                            _chatMessages[_chatStep]["badge"]!,
                            style: const TextStyle(
                              color: NotionTheme.pastelGreen,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 10.5,
                            ),
                          ),
                          const Spacer(),
                          NotionTheme.badge(
                            text: _chatMessages[_chatStep]["step"]!,
                            textColor: NotionTheme.pastelAmber,
                            bgColor: NotionTheme.pastelAmberBg,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _chatMessages[_chatStep]["title"]!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _chatMessages[_chatStep]["sender"]!,
                        style: const TextStyle(
                          color: NotionTheme.textSecondary,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Divider(color: NotionTheme.borderLight, height: 16),
                      Text(
                        _chatMessages[_chatStep]["content"]!,
                        style: const TextStyle(
                          color: NotionTheme.textPrimary,
                          fontSize: 11.5,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Row(
                            children: List.generate(3, (idx) {
                              return Container(
                                width: 7,
                                height: 7,
                                margin: const EdgeInsets.only(right: 5),
                                decoration: BoxDecoration(
                                  color: (idx == _chatStep)
                                      ? NotionTheme.pastelGreen
                                      : NotionTheme.textTertiary,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: _advanceChatStep,
                            icon: Icon(
                              _chatStep == 2 ? LucideIcons.rocket : LucideIcons.chevronRight,
                              size: 14,
                            ),
                            label: Text(_chatMessages[_chatStep]["btn"]!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NotionTheme.pastelGreen,
                              foregroundColor: Colors.black,
                              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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

          // 5. Temporal Warp Overlay
          if (_showTimeTravel)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.92),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NotionTheme.subtleLoader(size: 32, color: NotionTheme.pastelBlue),
                      const SizedBox(height: 16),
                      const Text(
                        "BRIDGING TEMPORAL TELEMETRY",
                        style: TextStyle(
                          color: NotionTheme.pastelBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "YEAR $_warpYear",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.0,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: 280,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: NotionTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: NotionTheme.borderMuted),
                        ),
                        child: Text(
                          _warpYear == 2047
                              ? "WARP COMPLETE: Solar telemetry links synchronized!"
                              : "ADVANCING SIMULATION MATRIX... (2027 -> 2047)",
                          style: TextStyle(
                            color: _warpYear == 2047 ? NotionTheme.pastelGreen : NotionTheme.pastelAmber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 6. On-Screen Touch Controls (Left D-Pad & Right Actions)
          Positioned(
            left: 20,
            bottom: 16,
            child: Row(
              children: [
                _buildTouchButton(
                  icon: LucideIcons.arrowLeft,
                  onPress: () => _inputLeft = true,
                  onRelease: () => _inputLeft = false,
                ),
                const SizedBox(width: 12),
                _buildTouchButton(
                  icon: LucideIcons.arrowRight,
                  onPress: () => _inputRight = true,
                  onRelease: () => _inputRight = false,
                ),
              ],
            ),
          ),

          Positioned(
            right: 20,
            bottom: 16,
            child: Row(
              children: [
                _buildTouchButton(
                  icon: LucideIcons.hand,
                  isAction: true,
                  activeColor: NotionTheme.pastelGreen,
                  onPress: () {
                    AudioService.playClick();
                    if (_isChatOpen) {
                      _advanceChatStep();
                    } else if (_showGatePopup && _popupAction != null) {
                      _popupAction!();
                    }
                  },
                ),
                const SizedBox(width: 10),
                _buildTouchButton(
                  icon: LucideIcons.zap,
                  isAction: true,
                  activeColor: NotionTheme.pastelAmber,
                  onPress: () => _inputSprint = true,
                  onRelease: () => _inputSprint = false,
                ),
                const SizedBox(width: 10),
                _buildTouchButton(
                  icon: LucideIcons.arrowUp,
                  isAction: true,
                  activeColor: NotionTheme.pastelBlue,
                  onPress: () => _inputJump = true,
                  onRelease: () => _inputJump = false,
                ),
              ],
            ),
          ),

          // Fade transition
          IgnorePointer(
            ignoring: _fadeOpacity == 0.0,
            child: AnimatedOpacity(
              opacity: _fadeOpacity,
              duration: const Duration(milliseconds: 250),
              child: Container(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneButton(String scene, String label) {
    final isSelected = _currentScene == scene;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          _transitionToScene(scene);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? NotionTheme.pastelBlueBg : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? NotionTheme.pastelBlue.withValues(alpha: 0.5) : Colors.transparent,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? NotionTheme.pastelBlue : NotionTheme.textSecondary,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTouchButton({
    required IconData icon,
    bool isAction = false,
    Color activeColor = const Color(0xFF38BDF8),
    required VoidCallback onPress,
    VoidCallback? onRelease,
  }) {
    return GestureDetector(
      onTapDown: (_) => onPress(),
      onTapUp: (_) => onRelease?.call(),
      onTapCancel: () => onRelease?.call(),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xCC0F172A),
          shape: BoxShape.circle,
          border: Border.all(
            color: activeColor.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: activeColor.withValues(alpha: 0.2),
              blurRadius: 8,
            )
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _GameCanvasPainter extends CustomPainter {
  final String currentScene;
  final ui.Image? outsideBgImg;
  final ui.Image? archiveBgImg;
  final ui.Image? moonBgImg;
  final ui.Image? avatarImg;
  final ui.Image? deskImg;
  final ui.Image? doorStandardOpen;
  final ui.Image? doorStandardClosed;
  final ui.Image? doorLabOpen;
  final ui.Image? hazardStripe;
  final ui.Image? signCaution;
  final ui.Image? signRadiation;
  final ui.Image? roomLabelCtrl;
  final ui.Image? doorGlow;
  final double playerWorldX;
  final double playerY;
  final bool facingRight;
  final int animFrame;

  _GameCanvasPainter({
    required this.currentScene,
    required this.outsideBgImg,
    required this.archiveBgImg,
    required this.moonBgImg,
    required this.avatarImg,
    required this.deskImg,
    required this.doorStandardOpen,
    required this.doorStandardClosed,
    required this.doorLabOpen,
    required this.hazardStripe,
    required this.signCaution,
    required this.signRadiation,
    required this.roomLabelCtrl,
    required this.doorGlow,
    required this.playerWorldX,
    required this.playerY,
    required this.facingRight,
    required this.animFrame,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Fallback background
    final bgPaint = Paint()
      ..color = (currentScene == "outside")
          ? const Color(0xFFD69B95)
          : (currentScene == "moon" ? const Color(0xFF14171F) : const Color(0xFF0D192E));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    ui.Image? activeBg;
    if (currentScene == "outside") {
      activeBg = outsideBgImg;
    } else if (currentScene == "moon") {
      activeBg = moonBgImg;
    } else {
      activeBg = archiveBgImg;
    }

    final bgNaturalW = (activeBg != null)
        ? activeBg.width.toDouble()
        : (currentScene == "outside" ? 5536.0 : 1920.0);
    final bgNaturalH = (activeBg != null)
        ? activeBg.height.toDouble()
        : (currentScene == "outside" ? 768.0 : 1080.0);

    final bgScale = math.max(size.height / bgNaturalH, size.width / bgNaturalW);
    final bgRenderW = bgNaturalW * bgScale;
    final bgRenderH = bgNaturalH * bgScale;
    final bgY = size.height - bgRenderH;
    final unit = bgRenderH / 300.0;

    final playerW = 50.0 * unit;
    final playerH = 80.0 * unit;

    // Camera scrolling
    final screenCenterX = size.width / 2;
    final idealBgX = screenCenterX - playerWorldX;
    final minBgX = size.width - bgRenderW;
    final maxBgX = 0.0;
    final bgX = idealBgX.clamp(minBgX, maxBgX);

    final playerScreenX = playerWorldX + bgX - (playerW / 2);
    final floorY = (bgY + bgRenderH) - (28.0 * unit);

    // 1. Draw Background
    if (activeBg != null) {
      canvas.drawImageRect(
        activeBg,
        Rect.fromLTWH(0, 0, activeBg.width.toDouble(), activeBg.height.toDouble()),
        Rect.fromLTWH(bgX, bgY, bgRenderW, bgRenderH),
        Paint()..filterQuality = FilterQuality.medium,
      );
    }

    // 2. Draw Scene-Specific World Props & Architecture
    if (currentScene == "outside") {
      // Draw Sci-Fi Security Gate at ~0.70 of launchpad
      final gateWorldX = bgRenderW * 0.70;
      final gateScreenX = gateWorldX + bgX;
      final gateW = 60.0 * unit;
      final gateH = 90.0 * unit;
      final isNearGate = (playerWorldX - gateWorldX).abs() < (70.0 * unit);

      // Floor Hazard Stripe threshold
      if (hazardStripe != null) {
        canvas.drawImageRect(
          hazardStripe!,
          Rect.fromLTWH(0, 0, hazardStripe!.width.toDouble(), hazardStripe!.height.toDouble()),
          Rect.fromLTWH(gateScreenX - (30 * unit), floorY - (4 * unit), 120 * unit, 8 * unit),
          Paint()..filterQuality = FilterQuality.medium,
        );
      }

      // Door frame & sliding doors
      final doorImg = isNearGate ? doorStandardOpen : doorStandardClosed;
      if (doorImg != null) {
        canvas.drawImageRect(
          doorImg,
          Rect.fromLTWH(0, 0, doorImg.width.toDouble(), doorImg.height.toDouble()),
          Rect.fromLTWH(gateScreenX, floorY - gateH, gateW, gateH),
          Paint()..filterQuality = FilterQuality.medium,
        );
      }

      // Warning Sign
      if (signCaution != null) {
        canvas.drawImageRect(
          signCaution!,
          Rect.fromLTWH(0, 0, signCaution!.width.toDouble(), signCaution!.height.toDouble()),
          Rect.fromLTWH(gateScreenX + gateW + (8 * unit), floorY - (60 * unit), 20 * unit, 20 * unit),
          Paint()..filterQuality = FilterQuality.medium,
        );
      }

      // Door indicator glow
      if (doorGlow != null) {
        canvas.drawImageRect(
          doorGlow!,
          Rect.fromLTWH(0, 0, doorGlow!.width.toDouble(), doorGlow!.height.toDouble()),
          Rect.fromLTWH(gateScreenX + (gateW / 2) - (8 * unit), floorY - gateH - (12 * unit), 16 * unit, 16 * unit),
          Paint()..filterQuality = FilterQuality.medium,
        );
      }
    } else if (currentScene == "archive") {
      // Draw Exit Door at Left (~0.12)
      final exitWorldX = bgRenderW * 0.12;
      final exitScreenX = exitWorldX + bgX;
      final exitW = 52.0 * unit;
      final exitH = 86.0 * unit;

      if (doorLabOpen != null) {
        canvas.drawImageRect(
          doorLabOpen!,
          Rect.fromLTWH(0, 0, doorLabOpen!.width.toDouble(), doorLabOpen!.height.toDouble()),
          Rect.fromLTWH(exitScreenX, floorY - exitH, exitW, exitH),
          Paint()..filterQuality = FilterQuality.medium,
        );
      }

      // Radiation Sign
      if (signRadiation != null) {
        canvas.drawImageRect(
          signRadiation!,
          Rect.fromLTWH(0, 0, signRadiation!.width.toDouble(), signRadiation!.height.toDouble()),
          Rect.fromLTWH(exitScreenX + exitW + (6 * unit), floorY - (64 * unit), 18 * unit, 18 * unit),
          Paint()..filterQuality = FilterQuality.medium,
        );
      }

      // Center Computer Desk
      final deskWorldX = bgRenderW * 0.50;
      final deskW = 116.0 * unit;
      final deskH = 92.0 * unit;
      final deskScreenX = deskWorldX + bgX;
      final deskScreenY = floorY - deskH;

      // Contact shadow under desk
      final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.45);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(deskScreenX + (deskW / 2), floorY + (2 * unit)),
          width: deskW * 0.96,
          height: 12 * unit,
        ),
        shadowPaint,
      );

      // Floor Hazard Stripe under desk
      if (hazardStripe != null) {
        canvas.drawImageRect(
          hazardStripe!,
          Rect.fromLTWH(0, 0, hazardStripe!.width.toDouble(), hazardStripe!.height.toDouble()),
          Rect.fromLTWH(deskScreenX - (10 * unit), floorY - (3 * unit), deskW + (20 * unit), 6 * unit),
          Paint()..filterQuality = FilterQuality.medium,
        );
      }

      // Desk Sprite
      if (deskImg != null) {
        canvas.drawImageRect(
          deskImg!,
          Rect.fromLTWH(0, 0, deskImg!.width.toDouble(), deskImg!.height.toDouble()),
          Rect.fromLTWH(deskScreenX, deskScreenY, deskW, deskH),
          Paint()..filterQuality = FilterQuality.medium,
        );
      }

      // Room Label above Desk
      if (roomLabelCtrl != null) {
        canvas.drawImageRect(
          roomLabelCtrl!,
          Rect.fromLTWH(0, 0, roomLabelCtrl!.width.toDouble(), roomLabelCtrl!.height.toDouble()),
          Rect.fromLTWH(deskScreenX + (deskW / 2) - (24 * unit), deskScreenY - (22 * unit), 48 * unit, 14 * unit),
          Paint()..filterQuality = FilterQuality.medium,
        );
      }

      // CRT Glow
      final glowPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(deskScreenX + (38 * unit), deskScreenY + (38 * unit)),
          48 * unit,
          [
            const Color(0x6622C55E),
            const Color(0x1122C55E),
            const Color(0x0022C55E),
          ],
          [0.0, 0.6, 1.0],
        );
      canvas.drawRect(
        Rect.fromLTWH(deskScreenX - (10 * unit), deskScreenY - (10 * unit), deskW + (20 * unit), deskH + (20 * unit)),
        glowPaint,
      );
    } else if (currentScene == "moon") {
      // Draw Moon Base Airlock at Left
      final airlockWorldX = bgRenderW * 0.10;
      final airlockScreenX = airlockWorldX + bgX;
      final airlockW = 56.0 * unit;
      final airlockH = 88.0 * unit;

      if (doorStandardClosed != null) {
        canvas.drawImageRect(
          doorStandardClosed!,
          Rect.fromLTWH(0, 0, doorStandardClosed!.width.toDouble(), doorStandardClosed!.height.toDouble()),
          Rect.fromLTWH(airlockScreenX, floorY - airlockH, airlockW, airlockH),
          Paint()..filterQuality = FilterQuality.medium,
        );
      }

      // Moon Regolith Dust Drift Atmosphere
      final dustPaint = Paint()..color = Colors.white.withValues(alpha: 0.08);
      for (int i = 0; i < 20; i++) {
        final dx = ((i * 87.0) % size.width);
        final dy = floorY - 30 - ((i * 23.0) % 80);
        canvas.drawCircle(Offset(dx, dy), 1.5, dustPaint);
      }
    }

    // 3. Draw Player
    if (avatarImg != null) {
      canvas.save();
      const frameSrcW = 138.0;
      const frameSrcH = 330.0;
      final srcX = animFrame * frameSrcW;

      final srcRect = Rect.fromLTWH(srcX, 0, frameSrcW, frameSrcH);
      final dstRect = Rect.fromLTWH(playerScreenX, playerY, playerW, playerH);

      if (facingRight) {
        canvas.drawImageRect(
          avatarImg!,
          srcRect,
          dstRect,
          Paint()..filterQuality = FilterQuality.medium,
        );
      } else {
        canvas.translate(playerScreenX + playerW, playerY);
        canvas.scale(-1, 1);
        canvas.drawImageRect(
          avatarImg!,
          srcRect,
          Rect.fromLTWH(0, 0, playerW, playerH),
          Paint()..filterQuality = FilterQuality.medium,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _GameCanvasPainter oldDelegate) {
    return true;
  }
}
