import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mohasunno/models/campaign_data.dart';
import 'package:mohasunno/services/vault_service.dart';
import 'package:mohasunno/space/space_mission_view.dart';
import 'package:mohasunno/screens/world_select_screen.dart';
import 'package:mohasunno/screens/level_select_screen.dart';
import 'package:mohasunno/theme/notion_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NASA 3D GLB Models & Level Model Viewer Tests', () {
    test('All 24 campaign levels resolve to valid GLB files in assets/models/', () {
      final worlds = CampaignCatalog.getAllWorlds();
      int totalLevels = 0;

      for (final world in worlds) {
        for (final level in world.levels) {
          totalLevels++;
          final glbPath = level.glbModelPath;
          expect(glbPath.endsWith('.glb'), isTrue,
              reason: 'Level ${level.code} model path must end with .glb: $glbPath');

          final file = File(glbPath);
          expect(file.existsSync(), isTrue,
              reason: 'Level ${level.code} (${level.spacecraft}) GLB file must exist at $glbPath');
          expect(file.lengthSync(), greaterThan(1000),
              reason: 'Level ${level.code} GLB file must not be empty');
        }
      }

      expect(totalLevels, 24);
    });

    test('All 11 primary NASA models from context/rawsrc/ exist and are verified', () {
      final expectedModels = [
        'assets/models/apollo_lunar_module.glb',
        'assets/models/opportunity.glb',
        'assets/models/viking_lander.glb',
        'assets/models/ingenuity.glb',
        'assets/models/insight.glb',
        'assets/models/pioneer10.glb',
        'assets/models/dawn.glb',
        'assets/models/kepler.glb',
        'assets/models/spitzer.glb',
        'assets/models/space_shuttle.glb',
        'assets/models/ladee.glb',
      ];

      for (final path in expectedModels) {
        final f = File(path);
        expect(f.existsSync(), isTrue, reason: 'Expected NASA 3D model missing: $path');
        expect(f.lengthSync(), greaterThan(1000), reason: 'Model file is too small: $path');
      }
    });

    test('Newly integrated mission-specific 3D models exist and are wired', () {
      final newModels = [
        'assets/models/lcross.glb',
        'assets/models/lunar_prospector.glb',
        'assets/models/phoenix_lander.glb',
        'assets/models/near_shoemaker.glb',
        'assets/models/deep_impact.glb',
        'assets/models/voyager.glb',
      ];

      for (final path in newModels) {
        final f = File(path);
        expect(f.existsSync(), isTrue, reason: 'Mission 3D model missing: $path');
        expect(f.lengthSync(), greaterThan(1000), reason: 'Model file is too small: $path');
      }

      // Verify levels map to their new exact models
      final worlds = CampaignCatalog.getAllWorlds();
      final m6 = worlds[0].levels.firstWhere((l) => l.id == 'm6');
      final r5 = worlds[1].levels.firstWhere((l) => l.id == 'r5');
      final d5 = worlds[2].levels.firstWhere((l) => l.id == 'd5');
      final d6 = worlds[2].levels.firstWhere((l) => l.id == 'd6');
      final d7 = worlds[2].levels.firstWhere((l) => l.id == 'd7');

      expect(m6.glbModelPath, 'assets/models/lcross.glb');
      expect(r5.glbModelPath, 'assets/models/phoenix_lander.glb');
      expect(d5.glbModelPath, 'assets/models/near_shoemaker.glb');
      expect(d6.glbModelPath, 'assets/models/deep_impact.glb');
      expect(d7.glbModelPath, 'assets/models/voyager.glb');
    });

    test('All 5 archival hardware images exist for missions without 3D models', () {
      final hardwareImages = [
        'assets/images/hardware/m1_ranger7.webp',
        'assets/images/hardware/m2_surveyor1.webp',
        'assets/images/hardware/m4_lunar_roving_vehicle.webp',
        'assets/images/hardware/m5_apollo_alsep.webp',
        'assets/images/hardware/r2_pathfinder_sojourner.webp',
      ];

      for (final path in hardwareImages) {
        final f = File(path);
        expect(f.existsSync(), isTrue, reason: 'Archival hardware image missing: $path');
        expect(f.lengthSync(), greaterThan(1000), reason: 'Image file too small: $path');
      }

      final worlds = CampaignCatalog.getAllWorlds();
      final m1 = worlds[0].levels.firstWhere((l) => l.id == 'm1');
      final m2 = worlds[0].levels.firstWhere((l) => l.id == 'm2');
      final m4 = worlds[0].levels.firstWhere((l) => l.id == 'm4');
      final m5 = worlds[0].levels.firstWhere((l) => l.id == 'm5');
      final r2 = worlds[1].levels.firstWhere((l) => l.id == 'r2');

      expect(m1.hardwareImagePath, isNotNull);
      expect(m2.hardwareImagePath, isNotNull);
      expect(m4.hardwareImagePath, isNotNull);
      expect(m5.hardwareImagePath, isNotNull);
      expect(r2.hardwareImagePath, isNotNull);
    });

    testWidgets('SpaceMissionView renders Archival Photographic HUD for Level M1',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final vault = VaultService();
      final level = CampaignCatalog.getAllWorlds().first.levels.first; // M1

      bool returnedToArchive = false;
      bool returnedToMenu = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark().copyWith(
            textTheme: ThemeData.dark().textTheme.apply(
                  fontFamily: NotionTheme.fontFamily,
                ),
          ),
          home: SpaceMissionView(
            vault: vault,
            campaignLevel: level,
            onReturnToArchive: () => returnedToArchive = true,
            onReturnToMenu: () => returnedToMenu = true,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Verify Level HUD elements
      expect(find.textContaining("RANGER 7"), findsWidgets);
      expect(find.textContaining("A PHOTOGRAPH BEFORE TOUCHDOWN"), findsWidgets);
      expect(find.text("NASA ARCHIVAL PHOTO"), findsOneWidget);
      expect(find.text("RESET ZOOM"), findsOneWidget);

      // 2. Verify Primary Action: Investigate Subsystem
      expect(find.text("INVESTIGATE SUBSYSTEM"), findsOneWidget);

      // 3. Test Return to Archive button
      await tester.tap(find.byIcon(LucideIcons.arrowLeft).first);
      await tester.pump(const Duration(milliseconds: 200));
      expect(returnedToArchive, isTrue);

      // 4. Test Return to Menu button
      await tester.tap(find.byIcon(LucideIcons.home));
      await tester.pump(const Duration(milliseconds: 200));
      expect(returnedToMenu, isTrue);
    });

    testWidgets('SpaceMissionView renders 3D Model Viewer HUD for Level M3 (Apollo LM)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final vault = VaultService();
      final level = CampaignCatalog.getAllWorlds().first.levels[2]; // M3: Apollo 11

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark().copyWith(
            textTheme: ThemeData.dark().textTheme.apply(
                  fontFamily: NotionTheme.fontFamily,
                ),
          ),
          home: SpaceMissionView(
            vault: vault,
            campaignLevel: level,
            onReturnToArchive: () {},
            onReturnToMenu: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text("GLB/glTF 3D"), findsOneWidget);
      expect(find.text("ROTATING"), findsOneWidget);

      await tester.tap(find.text("ROTATING"));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text("PAUSED"), findsOneWidget);
    });

    testWidgets('SpaceMissionView opens puzzle and displays victory flow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final vault = VaultService();
      final level = CampaignCatalog.getAllWorlds().first.levels.first; // M1

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: SpaceMissionView(
            vault: vault,
            campaignLevel: level,
            onReturnToArchive: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Investigate Subsystem button
      await tester.tap(find.text("INVESTIGATE SUBSYSTEM"));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Puzzle modal is presented
      expect(find.textContaining("Puzzle"), findsOneWidget);
    });

    testWidgets('WorldSelectScreen supports touch swipe to swap sectors',
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
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text("WORLD 1: THE MOON"), findsOneWidget);
      expect(find.text("WORLD 2: MARS"), findsOneWidget);

      // Fling left to swap sectors by touch
      await tester.fling(find.byType(PageView), const Offset(-600, 0), 1000);
      await tester.pumpAndSettle();

      // Verify Sector 2 is now shown (World 3 & 4)
      expect(find.text("WORLD 3: DEEP SPACE"), findsOneWidget);
      expect(find.text("WORLD 4: THE CONVERGENCE"), findsOneWidget);
    });

    testWidgets('LevelSelectScreen supports touch swap and whole right panel scrolling',
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
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Page 1 missions (M1, M2, M3)
      expect(find.text("M1"), findsWidgets);
      expect(find.text("M2"), findsWidgets);
      expect(find.text("M3"), findsWidgets);

      // Touch fling left across level cards to page 2 (M4, M5, M6)
      await tester.fling(find.byType(PageView), const Offset(-600, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text("M4"), findsWidgets);
      expect(find.text("M5"), findsWidgets);
      expect(find.text("M6"), findsWidgets);

      // Verify right side whole panel has SingleChildScrollView and scrolls
      final rightPanelFinder = find.byType(SingleChildScrollView);
      expect(rightPanelFinder, findsOneWidget);

      // Drag vertically on the top of the right panel
      await tester.drag(find.textContaining("MISSION LAB"), const Offset(0, -200));
      await tester.pumpAndSettle();

      // Launch button is visible (Level M4 is locked initially)
      expect(find.text("LEVEL LOCKED"), findsOneWidget);
    });
  });
}
