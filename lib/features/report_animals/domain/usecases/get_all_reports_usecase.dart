import 'package:adoptnest/core/usecases/app_usecase.dart';
import 'package:adoptnest/features/report_animals/data/repositories/animal_report_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/core/error/failures.dart';

import '../repositories/animal_report_repository.dart';
import '../entities/animal_report_entity.dart';

final getAllAnimalReportsUsecaseProvider =
    Provider<GetAllAnimalReportsUsecase>((ref) {
  final repository = ref.read(animalReportRepositoryProvider);
  return GetAllAnimalReportsUsecase(repository: repository);
});

class GetAllAnimalReportsUsecase
    implements UsecaseWithoutParams<List<AnimalReportEntity>> {
  final IAnimalReportRepository _repository;

  GetAllAnimalReportsUsecase({required IAnimalReportRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<AnimalReportEntity>>> call() {
    return _repository.getAllAnimalReports();
  }
}
