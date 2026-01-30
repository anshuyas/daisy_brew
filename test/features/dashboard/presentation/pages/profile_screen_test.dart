import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daisy_brew/features/dashboard/presentation/pages/profile_screen.dart';

void main() {
  group('ProfileScreen Widget Tests', () {
    testWidgets('should display user full name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(token: 'fake_token', fullName: 'Test User'),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('should find Change Profile Picture button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(token: 'fake_token', fullName: 'Test User'),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Change Profile Picture'), findsOneWidget);
    });

    testWidgets('should find Sign Out button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(token: 'fake_token', fullName: 'Test User'),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('should find all menu cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(token: 'fake_token', fullName: 'Test User'),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Shipping Address'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
    });
  });
}
