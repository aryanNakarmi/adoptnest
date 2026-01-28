import 'package:adoptnest/core/usecases/app_usecase.dart';
import 'package:adoptnest/features/report_animals/data/repositories/animal_report_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/core/error/failures.dart';
import '../repositories/animal_report_repository.dart';
import '../entities/animal_report_entity.dart';

class UpdateReportStatusParams extends Equatable {
  final String reportId;
  final AnimalReportStatus newStatus;

  const UpdateReportStatusParams({required this.reportId, required this.newStatus});

  @override
  List<Object?> get props => [reportId, newStatus];
}

final updateReportStatusUsecaseProvider =
    Provider<UpdateReportStatusUsecase>((ref) {
  final repository = ref.read(animalReportRepositoryProvider);
  return UpdateReportStatusUsecase(repository: repository);
});

class UpdateReportStatusUsecase
    implements UsecaseWithParams<AnimalReportEntity, UpdateReportStatusParams> {
  final IAnimalReportRepository _repository;

  UpdateReportStatusUsecase({required IAnimalReportRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, AnimalReportEntity>> call(UpdateReportStatusParams params) {
    return _repository.updateReportStatus(params.reportId, params.newStatus.name);
  }
}
