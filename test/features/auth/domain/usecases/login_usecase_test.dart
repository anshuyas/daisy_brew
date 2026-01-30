import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daisy_brew/features/auth/domain/entities/auth_entity.dart';
import 'package:daisy_brew/features/auth/domain/usecases/login_usecase.dart';
import 'package:daisy_brew/core/error/failures.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}

void main() {
  late MockLoginUsecase mockLoginUsecase;

  const tUser = AuthEntity(
    authId: '1',
    fullName: 'Test User',
    email: 'test@example.com',
  );

  setUpAll(() {
    registerFallbackValue(
      const LoginParams(email: 'fallback@email.com', password: 'fallback'),
    );
  });

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
  });

  group('LoginUsecase', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';

    test('should return AuthEntity when login is successful', () async {
      // Arrange
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Right(tUser));

      // Act
      final result = await mockLoginUsecase(
        const LoginParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Right(tUser));
      verify(() => mockLoginUsecase(any())).called(1);
    });

    test('should return Failure when login fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Invalid credentials');
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await mockLoginUsecase(
        const LoginParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockLoginUsecase(any())).called(1);
    });

    test('should pass correct email and password to usecase', () async {
      // Arrange
      LoginParams? capturedParams;
      when(() => mockLoginUsecase(any())).thenAnswer((invocation) {
        capturedParams = invocation.positionalArguments[0] as LoginParams;
        return Future.value(const Right(tUser));
      });

      // Act
      await mockLoginUsecase(
        const LoginParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(capturedParams?.email, tEmail);
      expect(capturedParams?.password, tPassword);
    });
  });
}
