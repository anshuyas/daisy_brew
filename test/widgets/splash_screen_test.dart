import 'package:daisy_brew/features/splash/presentation/pages/splash_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:daisy_brew/features/onboarding/presentation/pages/onboarding1_screen.dart';

void main() {
  testWidgets('SplashScreen renders correctly and navigates on button tap', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    // Check CircleAvatar exists
    expect(find.byType(CircleAvatar), findsOneWidget);

    // Check tagline text
    expect(find.text('Crafting comfort in every cup.'), findsOneWidget);

    // Check Start Brewing button
    final buttonFinder = find.text('Start Brewing');
    expect(buttonFinder, findsOneWidget);

    // Tap the button and check navigation
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen1), findsOneWidget);
  });
}
