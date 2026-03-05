import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/features/auth/domain/repositories/auth_repository.dart';
import 'package:adoptnest/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository repository;
  late LogoutUsecase usecase;

  setUp(() {
    repository = MockAuthRepository();
    usecase = LogoutUsecase(authRepository: repository);
  });

  group('LogoutUsecase', () {
    test('returns true on successful logout', () async {
      when(() => repository.logout())
          .thenAnswer((_) async => const Right(true));

      final result = await usecase();

      expect(result, const Right<Failure, bool>(true));
      verify(() => repository.logout()).called(1);
    });

    test('returns ApiFailure when logout fails on server', () async {
      const failure = ApiFailure(message: 'Logout failed', statusCode: 500);
      when(() => repository.logout())
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f.message, 'Logout failed'),
        (_) => fail('Expected failure'),
      );
    });

    test('returns NetworkFailure when device is offline', () async {
      const failure = NetworkFailure();
      when(() => repository.logout())
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test('calls repository logout exactly once', () async {
      when(() => repository.logout())
          .thenAnswer((_) async => const Right(true));

      await usecase();

      verify(() => repository.logout()).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}