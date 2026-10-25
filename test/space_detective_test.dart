import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mohasunno/models/campaign_data.dart';
import 'package:mohasunno/models/space_detective_data.dart';
import 'package:mohasunno/services/vault_service.dart';
import 'package:mohasunno/space/space_detective_dossier_panel.dart';
import 'package:mohasunno/space/space_mission_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Space Detective Campaign Catalog Tests', () {
    test('All 24 campaign cases exist with complete fields from PDF guide', () {
      expect(SpaceDetectiveCatalog.allCases.length, 24);

      final expectedCodes = [
        'M1', 'M2', 'M3', 'M4', 'M5', 'M6', 'M7',
        'R1', 'R2', 'R3', 'R4', 'R5', 'R6', 'R7',
        'D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7',
        '4.1', '4.2', '4.3'
      ];

      for (var code in expectedCodes) {
        final c = SpaceDetectiveCatalog.getCaseByCode(code);
        expect(c, isNotNull, reason: 'Case $code should exist');

        // Verify non-empty texts
        expect(c!.title.isNotEmpty, true, reason: '$code title should not be empty');
        expect(c.scenario.isNotEmpty, true, reason: '$code scenario should not be empty');
        expect(c.briefing.isNotEmpty, true, reason: '$code briefing should not be empty');

        // Verify Six-Field Memory System
        expect(c.missionScience.isNotEmpty, true, reason: '$code missionScience should not be empty');
        expect(c.outcomes.isNotEmpty, true, reason: '$code outcomes should not be empty');
        expect(c.whyEnded.isNotEmpty, true, reason: '$code whyEnded should not be empty');
        expect(c.contribution.isNotEmpty, true, reason: '$code contribution should not be empty');
        expect(c.deviceTechnology.isNotEmpty, true, reason: '$code deviceTechnology should not be empty');
        expect(c.missionChiefGuidelines.isNotEmpty, true, reason: '$code guidelines should not be empty');

        // Verify Clues
        expect(c.clue1.isNotEmpty, true, reason: '$code clue1 should not be empty');
        expect(c.clue2.isNotEmpty, true, reason: '$code clue2 should not be empty');
        expect(c.clue3.isNotEmpty, true, reason: '$code clue3 should not be empty');

        // Verify Solution, Challenge & Spaced Recall
        expect(c.caseSolution.isNotEmpty, true, reason: '$code caseSolution should not be empty');
        expect(c.playerChallenge.isNotEmpty, true, reason: '$code playerChallenge should not be empty');
        expect(c.memoryRecall.isNotEmpty, true, reason: '$code memoryRecall should not be empty');

        // Verify Checklist
        expect(c.observation.isNotEmpty, true);
        expect(c.interpretation.isNotEmpty, true);
        expect(c.alternativeRejected.isNotEmpty, true);
        expect(c.verificationTest.isNotEmpty, true);
        expect(c.confidenceLevel.isNotEmpty, true);

        // Verify Options
        expect(c.challengeOptions.length >= 3, true);
        final correctCount = c.challengeOptions.where((o) => o.isCorrect).length;
        expect(correctCount, 1, reason: '$code should have exactly 1 correct option');
      }
    });

    test('Case lookup functions correctly by code and levelId with case-insensitivity', () {
      expect(SpaceDetectiveCatalog.getCaseByCode('m1')?.title, contains('Touchdown'));
      expect(SpaceDetectiveCatalog.getCaseByCode('R4')?.title, contains('Water Clue'));
      expect(SpaceDetectiveCatalog.getCaseByCode('d1')?.title, contains('Last Packet'));
      expect(SpaceDetectiveCatalog.getCaseByCode('4.1')?.title, contains('Three-World Black Box'));
      expect(SpaceDetectiveCatalog.getCaseByCode('C1')?.title, contains('Three-World Black Box'));

      expect(SpaceDetectiveCatalog.getCaseByLevelId('m1')?.code, 'M1');
      expect(SpaceDetectiveCatalog.getCaseByLevelId('r7')?.code, 'R7');
      expect(SpaceDetectiveCatalog.getCaseByLevelId('c3')?.code, '4.3');
    });
  });

  group('Space Detective Dossier Panel Widget Tests', () {
    testWidgets('Renders case briefing, memory card fields, clue unlocks, and verdict debrief', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vault = VaultService();
      final caseM1 = SpaceDetectiveCatalog.getCaseByCode('M1')!;

      int solvedScore = 0;
      int solvedStars = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 440,
              height: 750,
              child: SpaceDetectiveDossierPanel(
                caseData: caseM1,
                vault: vault,
                onVerdictSolved: (score, stars) {
                  solvedScore = score;
                  solvedStars = stars;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Initial State: Tab 0 (Briefing)
      expect(find.text('M1'), findsOneWidget);
      expect(find.text(caseM1.title), findsOneWidget);
      expect(find.textContaining('Ranger 7'), findsWidgets);
      expect(find.text(caseM1.briefing), findsOneWidget);

      // 2. Switch to Tab 1 (Memory Card)
      await tester.tap(find.text('2. MEMORY'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('THE SIX-FIELD MISSION MEMORY SYSTEM'), findsOneWidget);
      expect(find.text('1. MISSION SCIENCE'), findsOneWidget);
      expect(find.text('2. OUTCOMES'), findsOneWidget);
      expect(find.text('3. WHY ENDED / ABANDONED'), findsOneWidget);
      expect(find.text('4. CONTRIBUTION'), findsOneWidget);
      expect(find.text('5. DEVICE TECHNOLOGY'), findsOneWidget);
      expect(find.text('6. CHIEF GUIDELINES'), findsOneWidget);

      // Verify exact text appears
      expect(find.text(caseM1.missionScience), findsOneWidget);

      // Test Memory Recall Mode Toggle
      await tester.tap(find.text('RECALL TEST'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('RECALL ON'), findsOneWidget);

      // Toggle back
      await tester.tap(find.text('RECALL ON'));
      await tester.pump(const Duration(milliseconds: 300));

      // 3. Switch to Tab 2 (Evidence Lock)
      await tester.tap(find.textContaining('3. CLUES'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('EVIDENCE LOCK • REVEAL IN SEQUENCE'), findsOneWidget);
      expect(find.text('CLUE 01 // INITIAL OBSERVATION'), findsOneWidget);
      expect(find.text(caseM1.clue1), findsOneWidget);

      // Unlock Clue 2
      expect(find.textContaining('REVEAL CLUE 2'), findsOneWidget);
      await tester.tap(find.textContaining('REVEAL CLUE 2'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(caseM1.clue2), findsOneWidget);

      // Unlock Clue 3
      expect(find.textContaining('REVEAL CLUE 3'), findsOneWidget);
      await tester.tap(find.textContaining('REVEAL CLUE 3'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(caseM1.clue3), findsOneWidget);
      expect(find.textContaining('ALL EVIDENCE CHANNELS REVEALED'), findsOneWidget);

      // 4. Switch to Tab 3 (Verdict & Debrief)
      await tester.tap(find.textContaining('4. VERDICT'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(caseM1.playerChallenge), findsOneWidget);
      expect(find.text('SCIENTIFIC THINKING CHECKLIST'), findsOneWidget);

      // Tap correct hypothesis for M1 (perspective illusion)
      final correctOpt = caseM1.challengeOptions.firstWhere((o) => o.isCorrect);
      await tester.ensureVisible(find.text(correctOpt.text));
      await tester.tap(find.text(correctOpt.text));
      await tester.pump(const Duration(milliseconds: 300));

      // Select Confidence: CONFIRMED
      await tester.ensureVisible(find.text('CONFIRMED'));
      await tester.tap(find.text('CONFIRMED'));
      await tester.pump(const Duration(milliseconds: 300));

      // Submit Verdict
      await tester.ensureVisible(find.text('SUBMIT MISSION VERDICT & DEBRIEF'));
      await tester.tap(find.text('SUBMIT MISSION VERDICT & DEBRIEF'));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Debrief shows Detective Rank, Case Solution, and Spaced Recall
      expect(find.textContaining('DETECTIVE RANK: MISSION DETECTIVE'), findsOneWidget);
      expect(solvedScore, 10);
      expect(solvedStars, 3);
      expect(find.text(caseM1.caseSolution), findsOneWidget);
      expect(find.text(caseM1.memoryRecall), findsOneWidget);
    });
  });

  group('SpaceMissionView Storytelling Beside Viewer Tests', () {
    testWidgets('SpaceMissionView displays 3D/photo viewer and Story Dossier panel side-by-side', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vault = VaultService();
      final campaignLevel = CampaignCatalog.getAllWorlds().first.levels.first; // M1

      await tester.pumpWidget(
        MaterialApp(
          home: SpaceMissionView(
            vault: vault,
            campaignLevel: campaignLevel,
            onReturnToArchive: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      // Verify both Viewer and Story Dossier are rendered simultaneously beside each other
      expect(find.byType(SpaceDetectiveDossierPanel), findsOneWidget);
      expect(find.text('M1'), findsWidgets);
      expect(find.textContaining('A Photograph Before Touchdown'), findsWidgets);

      // Test collapsing dossier panel
      await tester.tap(find.byTooltip('Collapse Dossier Beside Viewer'));
      await tester.pump(const Duration(milliseconds: 400));

      // Dossier is collapsed, floating toggle badge is visible
      expect(find.byType(SpaceDetectiveDossierPanel), findsNothing);
      expect(find.text('STORY DOSSIER [M1]'), findsOneWidget);

      // Tapping badge re-expands dossier beside the viewer
      await tester.tap(find.text('STORY DOSSIER [M1]'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(SpaceDetectiveDossierPanel), findsOneWidget);
    });

    testWidgets('Subsystem investigation obeys Story Dossier Debrief and cannot bypass level', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vault = VaultService();
      final campaignLevel = CampaignCatalog.getAllWorlds().first.levels.first; // M1

      await tester.pumpWidget(
        MaterialApp(
          home: SpaceMissionView(
            vault: vault,
            campaignLevel: campaignLevel,
            onReturnToArchive: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      // 1. Initial State: Bottom-right button is INVESTIGATE SUBSYSTEM
      expect(find.text('INVESTIGATE SUBSYSTEM'), findsOneWidget);
      expect(vault.getLevelById('m1')!.isCompleted, isFalse);

      // 2. Open Subsystem Diagnostic via bottom-right button
      await tester.tap(find.text('INVESTIGATE SUBSYSTEM'));
      await tester.pump(const Duration(milliseconds: 400));

      // Modal is open
      expect(find.byIcon(LucideIcons.x), findsWidgets);

      // Close modal (simulate exit or completion)
      await tester.tap(find.byIcon(LucideIcons.x).last);
      await tester.pump(const Duration(milliseconds: 400));

      // Level must NOT be bypassed or completed without the Story Dossier Debrief!
      expect(vault.getLevelById('m1')!.isCompleted, isFalse);

      // In Tab 2 (Clues), unlock Clue 2 to connect clues for full 10-point rubric
      await tester.tap(find.textContaining('3. CLUES'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.textContaining('REVEAL CLUE 2'));
      await tester.pump(const Duration(milliseconds: 300));

      // 3. Switch to Debrief Tab in Story Dossier and Submit Case Verdict
      await tester.tap(find.textContaining('4. VERDICT'));
      await tester.pump(const Duration(milliseconds: 400));

      // Select hypothesis and submit
      final caseM1 = SpaceDetectiveCatalog.getCaseByCode('M1')!;
      final correctOpt = caseM1.challengeOptions.firstWhere((o) => o.isCorrect);
      await tester.ensureVisible(find.text(correctOpt.text));
      await tester.tap(find.text(correctOpt.text));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.ensureVisible(find.text('CONFIRMED'));
      await tester.tap(find.text('CONFIRMED'));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.ensureVisible(find.text('SUBMIT MISSION VERDICT & DEBRIEF'));
      await tester.tap(find.text('SUBMIT MISSION VERDICT & DEBRIEF'));
      await tester.pump(const Duration(milliseconds: 400));

      // 4. Verify Case Solved & Level Completed in Vault
      expect(vault.getLevelById('m1')!.isCompleted, isTrue);
      expect(find.textContaining('SPACE DETECTIVE CASE SOLVED'), findsOneWidget);
      expect(find.text('RANK: MISSION DETECTIVE'), findsOneWidget);

      // 5. Test Review Dossier Button
      await tester.tap(find.text('REVIEW DOSSIER'));
      await tester.pump(const Duration(milliseconds: 400));

      // Victory modal dismissed, Dossier open with completed debrief
      expect(find.textContaining('SPACE DETECTIVE CASE SOLVED'), findsNothing);
      expect(find.byType(SpaceDetectiveDossierPanel), findsOneWidget);
      expect(find.textContaining('CASE RESOLVED'), findsOneWidget);
    });
  });
}
