import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/campaign_data.dart';
import 'services/vault_service.dart';
import 'services/audio_service.dart';
import 'theme/notion_theme.dart';
import 'screens/main_menu_screen.dart';
import 'screens/world_select_screen.dart';
import 'screens/level_select_screen.dart';
import 'game_2d/exploration_game.dart';
import 'space/space_mission_view.dart';
import 'shuttle/shuttle_flight_view.dart';
import 'dialogs/ember_onboarding_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Strict Landscape orientation lock for mobile gaming by default
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Immersive Fullscreen (hide status bars and navigation bar)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final vaultService = VaultService();

  runApp(EmberGameApp(vaultService: vaultService));
}

typedef MohasunnoGameApp = EmberGameApp;

class EmberGameApp extends StatelessWidget {
  final VaultService vaultService;

  const EmberGameApp({super.key, required this.vaultService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ember: The Space Science Investigation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: NotionTheme.bgDark,
        fontFamily: NotionTheme.fontFamily,
        fontFamilyFallback: const [NotionTheme.fontFamily, 'sans-serif'],
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: NotionTheme.fontFamily,
          bodyColor: NotionTheme.textPrimary,
          displayColor: NotionTheme.textPrimary,
        ),
        colorScheme: const ColorScheme.dark(
          primary: NotionTheme.pastelBlue,
          secondary: NotionTheme.pastelGreen,
          surface: NotionTheme.surfaceCard,
        ),
      ),
      home: GameRootScreen(vault: vaultService),
    );
  }
}

enum GameState {
  mainMenu,
  worldSelect,
  levelSelect,
  exploration2D,
  spaceMission3D,
  shuttleFlight,
}

class GameRootScreen extends StatefulWidget {
  final VaultService vault;

  const GameRootScreen({super.key, required this.vault});

  @override
  State<GameRootScreen> createState() => _GameRootScreenState();
}

class _GameRootScreenState extends State<GameRootScreen> {
  // Main Menu is the first screen by default!
  GameState _gameState = GameState.mainMenu;
  CampaignWorld? _selectedWorld;
  CampaignLevel? _selectedLevel;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    if (!widget.vault.hasCompletedOnboarding) {
      _showOnboarding = true;
    }
  }

  void _switchToMainMenu() {
    AudioService.playClick();
    setState(() {
      _gameState = GameState.mainMenu;
      _selectedLevel = null;
    });
  }

  void _switchToWorldSelect() {
    AudioService.playClick();
    setState(() {
      _gameState = GameState.worldSelect;
      _selectedLevel = null;
    });
  }

  void _switchToLevelSelect(CampaignWorld world) {
    AudioService.playClick();
    setState(() {
      _selectedWorld = world;
      _gameState = GameState.levelSelect;
      _selectedLevel = null;
    });
  }

  void _launchLevel(CampaignLevel level) {
    AudioService.playSuccess();
    setState(() {
      _selectedLevel = level;
      _gameState = GameState.spaceMission3D;
    });
  }

  void _switchToExploration() {
    AudioService.playSuccess();
    setState(() {
      _selectedLevel = null;
      _gameState = GameState.exploration2D;
    });
  }

  void _switchToSpaceMission() {
    AudioService.playSuccess();
    setState(() {
      _selectedLevel = null;
      _gameState = GameState.spaceMission3D;
    });
  }

  void _switchToShuttleFlight() {
    AudioService.playSuccess();
    setState(() {
      _selectedLevel = null;
      _gameState = GameState.shuttleFlight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _gameState == GameState.mainMenu,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _switchToMainMenu();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _buildCurrentStateWidget(),
              ),
            ),
            if (_showOnboarding)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.88),
                  child: EmberOnboardingDialog(
                    vault: widget.vault,
                    onComplete: () {
                      setState(() => _showOnboarding = false);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStateWidget() {
    switch (_gameState) {
      case GameState.mainMenu:
        return MainMenuScreen(
          key: const ValueKey('main_menu_screen'),
          vault: widget.vault,
          onStartGame: _switchToExploration,
          onOpenWorldSelect: _switchToWorldSelect,
          onOpenSpaceMissions: _switchToSpaceMission,
          onOpenShuttleFlight: _switchToShuttleFlight,
          onOpenOnboarding: () => setState(() => _showOnboarding = true),
        );

      case GameState.worldSelect:
        return WorldSelectScreen(
          key: const ValueKey('world_select_screen'),
          vault: widget.vault,
          onSelectWorld: _switchToLevelSelect,
          onReturnToMenu: _switchToMainMenu,
        );

      case GameState.levelSelect:
        final world = _selectedWorld ?? widget.vault.worlds.first;
        return LevelSelectScreen(
          key: ValueKey('level_select_${world.id}'),
          vault: widget.vault,
          world: world,
          onLaunchLevel: _launchLevel,
          onReturnToWorldSelect: _switchToWorldSelect,
        );

      case GameState.exploration2D:
        return ExplorationGameWidget(
          key: const ValueKey('2d_exploration_screen'),
          onLaunchMission: _switchToSpaceMission,
          onReturnToMenu: _switchToMainMenu,
        );

      case GameState.spaceMission3D:
        return SpaceMissionView(
          key: const ValueKey('3d_space_mission_screen'),
          vault: widget.vault,
          campaignLevel: _selectedLevel,
          onReturnToArchive: () {
            if (_selectedLevel != null && _selectedWorld != null) {
              _switchToLevelSelect(_selectedWorld!);
            } else {
              _switchToMainMenu();
            }
          },
          onReturnToMenu: _switchToMainMenu,
        );

      case GameState.shuttleFlight:
        return ShuttleFlightView(
          key: const ValueKey('shuttle_flight_screen'),
          onExitFlight: _switchToMainMenu,
        );
    }
  }
}
