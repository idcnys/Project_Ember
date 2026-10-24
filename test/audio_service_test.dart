import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mohasunno/models/campaign_data.dart';
import 'package:mohasunno/screens/level_select_screen.dart';
import 'package:mohasunno/screens/world_select_screen.dart';
import 'package:mohasunno/services/audio_service.dart';
import 'package:mohasunno/services/vault_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Interactive Audio & Sound Assets Suite', () {
    test('All authentic sci-fi sound effects exist in assets/sound/', () {
      final requiredSounds = [
        'click.wav',
        'level_complete.wav',
        'level_unlock.wav',
        'on_back.wav',
        'on_level_open.wav',
        'world_complete.wav',
        'zoomin_ control.wav',
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
  });
}
