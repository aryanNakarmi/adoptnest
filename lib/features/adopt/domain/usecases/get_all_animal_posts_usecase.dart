import 'package:adoptnest/core/usecases/app_usecase.dart';
import 'package:adoptnest/features/adopt/data/repositories/animal_post_repository.dart';
import 'package:adoptnest/features/adopt/domain/repositories/animal_post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/core/error/failures.dart';
import '../entities/animal_post_entity.dart';

final getAllAnimalPostsUsecaseProvider = Provider<GetAllAnimalPostsUsecase>((ref) {
  final repository = ref.read(animalPostRepositoryProvider);
  return GetAllAnimalPostsUsecase(repository: repository);
});

class GetAllAnimalPostsUsecase
    implements UsecaseWithoutParams<List<AnimalPostEntity>> {
  final IAnimalPostRepository _repository;

  GetAllAnimalPostsUsecase({required IAnimalPostRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<AnimalPostEntity>>> call() {
    return _repository.getAllAnimalPosts();
  }
}
