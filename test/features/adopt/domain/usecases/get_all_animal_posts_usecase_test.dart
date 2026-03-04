import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/features/adopt/domain/entities/animal_post_entity.dart';
import 'package:adoptnest/features/adopt/domain/repositories/animal_post_repository.dart';
import 'package:adoptnest/features/adopt/domain/usecases/get_all_animal_posts_usecase.dart';

class MockAnimalPostRepository extends Mock implements IAnimalPostRepository {}

AnimalPostEntity makePost(String id) => AnimalPostEntity(
      postId: id,
      species: 'Dog',
      gender: 'Male',
      breed: 'Labrador',
      age: 2,
      location: 'Kathmandu',
      photos: const ['photo.jpg'],
      status: AnimalPostStatus.available,
      createdAt: DateTime(2024, 1, 1),
    );

void main() {
  late MockAnimalPostRepository repository;
  late GetAllAnimalPostsUsecase usecase;

  setUp(() {
    repository = MockAnimalPostRepository();
    usecase = GetAllAnimalPostsUsecase(repository: repository);
  });

  group('GetAllAnimalPostsUsecase', () {
    test('returns list of posts on success', () async {
      final posts = [makePost('1'), makePost('2')];
      when(() => repository.getAllAnimalPosts())
          .thenAnswer((_) async => Right(posts));

      final result = await usecase();

      expect(result, Right<Failure, List<AnimalPostEntity>>(posts));
      verify(() => repository.getAllAnimalPosts()).called(1);
    });

    test('returns empty list when no posts exist', () async {
      when(() => repository.getAllAnimalPosts())
          .thenAnswer((_) async => const Right([]));

      final result = await usecase();

      expect(result, const Right<Failure, List<AnimalPostEntity>>([]));
    });

    test('returns ApiFailure when server error occurs', () async {
      const failure = ApiFailure(message: 'Server error', statusCode: 500);
      when(() => repository.getAllAnimalPosts())
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f.message, 'Server error'),
        (_) => fail('Expected failure'),
      );
    });

    test('returns NetworkFailure when device is offline', () async {
      const failure = NetworkFailure();
      when(() => repository.getAllAnimalPosts())
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected failure'),
      );
    });
  });
}