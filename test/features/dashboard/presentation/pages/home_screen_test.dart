import 'package:daisy_brew/features/dashboard/presentation/widgets/header_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:daisy_brew/features/dashboard/presentation/pages/home_screen.dart';
import 'package:daisy_brew/features/dashboard/presentation/pages/profile_screen.dart';

void main() {
  testWidgets('HomeScreen UI renders and navigation works', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(token: 'dummy_token', fullName: 'Harry Styles'),
      ),
    );

    // Check HeaderWidget exists
    expect(find.byType(HeaderWidget), findsOneWidget);

    // Check category chips exist
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('Matcha'), findsOneWidget);
    expect(find.text('Smoothies'), findsOneWidget);
    expect(find.text('Bubble Tea'), findsOneWidget);

    // Check product cards exist (Cappuccino)
    expect(find.text('Cappuccino'), findsOneWidget);
    expect(find.text('Rs. 250'), findsOneWidget);

    // Check bottom navigation bar exists
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Tap Profile icon and verify navigation
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}
