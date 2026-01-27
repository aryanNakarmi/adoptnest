import 'package:adoptnest/core/usecases/app_usecase.dart';
import 'package:adoptnest/features/report_animals/data/repositories/animal_report_repository.dart';
import 'package:adoptnest/features/report_animals/domain/repositories/animal_report_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/core/error/failures.dart';
import '../entities/animal_report_entity.dart';


class CreateReportParams extends Equatable {
  final AnimalReportEntity report;

  const CreateReportParams({required this.report});

  @override
  List<Object?> get props => [report];
}

final createAnimalReportUsecaseProvider =
    Provider<CreateAnimalReportUsecase>((ref) {
  final repository = ref.read(animalReportRepositoryProvider);
  return CreateAnimalReportUsecase(repository: repository);
});


class CreateAnimalReportUsecase
    implements UsecaseWithParams<AnimalReportEntity, CreateReportParams> {
  final IAnimalReportRepository _repository;

  CreateAnimalReportUsecase({required IAnimalReportRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, AnimalReportEntity>> call(CreateReportParams params) {
    return _repository.createAnimalReport(params.report);
  }
}