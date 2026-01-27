import 'package:adoptnest/core/usecases/app_usecase.dart';
import 'package:adoptnest/features/report_animals/data/repositories/animal_report_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/core/error/failures.dart';
import '../repositories/animal_report_repository.dart';
import '../entities/animal_report_entity.dart';

class GetAnimalReportByIdParams extends Equatable {
  final String reportId;

  const GetAnimalReportByIdParams({required this.reportId});

  @override
  List<Object?> get props => [reportId];
}

final getAnimalReportByIdUsecaseProvider =
    Provider<GetAnimalReportByIdUsecase>((ref) {
  final repository = ref.read(animalReportRepositoryProvider);
  return GetAnimalReportByIdUsecase(repository: repository);
});

class GetAnimalReportByIdUsecase
    implements UsecaseWithParams<AnimalReportEntity, GetAnimalReportByIdParams> {
  final IAnimalReportRepository _repository;

  GetAnimalReportByIdUsecase({required IAnimalReportRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, AnimalReportEntity>> call(
      GetAnimalReportByIdParams params) {
    return _repository.getAnimalReportById(params.reportId);
  }
}
