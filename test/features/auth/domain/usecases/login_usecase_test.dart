import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/features/auth/domain/entities/auth_entity.dart';
import 'package:adoptnest/features/auth/domain/repositories/auth_repository.dart';
import 'package:adoptnest/features/auth/domain/usecases/login_usecase.dart';
import 'package:mocktail/mocktail.dart';

// 1. Simple mock class
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(authRepository: mockRepository);
  });

  // Test data
  const email = 'test@example.com';
  const password = 'password123';
  final auth = AuthEntity(fullName: 'Test User', email: email);

  test('should return AuthEntity on successful login', () async {
    // Arrange
    when(() => mockRepository.login(email, password))
        .thenAnswer((_) async => Right(auth));

    // Act
    final result =
        await usecase(LoginUsecaseParams(email: email, password: password));

    // Assert
    expect(result, Right(auth));
    verify(() => mockRepository.login(email, password)).called(1);
  });

  test('should return Failure on failed login', () async {
    // Arrange
    when(() => mockRepository.login(email, password))
        .thenAnswer((_) async => Left(NetworkFailure()));

    // Act
    final result =
        await usecase(LoginUsecaseParams(email: email, password: password));

    // Assert
    expect(result, Left(NetworkFailure()));
    verify(() => mockRepository.login(email, password)).called(1);
  });
}
