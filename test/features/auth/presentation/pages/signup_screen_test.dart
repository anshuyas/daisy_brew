import 'package:daisy_brew/features/auth/domain/usecases/register_usecase.dart';
import 'package:daisy_brew/features/auth/presentation/pages/signup_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock RegisterUsecase
class MockRegisterUsecase extends Mock implements RegisterUsecase {}

// Fake RegisterParams for mocktail
class FakeRegisterParams extends Fake implements RegisterParams {}

void main() {
  late MockRegisterUsecase mockRegisterUsecase;

  // Register fallback value for mocktail before using any()
  setUpAll(() {
    registerFallbackValue(FakeRegisterParams());
  });

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
  });

  // Helper to create test widget
  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
      ],
      child: const MaterialApp(home: RegisterScreen()),
    );
  }

  // -------------------------------
  // UI Elements
  // -------------------------------
  group('RegisterScreen - UI Elements', () {
    testWidgets('should display header, form fields, button, and login link', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });
  });

  // -------------------------------
  // Form Input
  // -------------------------------
  group('RegisterScreen - Form Input', () {
    testWidgets('should allow entering all fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(find.byType(TextFormField).at(3), 'password123');

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsNWidgets(2)); // Password & Confirm
    });
  });

  // -------------------------------
  // Form Validation
  // -------------------------------
  group('RegisterScreen - Form Validation', () {
    testWidgets('should show error when Full Name is empty', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final signUpButton = find.text('Sign Up');
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      expect(find.text('Full Name is required'), findsOneWidget);
    });

    testWidgets('should show error when Email is empty', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter Full Name only
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');

      final signUpButton = find.text('Sign Up');
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('should show error when Email is invalid', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter Full Name
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      // Enter invalid Email
      await tester.enterText(find.byType(TextFormField).at(1), 'invalidemail');

      final signUpButton = find.text('Sign Up');
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      expect(find.text('Invalid email'), findsOneWidget);
    });

    testWidgets('should show error when Password is less than 6 chars', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter Full Name and Email
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'test@example.com',
      );
      // Enter short Password
      await tester.enterText(find.byType(TextFormField).at(2), '123');

      final signUpButton = find.text('Sign Up');
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets('should show error when Confirm Password does not match', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter Full Name, Email, Password
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      // Enter mismatched Confirm Password
      await tester.enterText(find.byType(TextFormField).at(3), 'password321');

      final signUpButton = find.text('Sign Up');
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });

  // -------------------------------
  // Form Submission
  // -------------------------------
  group('RegisterScreen - Form Submission', () {
    testWidgets('should call register usecase when form is valid', (
      tester,
    ) async {
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) async => const Right(true));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'john@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'mypassword');
      await tester.enterText(find.byType(TextFormField).at(3), 'mypassword');

      final signUpButton = find.text('Sign Up');
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      verify(() => mockRegisterUsecase(any())).called(1);
    });

    testWidgets('should pass correct params to register usecase', (
      tester,
    ) async {
      RegisterParams? capturedParams;

      when(() => mockRegisterUsecase(any())).thenAnswer((invocation) async {
        capturedParams = invocation.positionalArguments[0] as RegisterParams;
        return const Right(true);
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Jane Doe');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'jane@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'mypassword');
      await tester.enterText(find.byType(TextFormField).at(3), 'mypassword');

      final signUpButton = find.text('Sign Up');
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      expect(capturedParams?.fullName, 'Jane Doe');
      expect(capturedParams?.email, 'jane@example.com');
      expect(capturedParams?.password, 'mypassword');
    });
  });
}
