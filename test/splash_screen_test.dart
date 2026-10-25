import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mohasunno/main.dart';
import 'package:mohasunno/screens/splash_screen.dart';
import 'package:mohasunno/services/vault_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Native & Flutter Splash Screen with Loaders Tests', () {
    testWidgets('SplashScreen renders app logo, title, and NASA Challenge badge',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool finished = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            duration: const Duration(seconds: 2),
            onFinish: () => finished = true,
          ),
        ),
      );

      // Initial frame check
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text("EMBER"), findsOneWidget);
      expect(find.text("THE SPACE SCIENCE INVESTIGATION"), findsOneWidget);
      expect(find.text("NASA SPACE APPS CHALLENGE 2026"), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);

      // Verify telemetry loader is present
      expect(find.textContaining("INITIALIZING"), findsWidgets);

      // Let animation progress
      await tester.pump(const Duration(milliseconds: 1000));
      expect(finished, isFalse);

      // Complete the splash duration
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(milliseconds: 100));
      expect(finished, isTrue);
    });

    testWidgets('SplashScreen tap-to-skip immediately triggers onFinish',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool finished = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            duration: const Duration(seconds: 5),
            onFinish: () => finished = true,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(finished, isFalse);

      // Tap on the screen to skip
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump(const Duration(milliseconds: 100));

      expect(finished, isTrue);
    });

    testWidgets('EmberGameApp launches into SplashScreen by default',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final vaultService = VaultService();
      // Default showSplash = true
      await tester.pumpWidget(EmberGameApp(vaultService: vaultService));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify SplashScreen is displayed on app boot
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text("EMBER"), findsOneWidget);
      expect(find.text("NASA SPACE APPS CHALLENGE 2026"), findsOneWidget);

      // Skip splash
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 400));

      // After splash completion, Onboarding or Main Menu is displayed
      expect(find.byType(SplashScreen), findsNothing);
    });
  });
}
