import 'package:adoptnest/core/usecases/app_usecase.dart';
import 'package:adoptnest/features/report_animals/data/repositories/animal_report_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/core/error/failures.dart';
import '../repositories/animal_report_repository.dart';
import '../entities/animal_report_entity.dart';

class GetReportsBySpeciesParams extends Equatable {
  final String species;

  const GetReportsBySpeciesParams({required this.species});

  @override
  List<Object?> get props => [species];
}

final getReportsBySpeciesUsecaseProvider =
    Provider<GetReportsBySpeciesUsecase>((ref) {
  final repository = ref.read(animalReportRepositoryProvider);
  return GetReportsBySpeciesUsecase(repository: repository);
});

class GetReportsBySpeciesUsecase
    implements UsecaseWithParams<List<AnimalReportEntity>, GetReportsBySpeciesParams> {
  final IAnimalReportRepository _repository;

  GetReportsBySpeciesUsecase({required IAnimalReportRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<AnimalReportEntity>>> call(
      GetReportsBySpeciesParams params) {
    return _repository.getReportsBySpecies(params.species);
  }
}
