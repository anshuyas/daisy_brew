import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daisy_brew/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Mock SharedPreferences before each test
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'testuser@example.com-fullName': 'Test User',
      'testuser@example.com-email': 'testuser@example.com',
      'testuser@example.com-profile_picture': '',
    });
  });

  group('ProfileScreen Widget Tests', () {
    testWidgets('should display user full name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(
            token: 'fake_token',
            fullName: 'Test User',
            email: 'testuser@example.com',
            onProfileUpdated: (String newURL, {String? updatedName}) {},
          ),
        ),
      );

      // Wait for initState and SharedPreferences loading
      await tester.pumpAndSettle();

      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('should find Change Profile Picture button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(
            token: 'fake_token',
            fullName: 'Test User',
            email: 'testuser@example.com',
            onProfileUpdated: (String newURL, {String? updatedName}) {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Change Profile Picture'), findsOneWidget);
    });

    testWidgets('should find Sign Out button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(
            token: 'fake_token',
            fullName: 'Test User',
            email: 'testuser@example.com',
            onProfileUpdated: (String newURL, {String? updatedName}) {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('should find all menu cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(
            token: 'fake_token',
            fullName: 'Test User',
            email: 'testuser@example.com',
            onProfileUpdated: (String newURL, {String? updatedName}) {},
          ),
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
