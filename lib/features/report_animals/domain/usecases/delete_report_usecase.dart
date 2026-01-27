import 'package:adoptnest/core/usecases/app_usecase.dart';
import 'package:adoptnest/features/report_animals/data/repositories/animal_report_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/core/error/failures.dart';  
import '../repositories/animal_report_repository.dart';

class DeleteReportParams extends Equatable {
  final String reportId;

  const DeleteReportParams({required this.reportId});

  @override
  List<Object?> get props => [reportId];
}

final deleteReportUsecaseProvider =
    Provider<DeleteReportUsecase>((ref) {
  final repository = ref.read(animalReportRepositoryProvider);
  return DeleteReportUsecase(repository: repository);
});

class DeleteReportUsecase
    implements UsecaseWithParams<bool, DeleteReportParams> {
  final IAnimalReportRepository _repository;

  DeleteReportUsecase({required IAnimalReportRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(DeleteReportParams params) {
    return _repository.deleteReport(params.reportId);
  }
}
