import 'package:daisy_brew/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:daisy_brew/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:daisy_brew/features/auth/presentation/state/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock view model
class MockAuthViewModel extends Mock implements AuthViewModel {}

class FakeAuthViewModel extends AuthViewModel {
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // simulate success
    state = const AuthState(status: AuthStatus.passwordResetEmailSent);
  }
}

void main() {
  late MockAuthViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockAuthViewModel();
  });

  Widget makeTestableWidget(Widget child) {
    return ProviderScope(
      overrides: [authViewModelProvider.overrideWith(() => mockViewModel)],
      child: MaterialApp(
        routes: {
          '/reset-password': (_) => const Scaffold(body: Text('Reset Screen')),
        },
        home: child,
      ),
    );
  }

  testWidgets('renders all widgets', (tester) async {
    await tester.pumpWidget(makeTestableWidget(const ForgotPasswordScreen()));

    expect(find.text('Forgot Password'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byIcon(Icons.lock_reset), findsOneWidget);
  });

  testWidgets('shows validation error when email is empty', (tester) async {
    await tester.pumpWidget(makeTestableWidget(const ForgotPasswordScreen()));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Email required'), findsOneWidget);
  });

  testWidgets('calls sendPasswordResetEmail and shows success', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authViewModelProvider.overrideWith(FakeAuthViewModel.new)],
        child: const MaterialApp(home: ForgotPasswordScreen()),
      ),
    );

    // Enter email
    await tester.enterText(find.byType(TextFormField), 'test@example.com');

    // Tap the button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Check that Snackbar is shown
    expect(find.text('Reset token sent to test@example.com'), findsOneWidget);
  });

  testWidgets('shows error snackbar on failure', (tester) async {
    when(() => mockViewModel.sendPasswordResetEmail(any())).thenAnswer((
      _,
    ) async {
      when(() => mockViewModel.state).thenReturn(
        const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Failed to send email',
        ),
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authViewModelProvider.overrideWith(() => mockViewModel)],
        child: const MaterialApp(home: ForgotPasswordScreen()),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'test@example.com');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
