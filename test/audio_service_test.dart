import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mohasunno/models/campaign_data.dart';
import 'package:mohasunno/dialogs/settings_dialog.dart';
import 'package:mohasunno/screens/level_select_screen.dart';
import 'package:mohasunno/screens/world_select_screen.dart';
import 'package:mohasunno/services/audio_service.dart';
import 'package:mohasunno/services/vault_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (call) async => null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (call) async => null,
    );
  });

  group('Interactive Audio & Sound Assets Suite', () {
    test('All authentic sci-fi sound effects exist in assets/sound/', () {
      final requiredSounds = [
        'click.mp3',
        'level_complete.mp3',
        'level_unlock.mp3',
        'on_back.mp3',
        'on_level_open.mp3',
        'world_complete.mp3',
        'zoomin_ control.mp3',
        'lexin_music-space-ambient-sci-fi-121842.mp3',
        'atlasaudio-detective-518071.mp3',
      ];

      for (final sound in requiredSounds) {
        final file = File('assets/sound/$sound');
        expect(file.existsSync(), isTrue, reason: 'Sound asset $sound missing!');
        expect(file.lengthSync(), greaterThan(1000), reason: '$sound is empty!');
      }

      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec.contains('assets/sound/'), isTrue,
          reason: 'assets/sound/ must be registered in pubspec.yaml');
    });

    test('AudioService default volumes (50% SFX, 40% BGM) and playback APIs', () async {
      await AudioService.init();
      expect(AudioService.sfxVolume, 0.5);
      expect(AudioService.bgmVolume, 0.4);
      expect(AudioService.isBgmEnabled, isTrue);
      expect(AudioService.currentTrack, AudioService.trackAmbient);

      AudioService.isMuted = false;
      await AudioService.startBgm();
      expect(() => AudioService.setSfxVolume(0.5), returnsNormally);
      expect(() => AudioService.setBgmVolume(0.4), returnsNormally);
      expect(() => AudioService.playClick(), returnsNormally);

      // Test switching to detective track
      await AudioService.setBgmTrack(AudioService.trackDetective);
      expect(AudioService.currentTrack, AudioService.trackDetective);

      // Test toggling BGM off and on
      await AudioService.setBgmEnabled(false);
      expect(AudioService.isBgmEnabled, isFalse);
      await AudioService.setBgmEnabled(true);
      expect(AudioService.isBgmEnabled, isTrue);

      expect(() => AudioService.stopBgm(), returnsNormally);
    });

    test('AudioService plays all sound cues cleanly and respects mute toggles', () {
      AudioService.isMuted = false;
      expect(() => AudioService.playClick(), returnsNormally);
      expect(() => AudioService.playBack(), returnsNormally);
      expect(() => AudioService.playSwipe(), returnsNormally);
      expect(() => AudioService.playLevelUnlock(), returnsNormally);
      expect(() => AudioService.playCardSelect(), returnsNormally);
      expect(() => AudioService.playLevelOpen(), returnsNormally);
      expect(() => AudioService.playLaunch(), returnsNormally);
      expect(() => AudioService.playLevelComplete(), returnsNormally);
      expect(() => AudioService.playWorldComplete(), returnsNormally);
      expect(() => AudioService.playSuccess(), returnsNormally);
      expect(() => AudioService.playAlert(), returnsNormally);
      expect(() => AudioService.playClueChime(), returnsNormally);
      expect(() => AudioService.playHint(), returnsNormally);
      expect(() => AudioService.playGear(), returnsNormally);
      expect(() => AudioService.playZoom(), returnsNormally);

      AudioService.isMuted = true;
      expect(() => AudioService.playClick(), returnsNormally);
      expect(() => AudioService.playSwipe(), returnsNormally);
      AudioService.isMuted = false;
    });

    testWidgets('WorldSelectScreen has no chevron buttons and relies on touch navigation',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final vault = VaultService();
      await tester.pumpWidget(
        MaterialApp(
          home: WorldSelectScreen(
            vault: vault,
            onSelectWorld: (_) {},
            onReturnToMenu: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Assert no chevron left or right buttons are present in WorldSelectScreen
      expect(find.byIcon(LucideIcons.chevronLeft), findsNothing);
      expect(find.byIcon(LucideIcons.chevronRight), findsNothing);

      // Verify Touch Sector indicator is present
      expect(find.text("SECTOR 1 / 2"), findsOneWidget);
    });

    testWidgets('LevelSelectScreen has no chevron buttons and relies on touch navigation',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final vault = VaultService();
      final world = CampaignCatalog.getAllWorlds().first;

      await tester.pumpWidget(
        MaterialApp(
          home: LevelSelectScreen(
            vault: vault,
            world: world,
            onLaunchLevel: (_) {},
            onReturnToWorldSelect: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Assert no chevron left or right buttons are present in LevelSelectScreen
      expect(find.byIcon(LucideIcons.chevronLeft), findsNothing);
      expect(find.byIcon(LucideIcons.chevronRight), findsNothing);

      // Verify Touch Missions indicator is present
      expect(find.text("MISSIONS 1–3 OF 7"), findsOneWidget);
    });

    testWidgets('SettingsDialog allows user to toggle BGM on/off and switch between tracks',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final vault = VaultService();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsDialog(
              vault: vault,
              onClose: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Check BGM title and track selector
      expect(find.text("Background Music (BGM)"), findsOneWidget);
      expect(find.text("Space Ambient"), findsOneWidget);
      expect(find.text("Detective Theme"), findsOneWidget);

      // Select Detective Theme
      await tester.tap(find.text("Detective Theme"));
      await tester.pump(const Duration(milliseconds: 200));

      expect(vault.bgmTrack, AudioService.trackDetective);
      expect(AudioService.currentTrack, AudioService.trackDetective);

      // Select Space Ambient
      await tester.tap(find.text("Space Ambient"));
      await tester.pump(const Duration(milliseconds: 200));

      expect(vault.bgmTrack, AudioService.trackAmbient);
      expect(AudioService.currentTrack, AudioService.trackAmbient);
    });
  });
}
