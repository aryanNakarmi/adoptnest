import 'package:adoptnest/core/usecases/app_usecase.dart';
import 'package:adoptnest/features/adopt/data/repositories/animal_post_repository.dart';
import 'package:adoptnest/features/adopt/domain/repositories/animal_post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/core/error/failures.dart';

class CancelAdoptionRequestParams extends Equatable {
  final String postId;
  const CancelAdoptionRequestParams({required this.postId});

  @override
  List<Object?> get props => [postId];
}

final cancelAdoptionRequestUsecaseProvider =
    Provider<CancelAdoptionRequestUsecase>((ref) {
  return CancelAdoptionRequestUsecase(
      repository: ref.read(animalPostRepositoryProvider));
});

class CancelAdoptionRequestUsecase
    implements UsecaseWithParams<void, CancelAdoptionRequestParams> {
  final IAnimalPostRepository _repository;

  CancelAdoptionRequestUsecase({required IAnimalPostRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, void>> call(CancelAdoptionRequestParams params) {
    return _repository.cancelAdoptionRequest(params.postId);
  }
}
