import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/campaign_data.dart';
import 'services/vault_service.dart';
import 'services/audio_service.dart';
import 'theme/notion_theme.dart';
import 'screens/main_menu_screen.dart';
import 'screens/world_select_screen.dart';
import 'screens/level_select_screen.dart';
import 'space/space_mission_view.dart';
import 'dialogs/ember_onboarding_dialog.dart';
import 'screens/model_museum_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Strict Landscape orientation lock for mobile gaming by default
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Immersive Fullscreen (hide status bars and navigation bar)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize AudioService so BGM and SFX mix concurrently without interruption
  await AudioService.init();

  final vaultService = VaultService();

  runApp(EmberGameApp(vaultService: vaultService));
}

typedef MohasunnoGameApp = EmberGameApp;

class EmberGameApp extends StatelessWidget {
  final VaultService vaultService;
  final bool showSplash;

  const EmberGameApp({
    super.key,
    required this.vaultService,
    this.showSplash = true,
  });

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
      home: GameRootScreen(vault: vaultService, showSplash: showSplash),
    );
  }
}

enum GameState {
  splash,
  mainMenu,
  worldSelect,
  levelSelect,
  spaceMission3D,
  modelMuseum,
}

class GameRootScreen extends StatefulWidget {
  final VaultService vault;
  final bool showSplash;

  const GameRootScreen({
    super.key,
    required this.vault,
    this.showSplash = true,
  });

  @override
  State<GameRootScreen> createState() => _GameRootScreenState();
}

class _GameRootScreenState extends State<GameRootScreen> {
  // Splash is shown on initial launch, then switches to Main Menu
  late GameState _gameState;
  CampaignWorld? _selectedWorld;
  CampaignLevel? _selectedLevel;
  bool _showOnboarding = false;
  bool _isFromModelMuseum = false;

  @override
  void initState() {
    super.initState();
    _gameState = widget.showSplash ? GameState.splash : GameState.mainMenu;

    if (!widget.showSplash) {
      AudioService.startBgm();
      if (!widget.vault.hasCompletedOnboarding) {
        _showOnboarding = true;
      }
    }
  }

  void _switchToMainMenu() {
    AudioService.playClick();
    setState(() {
      _gameState = GameState.mainMenu;
      _selectedLevel = null;
      _isFromModelMuseum = false;
    });
  }

  void _switchToWorldSelect() {
    AudioService.playClick();
    setState(() {
      _gameState = GameState.worldSelect;
      _selectedLevel = null;
      _isFromModelMuseum = false;
    });
  }

  void _switchToLevelSelect(CampaignWorld world) {
    AudioService.playClick();
    setState(() {
      _selectedWorld = world;
      _gameState = GameState.levelSelect;
      _selectedLevel = null;
      _isFromModelMuseum = false;
    });
  }

  void _switchToModelMuseum() {
    AudioService.playClick();
    setState(() {
      _gameState = GameState.modelMuseum;
      _selectedLevel = null;
      _isFromModelMuseum = false;
    });
  }

  void _launchLevelFromMuseum(CampaignLevel level) {
    widget.vault.setActiveLevel(level.id);
    AudioService.playSuccess();
    setState(() {
      _selectedLevel = level;
      _selectedWorld = widget.vault.worlds.firstWhere(
        (w) => w.levels.any((l) => l.id == level.id),
        orElse: () => widget.vault.worlds.first,
      );
      _isFromModelMuseum = true;
      _gameState = GameState.spaceMission3D;
    });
  }

  void _launchLevel(CampaignLevel level) {
    widget.vault.setActiveLevel(level.id);
    AudioService.playSuccess();
    setState(() {
      _selectedLevel = level;
      _selectedWorld = widget.vault.worlds.firstWhere(
        (w) => w.levels.any((l) => l.id == level.id),
        orElse: () => widget.vault.worlds.first,
      );
      _isFromModelMuseum = false;
      _gameState = GameState.spaceMission3D;
    });
  }

  void _switchToSpaceMission() {
    AudioService.playSuccess();
    setState(() {
      _selectedLevel = null;
      _isFromModelMuseum = false;
      _gameState = GameState.spaceMission3D;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _gameState == GameState.mainMenu || _gameState == GameState.splash,
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
      case GameState.splash:
        return SplashScreen(
          key: const ValueKey('splash_screen'),
          onFinish: () {
            AudioService.startBgm();
            setState(() {
              _gameState = GameState.mainMenu;
              if (!widget.vault.hasCompletedOnboarding) {
                _showOnboarding = true;
              }
            });
          },
        );

      case GameState.mainMenu:
        return MainMenuScreen(
          key: const ValueKey('main_menu_screen'),
          vault: widget.vault,
          onOpenWorldSelect: _switchToWorldSelect,
          onOpenSpaceMissions: _switchToSpaceMission,
          onOpenModelMuseum: _switchToModelMuseum,
          onContinueLevel: (level) => _launchLevel(level),
          onOpenOnboarding: () => setState(() => _showOnboarding = true),
        );

      case GameState.modelMuseum:
        return ModelMuseumScreen(
          key: const ValueKey('model_museum_screen'),
          vault: widget.vault,
          onSelectModel: _launchLevelFromMuseum,
          onReturnToMenu: _switchToMainMenu,
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

      case GameState.spaceMission3D:
        return SpaceMissionView(
          key: const ValueKey('3d_space_mission_screen'),
          vault: widget.vault,
          campaignLevel: _selectedLevel,
          onReturnToArchive: () {
            if (_isFromModelMuseum) {
              _switchToModelMuseum();
            } else if (_selectedLevel != null && _selectedWorld != null) {
              _switchToLevelSelect(_selectedWorld!);
            } else {
              _switchToMainMenu();
            }
          },
          onReturnToMenu: _switchToMainMenu,
        );
    }
  }
}
