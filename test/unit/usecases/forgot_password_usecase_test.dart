import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daisy_brew/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:daisy_brew/features/auth/domain/repositories/auth_repository.dart';
import 'package:daisy_brew/core/error/failures.dart';

// Create Mock
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late ForgotPasswordUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = ForgotPasswordUsecase(mockRepository);
  });

  const testEmail = "test@example.com";

  group('ForgotPasswordUsecase Tests', () {
    test('should call sendPasswordResetEmail with correct email', () async {
      // Arrange
      when(
        () => mockRepository.sendPasswordResetEmail(testEmail),
      ).thenAnswer((_) async => const Right(true));

      // Act
      await usecase(ForgotPasswordParams(email: testEmail));

      // Assert
      verify(() => mockRepository.sendPasswordResetEmail(testEmail)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should complete without exception when success is returned',
      () async {
        // Arrange
        when(
          () => mockRepository.sendPasswordResetEmail(testEmail),
        ).thenAnswer((_) async => const Right(true));

        // Act & Assert
        expect(
          () async => await usecase(ForgotPasswordParams(email: testEmail)),
          returnsNormally,
        );
      },
    );

    test('should throw Exception when repository returns Failure', () async {
      // Arrange
      final failure = ApiFailure(message: "Email not found");

      when(
        () => mockRepository.sendPasswordResetEmail(testEmail),
      ).thenAnswer((_) async => Left(failure));

      // Act & Assert
      expect(
        () async => await usecase(ForgotPasswordParams(email: testEmail)),
        throwsA(isA<Exception>()),
      );
    });
  });
}
