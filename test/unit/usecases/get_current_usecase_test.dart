import 'package:daisy_brew/core/error/failures.dart';
import 'package:daisy_brew/features/auth/domain/entities/auth_entity.dart';
import 'package:daisy_brew/features/auth/domain/repositories/auth_repository.dart';
import 'package:daisy_brew/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late GetCurrentUserUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = GetCurrentUserUsecase(authRepository: mockRepository);
  });

  const tUser = AuthEntity(
    authId: '1',
    fullName: 'Test User',
    email: 'test@example.com',
    role: 'user',
  );

  group('GetCurrentUserUsecase', () {
    test('should return AuthEntity when user is authenticated', () async {
      // Arrange
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tUser));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(tUser));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when user is not authenticated', () async {
      // Arrange
      const failure = ApiFailure(message: 'User not authenticated');
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should return LocalDatabaseFailure when local storage fails',
      () async {
        // Arrange
        const failure = LocalDatabaseFailure(
          message: 'Failed to read user data',
        );
        when(
          () => mockRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await usecase();

        // Assert
        expect(result, const Left(failure));
        verify(() => mockRepository.getCurrentUser()).called(1);
      },
    );

    test(
      'should return NetworkFailure when fetching from remote fails',
      () async {
        // Arrange
        const failure = NetworkFailure();
        when(
          () => mockRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await usecase();

        // Assert
        expect(result, const Left(failure));
        verify(() => mockRepository.getCurrentUser()).called(1);
      },
    );

    test('should return user with all fields populated', () async {
      // Arrange
      const userWithAllFields = AuthEntity(
        authId: '1',
        fullName: 'Test User',
        email: 'test@example.com',
        role: 'user',
        profilePicture: 'https://example.com/pic.jpg',
      );
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(userWithAllFields));

      // Act
      final result = await usecase();

      // Assert
      result.fold((failure) => fail('Should return user'), (user) {
        expect(user.authId, '1');
        expect(user.fullName, 'Test User');
        expect(user.email, 'test@example.com');
        expect(user.profilePicture, 'https://example.com/pic.jpg');
      });
    });
  });
}
