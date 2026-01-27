import 'package:adoptnest/core/usecases/app_usecase.dart';
import 'package:adoptnest/features/report_animals/data/repositories/animal_report_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/core/error/failures.dart';
import '../repositories/animal_report_repository.dart';
import '../entities/animal_report_entity.dart';

final createAnimalReportUsecaseProvider =
    Provider<CreateAnimalReportUsecase>((ref) {
  final repository = ref.read(animalReportRepositoryProvider);
  return CreateAnimalReportUsecase(repository: repository);
});

class CreateAnimalReportUsecase
    implements UsecaseWithParams<AnimalReportEntity, AnimalReportEntity> {
  final IAnimalReportRepository _repository;

  CreateAnimalReportUsecase({required IAnimalReportRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, AnimalReportEntity>> call(AnimalReportEntity report) {
    return _repository.createAnimalReport(report);
  }
}
