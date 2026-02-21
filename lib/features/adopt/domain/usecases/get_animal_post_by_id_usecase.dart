import 'package:adoptnest/core/usecases/app_usecase.dart';
import 'package:adoptnest/features/adopt/data/repositories/animal_post_repository.dart';
import 'package:adoptnest/features/adopt/domain/repositories/animal_post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/core/error/failures.dart';
import '../entities/animal_post_entity.dart';

class GetAnimalPostByIdParams extends Equatable {
  final String postId;
  const GetAnimalPostByIdParams({required this.postId});

  @override
  List<Object?> get props => [postId];
}

final getAnimalPostByIdUsecaseProvider = Provider<GetAnimalPostByIdUsecase>((ref) {
  final repository = ref.read(animalPostRepositoryProvider);
  return GetAnimalPostByIdUsecase(repository: repository);
});

class GetAnimalPostByIdUsecase
    implements UsecaseWithParams<AnimalPostEntity, GetAnimalPostByIdParams> {
  final IAnimalPostRepository _repository;

  GetAnimalPostByIdUsecase({required IAnimalPostRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, AnimalPostEntity>> call(GetAnimalPostByIdParams params) {
    return _repository.getAnimalPostById(params.postId);
  }
}
