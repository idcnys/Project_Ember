import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mohasunno/main.dart';
import 'package:mohasunno/services/vault_service.dart';
import 'package:mohasunno/space/space_mission_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Ember Pixel Chatbot Startup & Backstory Dialog Test',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final vaultService = VaultService();
    await tester.pumpWidget(EmberGameApp(vaultService: vaultService));
    await tester.pump(const Duration(milliseconds: 200));

    // 1. Verify Pixel Chatbot Onboarding modal appears on startup
    expect(find.text("UNIT ECHO"), findsOneWidget);
    expect(find.text("GREETINGS, INVESTIGATOR AOHINE."), findsOneWidget);

    // 2. Select a designation & authenticate
    expect(find.text("Commander"), findsOneWidget);
    await tester.tap(find.text("Commander"));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text("AUTHENTICATE IDENTITY"), findsOneWidget);
    await tester.tap(find.text("AUTHENTICATE IDENTITY"));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Investigator name saved in Vault
    expect(vaultService.playerName, "Commander Aohine");

    // 3. Sequential Backstory Transmission 1
    expect(find.text("TRANSMISSION 01 // 2027 LOCKDOWN"), findsOneWidget);
    expect(find.text("GLOBAL AI DATA SEIZURE"), findsOneWidget);

    // Continue to Transmission 2
    await tester.tap(find.text("CONTINUE"));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("TRANSMISSION 02 // HARD EVIDENCE"), findsOneWidget);

    // Continue to Transmission 3
    await tester.tap(find.text("CONTINUE"));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("TRANSMISSION 03 // PROJECT EMBER"), findsOneWidget);

    // Continue to Transmission 4
    await tester.tap(find.text("CONTINUE"));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("TRANSMISSION 04 // LAUNCH DIRECTIVE"), findsOneWidget);

    // 4. Click COMMENCE OPERATION to enter Ember Main Menu
    expect(find.text("COMMENCE OPERATION"), findsOneWidget);
    await tester.tap(find.text("COMMENCE OPERATION"));
    await tester.pump(const Duration(milliseconds: 400));

    // Verify Main Menu reached and onboarding complete
    expect(vaultService.hasCompletedOnboarding, isTrue);
    expect(find.text("Ember"), findsOneWidget);
    expect(find.text("Commander Aohine"), findsOneWidget);
  });

  testWidgets('Ember Campaign World and Level Select Smoke Test',
      (WidgetTester tester) async {
    // Landscape physical resolution
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final vaultService = VaultService();
    await tester.pumpWidget(EmberGameApp(vaultService: vaultService));
    await tester.pump(const Duration(milliseconds: 200));

    // Skip prologue if shown
    if (find.text("SKIP PROLOGUE").evaluate().isNotEmpty) {
      await tester.tap(find.text("SKIP PROLOGUE"));
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 1. Verify Main Menu branding & World Select button
    expect(find.text("Ember"), findsOneWidget);
    expect(find.text("Campaign: Select World"), findsOneWidget);

    // 2. Tap to enter WorldSelectScreen
    await tester.tap(find.text("Campaign: Select World"));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Paginated Worlds (Page 1 shows Moon & Mars)
    expect(find.text("WORLD 1: THE MOON"), findsOneWidget);
    expect(find.text("WORLD 2: MARS"), findsOneWidget);

    // 3. Tap WORLD 1: THE MOON to enter LevelSelectScreen
    await tester.tap(find.text("WORLD 1: THE MOON"));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify World 1 Moon levels appear on Page 1 (M1, M2, M3)
    expect(find.text("M1"), findsWidgets);
    expect(find.text("M2"), findsWidgets);
    expect(find.text("M3"), findsWidgets);
    expect(find.text("A Photograph Before Touchdown (Ranger 7)"), findsWidgets);

    // 4. Tap LAUNCH MISSION RECONSTRUCTION to launch level into 3D Spacecraft View
    await tester.tap(find.text("LAUNCH MISSION RECONSTRUCTION"));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify in 3D Spacecraft Inspector with level M1
    expect(find.text("A Photograph Before Touchdown (Ranger 7)"), findsWidgets);
    expect(find.text("Ranger 7"), findsWidgets);
  });

  testWidgets('Ember Main Menu Tools and Dialogs Test',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final vaultService = VaultService();
    await tester.pumpWidget(EmberGameApp(vaultService: vaultService));
    await tester.pump(const Duration(milliseconds: 200));

    if (find.text("SKIP PROLOGUE").evaluate().isNotEmpty) {
      await tester.tap(find.text("SKIP PROLOGUE"));
      await tester.pump(const Duration(milliseconds: 300));
    }

    // Open Evidence Vault dialog
    expect(find.text("Evidence Vault"), findsOneWidget);
    await tester.tap(find.text("Evidence Vault"));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("Evidence Vault • Physical Scientific Archives"), findsOneWidget);

    // Close Evidence Vault dialog
    await tester.tap(find.byIcon(LucideIcons.x).first);
    await tester.pump(const Duration(milliseconds: 300));

    // Open About Dialog
    expect(find.text("About & Lore"), findsOneWidget);
    await tester.tap(find.text("About & Lore"));
    await tester.pump(const Duration(milliseconds: 300));
    // Close About Dialog
    await tester.tap(find.byIcon(LucideIcons.x).first);
    await tester.pump(const Duration(milliseconds: 300));

    // Open Settings Dialog
    expect(find.text("Settings"), findsOneWidget);
    await tester.tap(find.text("Settings"));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("System Settings & Telemetry"), findsOneWidget);

    // Close Settings Dialog
    await tester.tap(find.byIcon(LucideIcons.x).first);
    await tester.pump(const Duration(milliseconds: 300));

    // Open NASA Timeline Dialog
    expect(find.text("NASA Timeline"), findsOneWidget);
    await tester.tap(find.text("NASA Timeline"));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("NASA Historical Hardware Directory (1960–Present)"), findsOneWidget);

    // Close NASA Timeline Dialog
    await tester.tap(find.byIcon(LucideIcons.x).first);
    await tester.pump(const Duration(milliseconds: 300));

    // Open Solar Map Dialog
    expect(find.text("Solar Map"), findsOneWidget);
    await tester.tap(find.text("Solar Map"));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("Solar System Orbital Chart • Mission Directory"), findsOneWidget);
  });

  test('VaultService Campaign Progress and Star Ratings Unit Test', () {
    final vault = VaultService();
    expect(vault.worlds.length, 4);
    expect(vault.totalLevelsCount, 24);

    // Level 1 should be unlocked by default
    final m1 = vault.getLevelById("m1");
    expect(m1, isNotNull);
    expect(m1!.isUnlocked, isTrue);

    // Complete Level 1 with 3 stars
    vault.completeCampaignLevel("m1", 3);
    expect(m1.isCompleted, isTrue);
    expect(m1.stars, 3);
    expect(vault.completedLevelsCount, 1);

    // Next level m2 should now be unlocked automatically
    final m2 = vault.getLevelById("m2");
    expect(m2, isNotNull);
    expect(m2!.isUnlocked, isTrue);
  });

  testWidgets('Mobile Landscape (720x360) Layout & Zero Overflow Test',
      (WidgetTester tester) async {
    // Exact compact mobile landscape resolution: 720 x 340 (covers ultra-compact phones)
    tester.view.physicalSize = const Size(720, 340);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final vaultService = VaultService();
    await tester.pumpWidget(EmberGameApp(vaultService: vaultService));
    await tester.pump(const Duration(milliseconds: 200));

    if (find.text("SKIP PROLOGUE").evaluate().isNotEmpty) {
      await tester.tap(find.text("SKIP PROLOGUE"));
      await tester.pump(const Duration(milliseconds: 300));
    }

    // 1. Verify Main Menu has zero overflows on small screen
    expect(find.text("Ember"), findsOneWidget);

    // Test Dialogs at small landscape size (720x340)
    await tester.ensureVisible(find.text("Evidence Vault", skipOffstage: false));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text("Evidence Vault"));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("Evidence Vault • Physical Scientific Archives"), findsOneWidget);
    await tester.tap(find.byIcon(LucideIcons.x).first);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.text("Settings", skipOffstage: false));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text("Settings"));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("System Settings & Telemetry"), findsOneWidget);
    await tester.tap(find.byIcon(LucideIcons.x).first);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.text("Solar Map", skipOffstage: false));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text("Solar Map"));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("Solar System Orbital Chart • Mission Directory"), findsOneWidget);
    await tester.tap(find.byIcon(LucideIcons.x).first);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.text("NASA Timeline", skipOffstage: false));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text("NASA Timeline"));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("NASA Historical Hardware Directory (1960–Present)"), findsOneWidget);
    await tester.tap(find.byIcon(LucideIcons.x).first);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.text("About & Lore", skipOffstage: false));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text("About & Lore"));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(LucideIcons.x), findsWidgets);
    await tester.tap(find.byIcon(LucideIcons.x).first);
    await tester.pump(const Duration(milliseconds: 300));

    // 2. Open Campaign: World Select -> Level Select at small screen
    await tester.ensureVisible(find.text("Campaign: Select World", skipOffstage: false));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text("Campaign: Select World"));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text("WORLD 1: THE MOON"), findsOneWidget);

    await tester.tap(find.text("WORLD 1: THE MOON"));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text("M1"), findsWidgets);

    // Launch mission M1
    await tester.ensureVisible(find.text("LAUNCH MISSION RECONSTRUCTION", skipOffstage: false));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text("LAUNCH MISSION RECONSTRUCTION"));
    await tester.pump(const Duration(milliseconds: 400));

    // 3. In Space Mission View: engage puzzle modal directly via dossier console
    expect(find.text("PUZZLE"), findsOneWidget);
    await tester.tap(find.text("PUZZLE"));
    await tester.pump(const Duration(milliseconds: 400));

    // Verify Puzzle modal opened with zero overflow
    expect(find.byIcon(LucideIcons.x), findsWidgets);
    await tester.tap(find.byIcon(LucideIcons.x).last);
    await tester.pump(const Duration(milliseconds: 400));

    // Return to main menu via home icon
    await tester.tap(find.byIcon(LucideIcons.home));
    await tester.pump(const Duration(milliseconds: 400));

    // 4. Continue Level directly from Main Home (remembers last played level)
    await tester.ensureVisible(find.textContaining("CONTINUE:", skipOffstage: false));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.textContaining("CONTINUE:"));
    await tester.pump(const Duration(milliseconds: 400));

    // Verify Space Mission View opened for the continued level with zero overflows
    expect(find.byType(SpaceMissionView), findsOneWidget);
    expect(find.text("M1"), findsWidgets);
  });
}
