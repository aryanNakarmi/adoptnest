import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/features/auth/domain/entities/auth_entity.dart';
import 'package:adoptnest/features/auth/domain/repositories/auth_repository.dart';
import 'package:adoptnest/features/auth/domain/usecases/register_usecase.dart';

// Step 1: Create a mock repository
class MockAuthRepository extends Mock implements IAuthRepository {}

// Step 2: Create a Fake for AuthEntity
class AuthEntityFake extends Fake implements AuthEntity {}

void main() {
  late RegisterUsecase usecase;
  late MockAuthRepository mockRepository;

  // Step 3: Register the fallback value
  setUpAll(() {
    registerFallbackValue(AuthEntityFake());
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUsecase(authRepository: mockRepository);
  });

  // Test data
  const fullName = 'John Doe';
  const email = 'john@example.com';
  const password = 'password123';
  const phoneNumber = '1234567890';

  final authEntity = AuthEntity(
    fullName: fullName,
    email: email,
    phoneNumber: phoneNumber,
    password: password,
    role: 'user',
    authId: '1',
    profilePicture: null,
  );

  test('should return true when registration succeeds', () async {
    // Arrange
    when(() => mockRepository.register(any()))
        .thenAnswer((_) async => const Right(true));

    // Act
    final result = await usecase(
      const RegisterUsecaseParams(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      ),
    );

    // Assert
    expect(result, const Right(true));
    verify(() => mockRepository.register(any())).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Failure when registration fails', () async {
    // Arrange
    when(() => mockRepository.register(any()))
        .thenAnswer((_) async => Left(NetworkFailure()));

    // Act
    final result = await usecase(
      const RegisterUsecaseParams(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      ),
    );

    // Assert
    expect(result, isA<Left>());
    verify(() => mockRepository.register(any())).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
