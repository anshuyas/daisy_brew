import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daisy_brew/features/auth/domain/usecases/register_usecase.dart';
import 'package:daisy_brew/core/error/failures.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

void main() {
  late MockRegisterUsecase mockRegisterUsecase;

  setUpAll(() {
    registerFallbackValue(
      const RegisterParams(
        fullName: 'fallback',
        email: 'fallback@email.com',
        password: 'fallback',
        confirmPassword: 'fallback',
      ),
    );
  });

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
  });

  group('RegisterUsecase', () {
    const tFullName = 'Test User';
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    const tConfirmPassword = 'password123';

    test('should return true when registration is successful', () async {
      // Arrange
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final result = await mockRegisterUsecase(
        const RegisterParams(
          fullName: tFullName,
          email: tEmail,
          password: tPassword,
          confirmPassword: tConfirmPassword,
        ),
      );

      // Assert
      expect(result, const Right(true));
      verify(() => mockRegisterUsecase(any())).called(1);
    });

    test('should return Failure when registration fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Email already exists');
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await mockRegisterUsecase(
        const RegisterParams(
          fullName: tFullName,
          email: tEmail,
          password: tPassword,
          confirmPassword: tConfirmPassword,
        ),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRegisterUsecase(any())).called(1);
    });

    test('should pass correct parameters to usecase', () async {
      // Arrange
      RegisterParams? capturedParams;
      when(() => mockRegisterUsecase(any())).thenAnswer((invocation) {
        capturedParams = invocation.positionalArguments[0] as RegisterParams;
        return Future.value(const Right(true));
      });

      // Act
      await mockRegisterUsecase(
        const RegisterParams(
          fullName: tFullName,
          email: tEmail,
          password: tPassword,
          confirmPassword: tConfirmPassword,
        ),
      );

      // Assert
      expect(capturedParams?.fullName, tFullName);
      expect(capturedParams?.email, tEmail);
      expect(capturedParams?.password, tPassword);
      expect(capturedParams?.confirmPassword, tConfirmPassword);
    });
  });
}
