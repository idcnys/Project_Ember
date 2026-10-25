import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mohasunno/models/campaign_data.dart';
import 'package:mohasunno/models/space_detective_data.dart';
import 'package:mohasunno/screens/main_menu_screen.dart';
import 'package:mohasunno/screens/model_museum_screen.dart';
import 'package:mohasunno/services/vault_service.dart';
import 'package:mohasunno/space/space_detective_dossier_panel.dart';

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

  group('Model Museum & Whole Content Scrollable Story Dossier Tests', () {
    testWidgets('MainMenuScreen features Model Museum action card', (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vault = VaultService();
      bool openedMuseum = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MainMenuScreen(
              vault: vault,
              onOpenWorldSelect: () {},
              onOpenSpaceMissions: () {},
              onOpenModelMuseum: () {
                openedMuseum = true;
              },
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Assert Model Museum button is present on Home Screen
      expect(find.text("Model Museum"), findsOneWidget);
      expect(find.textContaining("Interactive 3D gallery"), findsOneWidget);

      // Tap Model Museum
      await tester.tap(find.text("Model Museum"));
      await tester.pump(const Duration(milliseconds: 200));
      expect(openedMuseum, isTrue);
    });

    testWidgets('ModelMuseumScreen displays vertical cards gallery of all available models', (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vault = VaultService();
      CampaignLevel? selectedModel;
      bool returnedToMenu = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ModelMuseumScreen(
            vault: vault,
            onSelectModel: (lvl) {
              selectedModel = lvl;
            },
            onReturnToMenu: () {
              returnedToMenu = true;
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Header assertions
      expect(find.text("MODEL MUSEUM"), findsOneWidget);
      expect(find.text("19 3D GLB MODELS READY"), findsOneWidget);

      // Filter chips assertions
      expect(find.text("3D GLB MODELS (19)"), findsOneWidget);
      expect(find.text("ALL HARDWARE (24)"), findsOneWidget);
      expect(find.text("THE MOON (7)"), findsOneWidget);
      expect(find.text("MARS (7)"), findsOneWidget);
      expect(find.text("DEEP SPACE (7)"), findsOneWidget);
      expect(find.text("OBSERVATORIES (3)"), findsOneWidget);

      // Model cards assertions (Verify key NASA 3D models exist in the vertical cards gallery)
      expect(find.text("Apollo 11 Lunar Module"), findsOneWidget);
      expect(find.text("Viking Lander 1 & 2"), findsOneWidget);

      // Search functionality test
      await tester.enterText(find.byType(TextField), "Voyager");
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text("Voyager & Pioneer Plaque"), findsOneWidget);
      expect(find.text("Apollo 11 Lunar Module"), findsNothing);

      // Tap on the Voyager card to open it in viewer with all its details
      await tester.tap(find.text("Voyager & Pioneer Plaque"));
      await tester.pump(const Duration(milliseconds: 200));

      expect(selectedModel, isNotNull);
      expect(selectedModel!.spacecraft, "Voyager & Pioneer Plaque");
      expect(selectedModel!.code, "D7");

      // Test Return to Menu button
      await tester.tap(find.text("MAIN MENU"));
      await tester.pump(const Duration(milliseconds: 200));
      expect(returnedToMenu, isTrue);
    });

    testWidgets('Story Dossier keeps tab view with title and tab options inside scrollable popup', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vault = VaultService();
      final caseM1 = SpaceDetectiveCatalog.getCaseByCode('M1')!;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 440,
              height: 750,
              child: SpaceDetectiveDossierPanel(
                caseData: caseM1,
                vault: vault,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Assert outer SingleChildScrollView exists to make title, tab options and content scrollable
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Verify Title, Scenario and Tab options are present in the scrollable view
      expect(find.text(caseM1.title), findsOneWidget);
      expect(find.text("1. BRIEFING"), findsOneWidget);
      expect(find.text("2. MEMORY"), findsOneWidget);
      expect(find.textContaining("3. CLUES"), findsOneWidget);
      expect(find.textContaining("4. VERDICT"), findsOneWidget);

      // Tab view is preserved (Tab 0: Briefing active by default)
      expect(find.text(caseM1.briefing), findsOneWidget);
      expect(find.text("THE SIX-FIELD MISSION MEMORY SYSTEM"), findsNothing);

      // Switch to Tab 1 (Memory)
      await tester.tap(find.text("2. MEMORY"));
      await tester.pump(const Duration(milliseconds: 300));

      // Now Memory card content is shown in focused tab view
      expect(find.text("THE SIX-FIELD MISSION MEMORY SYSTEM"), findsOneWidget);
      expect(find.text(caseM1.briefing), findsNothing);
    });
  });
}
