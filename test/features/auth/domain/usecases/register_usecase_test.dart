import 'package:daisy_brew/core/error/failures.dart';
import 'package:daisy_brew/features/auth/domain/entities/auth_entity.dart';
import 'package:daisy_brew/features/auth/domain/repositories/auth_repository.dart';
import 'package:daisy_brew/features/auth/domain/usecases/register_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUsecase(authRepository: mockRepository);
  });

  const tFullName = 'Test User';
  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tConfirmPassword = 'password123';

  setUpAll(() {
    registerFallbackValue(
      AuthEntity(
        fullName: 'fallback',
        email: 'fallback@email.com',
        password: 'fallback',
      ),
    );
    registerFallbackValue(
      const RegisterParams(
        fullName: 'fallback',
        email: 'fallback@email.com',
        password: 'fallback',
        confirmPassword: 'fallback',
      ),
    );
  });

  group('RegisterUsecase', () {
    test('should return true when registration is successful', () async {
      // Arrange
      when(
        () => mockRepository.register(
          any(),
          user: any(named: 'user'),
          confirmPassword: any(named: 'confirmPassword'),
        ),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(
        const RegisterParams(
          fullName: tFullName,
          email: tEmail,
          password: tPassword,
          confirmPassword: tConfirmPassword,
        ),
      );

      // Assert
      expect(result, const Right(true));
      verify(
        () => mockRepository.register(
          any(),
          user: any(named: 'user'),
          confirmPassword: any(named: 'confirmPassword'),
        ),
      ).called(1);
    });

    test('should return failure when registration fails', () async {
      const failure = ApiFailure(message: 'Email already exists');
      when(
        () => mockRepository.register(
          any(),
          user: any(named: 'user'),
          confirmPassword: any(named: 'confirmPassword'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        const RegisterParams(
          fullName: tFullName,
          email: tEmail,
          password: tPassword,
          confirmPassword: tConfirmPassword,
        ),
      );

      expect(result, const Left(failure));
      verify(
        () => mockRepository.register(
          any(),
          user: any(named: 'user'),
          confirmPassword: any(named: 'confirmPassword'),
        ),
      ).called(1);
    });

    test('should pass correct values to repository', () async {
      late RegisterParams capturedParams;
      late AuthEntity capturedUser;
      late String capturedConfirmPassword;

      when(
        () => mockRepository.register(
          any(),
          user: any(named: 'user'),
          confirmPassword: any(named: 'confirmPassword'),
        ),
      ).thenAnswer((invocation) async {
        capturedParams = invocation.positionalArguments[0] as RegisterParams;
        capturedUser = invocation.namedArguments[#user] as AuthEntity;
        capturedConfirmPassword =
            invocation.namedArguments[#confirmPassword] as String;
        return const Right(true);
      });

      await usecase(
        const RegisterParams(
          fullName: tFullName,
          email: tEmail,
          password: tPassword,
          confirmPassword: tConfirmPassword,
        ),
      );

      expect(capturedParams.fullName, tFullName);
      expect(capturedUser.fullName, tFullName);
      expect(capturedUser.email, tEmail);
      expect(capturedUser.password, tPassword);
      expect(capturedConfirmPassword, tConfirmPassword);
    });
  });
}
