import 'package:adoptnest/core/usecases/app_usecase.dart';
import 'package:adoptnest/features/adopt/data/repositories/animal_post_repository.dart';
import 'package:adoptnest/features/adopt/domain/repositories/animal_post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/core/error/failures.dart';

class RequestAdoptionParams extends Equatable {
  final String postId;
  const RequestAdoptionParams({required this.postId});

  @override
  List<Object?> get props => [postId];
}

final requestAdoptionUsecaseProvider = Provider<RequestAdoptionUsecase>((ref) {
  return RequestAdoptionUsecase(repository: ref.read(animalPostRepositoryProvider));
});

class RequestAdoptionUsecase
    implements UsecaseWithParams<void, RequestAdoptionParams> {
  final IAnimalPostRepository _repository;

  RequestAdoptionUsecase({required IAnimalPostRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, void>> call(RequestAdoptionParams params) {
    return _repository.requestAdoption(params.postId);
  }
}
