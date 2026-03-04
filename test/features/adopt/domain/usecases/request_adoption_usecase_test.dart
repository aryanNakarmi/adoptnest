import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/features/adopt/domain/repositories/animal_post_repository.dart';
import 'package:adoptnest/features/adopt/domain/usecases/request_adoption_usecase.dart';

class MockAnimalPostRepository extends Mock implements IAnimalPostRepository {}

void main() {
  late MockAnimalPostRepository repository;
  late RequestAdoptionUsecase usecase;

  setUp(() {
    repository = MockAnimalPostRepository();
    usecase = RequestAdoptionUsecase(repository: repository);
  });

  group('RequestAdoptionUsecase', () {
    test('returns Right(void) on successful adoption request', () async {
      when(() => repository.requestAdoption('post-1'))
          .thenAnswer((_) async => const Right(null));

      final result =
          await usecase(const RequestAdoptionParams(postId: 'post-1'));

      expect(result.isRight(), true);
      verify(() => repository.requestAdoption('post-1')).called(1);
    });

    test('returns ApiFailure with 400 when already requested', () async {
      const failure =
          ApiFailure(message: 'Already requested', statusCode: 400);
      when(() => repository.requestAdoption('post-1'))
          .thenAnswer((_) async => const Left(failure));

      final result =
          await usecase(const RequestAdoptionParams(postId: 'post-1'));

      expect(result.isLeft(), true);
      result.fold(
        (f) {
          expect(f.message, 'Already requested');
          expect((f as ApiFailure).statusCode, 400);
        },
        (_) => fail('Expected failure'),
      );
    });

    test('returns NetworkFailure when device is offline', () async {
      const failure = NetworkFailure();
      when(() => repository.requestAdoption('post-1'))
          .thenAnswer((_) async => const Left(failure));

      final result =
          await usecase(const RequestAdoptionParams(postId: 'post-1'));

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test('passes correct postId to repository', () async {
      when(() => repository.requestAdoption('specific-post-id'))
          .thenAnswer((_) async => const Right(null));

      await usecase(const RequestAdoptionParams(postId: 'specific-post-id'));

      verify(() => repository.requestAdoption('specific-post-id')).called(1);
      verifyNever(() => repository.requestAdoption('post-1'));
    });
  });
}