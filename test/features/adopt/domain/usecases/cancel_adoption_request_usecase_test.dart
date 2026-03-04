import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/features/adopt/domain/repositories/animal_post_repository.dart';
import 'package:adoptnest/features/adopt/domain/usecases/cancel_adoption_request_usecase.dart';

class MockAnimalPostRepository extends Mock implements IAnimalPostRepository {}

void main() {
  late MockAnimalPostRepository repository;
  late CancelAdoptionRequestUsecase usecase;

  setUp(() {
    repository = MockAnimalPostRepository();
    usecase = CancelAdoptionRequestUsecase(repository: repository);
  });

  group('CancelAdoptionRequestUsecase', () {
    test('returns Right(void) on successful cancellation', () async {
      when(() => repository.cancelAdoptionRequest('post-1'))
          .thenAnswer((_) async => const Right(null));

      final result = await usecase(
          const CancelAdoptionRequestParams(postId: 'post-1'));

      expect(result.isRight(), true);
      verify(() => repository.cancelAdoptionRequest('post-1')).called(1);
    });

    test('returns ApiFailure when no active request exists', () async {
      const failure =
          ApiFailure(message: 'No adoption request found', statusCode: 404);
      when(() => repository.cancelAdoptionRequest('post-1'))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(
          const CancelAdoptionRequestParams(postId: 'post-1'));

      expect(result.isLeft(), true);
      result.fold(
        (f) {
          expect(f.message, 'No adoption request found');
          expect((f as ApiFailure).statusCode, 404);
        },
        (_) => fail('Expected failure'),
      );
    });

    test('returns NetworkFailure when device is offline', () async {
      const failure = NetworkFailure();
      when(() => repository.cancelAdoptionRequest('post-1'))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(
          const CancelAdoptionRequestParams(postId: 'post-1'));

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test('passes correct postId to repository', () async {
      when(() => repository.cancelAdoptionRequest('specific-post-id'))
          .thenAnswer((_) async => const Right(null));

      await usecase(
          const CancelAdoptionRequestParams(postId: 'specific-post-id'));

      verify(() => repository.cancelAdoptionRequest('specific-post-id'))
          .called(1);
      verifyNever(() => repository.cancelAdoptionRequest('post-1'));
    });
  });
}