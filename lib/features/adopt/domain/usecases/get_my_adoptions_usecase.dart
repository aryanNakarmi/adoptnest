import 'package:adoptnest/core/usecases/app_usecase.dart';
import 'package:adoptnest/features/adopt/data/repositories/animal_post_repository.dart';
import 'package:adoptnest/features/adopt/domain/repositories/animal_post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/core/error/failures.dart';
import '../entities/animal_post_entity.dart';

final getMyAdoptionsUsecaseProvider = Provider<GetMyAdoptionsUsecase>((ref) {
  final repository = ref.read(animalPostRepositoryProvider);
  return GetMyAdoptionsUsecase(repository: repository);
});

class GetMyAdoptionsUsecase
    implements UsecaseWithoutParams<List<AnimalPostEntity>> {
  final IAnimalPostRepository _repository;

  GetMyAdoptionsUsecase({required IAnimalPostRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<AnimalPostEntity>>> call() {
    return _repository.getMyAdoptions();
  }
}
