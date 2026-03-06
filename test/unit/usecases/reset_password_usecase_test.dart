import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daisy_brew/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:daisy_brew/features/auth/domain/repositories/auth_repository.dart';
import 'package:daisy_brew/core/error/failures.dart';

// Mock Repository
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late ResetPasswordUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = ResetPasswordUsecase(mockRepository);
  });

  const testToken = "reset_token_123";
  const testPassword = "NewPassword@123";

  group('ResetPasswordUsecase Tests', () {
    test(
      'should call repository.resetPassword with correct parameters',
      () async {
        // Arrange
        when(
          () => mockRepository.resetPassword(
            token: testToken,
            newPassword: testPassword,
          ),
        ).thenAnswer((_) async => const Right(true));

        // Act
        await usecase(
          ResetPasswordParams(token: testToken, newPassword: testPassword),
        );

        // Assert
        verify(
          () => mockRepository.resetPassword(
            token: testToken,
            newPassword: testPassword,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return Right(true) when repository reset is successful',
      () async {
        // Arrange
        when(
          () => mockRepository.resetPassword(
            token: testToken,
            newPassword: testPassword,
          ),
        ).thenAnswer((_) async => const Right(true));

        // Act
        final result = await usecase(
          ResetPasswordParams(token: testToken, newPassword: testPassword),
        );

        // Assert
        expect(result, const Right(true));
      },
    );

    test('should return Left(Failure) when repository reset fails', () async {
      // Arrange
      final failure = ApiFailure(message: "Reset token expired");

      when(
        () => mockRepository.resetPassword(
          token: testToken,
          newPassword: testPassword,
        ),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await usecase(
        ResetPasswordParams(token: testToken, newPassword: testPassword),
      );

      // Assert
      expect(result, Left(failure));
    });
  });
}
