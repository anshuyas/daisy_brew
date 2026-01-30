import 'package:daisy_brew/features/auth/domain/entities/auth_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:daisy_brew/features/auth/domain/usecases/login_usecase.dart';
import 'package:daisy_brew/features/auth/domain/usecases/logout_usecase.dart';
import 'package:daisy_brew/features/auth/domain/usecases/register_usecase.dart';
import 'package:daisy_brew/features/auth/presentation/state/auth_state.dart';
import 'package:daisy_brew/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:daisy_brew/core/error/failures.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

void main() {
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late ProviderContainer container;

  setUpAll(() {
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

    container = ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  final tUser = AuthEntity(
    authId: '1',
    fullName: 'Test User',
    email: 'test@gmail.com',
    token: 'token_123',
  );

  group('AuthViewModel', () {
    group('initial state', () {
      test('should have initial state when created', () {
        final state = container.read(authViewModelProvider);

        expect(state.status, AuthStatus.initial);
        expect(state.user, isNull);
        expect(state.errorMessage, isNull);
      });
    });

    // REGISTER
    group('register', () {
      test(
        'should emit registered state when registration is successful',
        () async {
          // Arrange
          when(
            () => mockRegisterUsecase(any()),
          ).thenAnswer((_) async => const Right(true));

          final viewModel = container.read(authViewModelProvider.notifier);

          // Act
          await viewModel.register(
            fullName: 'Test',
            email: 'test@gmail.com',
            password: '123456',
            confirmPassword: '123456',
          );

          // Assert
          final state = container.read(authViewModelProvider);
          expect(state.status, AuthStatus.registered);
          verify(() => mockRegisterUsecase(any())).called(1);
        },
      );

      test('should emit error state when registration fails', () async {
        // Arrange
        const failure = ApiFailure(message: 'Registration failed');

        when(
          () => mockRegisterUsecase(any()),
        ).thenAnswer((_) async => const Left(failure));

        final viewModel = container.read(authViewModelProvider.notifier);

        // Act
        await viewModel.register(
          fullName: 'Test',
          email: 'test@gmail.com',
          password: '123456',
          confirmPassword: '123456',
        );

        // Assert
        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Registration failed');
      });
    });

    //LOGIN
    group('login', () {
      test(
        'should emit authenticated state when login is successful',
        () async {
          // Arrange
          when(
            () => mockLoginUsecase(any()),
          ).thenAnswer((_) async => Right(tUser));

          final viewModel = container.read(authViewModelProvider.notifier);

          // Act
          await viewModel.login(email: 'test@gmail.com', password: '123456');

          // Assert
          final state = container.read(authViewModelProvider);
          expect(state.status, AuthStatus.authenticated);
          expect(state.user, tUser);
          verify(() => mockLoginUsecase(any())).called(1);
        },
      );

      test('should emit error state when login fails', () async {
        // Arrange
        const failure = ApiFailure(message: 'Invalid credentials');

        when(
          () => mockLoginUsecase(any()),
        ).thenAnswer((_) async => const Left(failure));

        final viewModel = container.read(authViewModelProvider.notifier);

        // Act
        await viewModel.login(email: 'test@gmail.com', password: 'wrongpass');

        // Assert
        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Invalid credentials');
      });
    });

    group('logout', () {
      test(
        'should emit unauthenticated state when logout is successful',
        () async {
          // Arrange
          when(
            () => mockLogoutUsecase(),
          ).thenAnswer((_) async => const Right(true));

          final viewModel = container.read(authViewModelProvider.notifier);

          // Act
          await viewModel.logout();

          // Assert
          final state = container.read(authViewModelProvider);
          expect(state.status, AuthStatus.unauthenticated);
          expect(state.user, isNull);
        },
      );

      test('should emit error state when logout fails', () async {
        // Arrange
        const failure = ApiFailure(message: 'Logout failed');

        when(
          () => mockLogoutUsecase(),
        ).thenAnswer((_) async => const Left(failure));

        final viewModel = container.read(authViewModelProvider.notifier);

        // Act
        await viewModel.logout();

        // Assert
        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Logout failed');
      });
    });

    group('clearError', () {
      test('should clear error message', () async {
        const failure = ApiFailure(message: 'Some error');

        when(
          () => mockLoginUsecase(any()),
        ).thenAnswer((_) async => const Left(failure));

        final viewModel = container.read(authViewModelProvider.notifier);

        await viewModel.login(email: 'a', password: 'b');

        var state = container.read(authViewModelProvider);
        expect(state.errorMessage, 'Some error');

        // Act
        viewModel.clearError();

        state = container.read(authViewModelProvider);
        expect(state.errorMessage, isNull);
      });
    });
  });

  group('AuthState', () {
    test('initial values', () {
      const state = AuthState();

      expect(state.status, AuthStatus.initial);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
    });

    test('copyWith updates values correctly', () {
      const state = AuthState();

      final newState = state.copyWith(
        status: AuthStatus.authenticated,
        user: tUser,
      );

      expect(newState.status, AuthStatus.authenticated);
      expect(newState.user, tUser);
      expect(newState.errorMessage, isNull);
    });

    test('states with same values are equal', () {
      final s1 = AuthState(status: AuthStatus.authenticated, user: tUser);
      final s2 = AuthState(status: AuthStatus.authenticated, user: tUser);

      expect(s1, s2);
    });
  });
}
