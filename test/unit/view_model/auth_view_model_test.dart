import 'package:daisy_brew/features/auth/domain/entities/auth_entity.dart';
import 'package:daisy_brew/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:daisy_brew/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:daisy_brew/features/auth/domain/usecases/login_usecase.dart';
import 'package:daisy_brew/features/auth/domain/usecases/logout_usecase.dart';
import 'package:daisy_brew/features/auth/domain/usecases/register_usecase.dart';
import 'package:daisy_brew/features/auth/presentation/state/auth_state.dart';
import 'package:daisy_brew/features/auth/presentation/view_model/auth_view_model.dart'
    hide forgotPasswordUsecaseProvider;
import 'package:daisy_brew/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class MockForgotPasswordUsecase extends Mock implements ForgotPasswordUsecase {}

class MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}

class FakeForgotPasswordParams extends Fake implements ForgotPasswordParams {}

class FakeResetPasswordParams extends Fake implements ResetPasswordParams {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockForgotPasswordUsecase mockForgotPasswordUsecase;
  late MockResetPasswordUsecase mockResetPasswordUsecase;
  late ProviderContainer container;

  final tUser = AuthEntity(
    authId: '1',
    fullName: 'Test User',
    email: 'test@gmail.com',
    token: 'token_123',
    role: 'user',
  );

  setUpAll(() {
    registerFallbackValue(FakeForgotPasswordParams());
    registerFallbackValue(FakeResetPasswordParams());
    registerFallbackValue(
      RegisterParams(
        fullName: 'fallback',
        email: 'fallback@gmail.com',
        password: 'fallback',
        confirmPassword: 'fallback',
      ),
    );
    registerFallbackValue(
      LoginParams(email: 'fallback@gmail.com', password: 'fallback'),
    );
  });

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockForgotPasswordUsecase = MockForgotPasswordUsecase();
    container = ProviderContainer(
      overrides: [
        forgotPasswordUsecaseProvider.overrideWithValue(
          mockForgotPasswordUsecase,
        ),
      ],
    );
    mockResetPasswordUsecase = MockResetPasswordUsecase();

    container = ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
        forgotPasswordUsecaseProvider.overrideWithValue(
          mockForgotPasswordUsecase,
        ),
        resetPasswordUsecaseProvider.overrideWithValue(
          mockResetPasswordUsecase,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthViewModel', () {
    test('initial state', () {
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.initial);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
    });

    group('Register', () {
      test('success', () async {
        when(
          () => mockRegisterUsecase(any()),
        ).thenAnswer((_) async => const Right(true));
        final viewModel = container.read(authViewModelProvider.notifier);
        await viewModel.register(
          fullName: 'Test',
          email: 'a@a.com',
          password: '123',
          confirmPassword: '123',
        );
        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.registered);
      });

      test('failure', () async {
        const failure = ApiFailure(message: 'Registration failed');
        when(
          () => mockRegisterUsecase(any()),
        ).thenAnswer((_) async => const Left(failure));
        final viewModel = container.read(authViewModelProvider.notifier);
        await viewModel.register(
          fullName: 'Test',
          email: 'a@a.com',
          password: '123',
          confirmPassword: '123',
        );
        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Registration failed');
      });
    });

    group('Login', () {
      test('success', () async {
        when(
          () => mockLoginUsecase(any()),
        ).thenAnswer((_) async => Right(tUser));
        final viewModel = container.read(authViewModelProvider.notifier);
        await viewModel.login(email: 'test@gmail.com', password: '123');
        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.user, tUser);
      });

      test('failure', () async {
        const failure = ApiFailure(message: 'Invalid credentials');
        when(
          () => mockLoginUsecase(any()),
        ).thenAnswer((_) async => const Left(failure));
        final viewModel = container.read(authViewModelProvider.notifier);
        await viewModel.login(email: 'test@gmail.com', password: 'wrong');
        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Invalid credentials');
      });
    });

    group('Logout', () {
      test('success', () async {
        when(
          () => mockLogoutUsecase(),
        ).thenAnswer((_) async => const Right(true));
        final viewModel = container.read(authViewModelProvider.notifier);
        await viewModel.logout();
        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.unauthenticated);
        expect(state.user, isNull);
      });

      test('failure', () async {
        const failure = ApiFailure(message: 'Logout failed');
        when(
          () => mockLogoutUsecase(),
        ).thenAnswer((_) async => const Left(failure));
        final viewModel = container.read(authViewModelProvider.notifier);
        await viewModel.logout();
        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Logout failed');
      });
    });

    // group('ForgotPassword', () {
    //   test('success', () async {
    //     when(
    //       () => mockForgotPasswordUsecase(any()),
    //     ).thenAnswer((_) async => Future.value());

    //     final viewModel = container.read(authViewModelProvider.notifier);

    //     await viewModel.sendPasswordResetEmail('test@example.com');

    //     final state = container.read(authViewModelProvider);
    //     expect(state.status, AuthStatus.passwordResetEmailSent);
    //     expect(state.errorMessage, isNull);
    //   });

    //   test('failure', () async {
    //     when(
    //       () => mockForgotPasswordUsecase(any()),
    //     ).thenThrow(Exception('Failed to send email'));

    //     final viewModel = container.read(authViewModelProvider.notifier);

    //     await viewModel.sendPasswordResetEmail('test@example.com');

    //     final state = container.read(authViewModelProvider);
    //     expect(state.status, AuthStatus.error);
    //     expect(state.errorMessage, 'Failed to send email');
    //   });
    // });

    group('ResetPassword', () {
      test('success', () async {
        when(
          () => mockResetPasswordUsecase(any()),
        ).thenAnswer((_) async => const Right(true));
        final viewModel = container.read(authViewModelProvider.notifier);
        await viewModel.resetPassword(token: 'token123', newPassword: '123456');
        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.passwordResetSuccess);
        expect(state.errorMessage, isNull);
      });

      test('failure', () async {
        when(() => mockResetPasswordUsecase(any())).thenAnswer(
          (_) async => const Left(ApiFailure(message: 'Reset failed')),
        );
        final viewModel = container.read(authViewModelProvider.notifier);
        await viewModel.resetPassword(token: 'token123', newPassword: '123456');
        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Reset failed');
      });
    });
  });
}
