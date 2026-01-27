import 'package:adoptnest/core/usecases/app_usecase.dart';
import 'package:adoptnest/features/report_animals/data/repositories/animal_report_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/core/error/failures.dart';
import '../repositories/animal_report_repository.dart';
import '../entities/animal_report_entity.dart';

class GetMyReportsParams extends Equatable {
  final String userId;

  const GetMyReportsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

final getMyReportsUsecaseProvider =
    Provider<GetMyReportsUsecase>((ref) {
  final repository = ref.read(animalReportRepositoryProvider);
  return GetMyReportsUsecase(repository: repository);
});

class GetMyReportsUsecase
    implements UsecaseWithParams<List<AnimalReportEntity>, GetMyReportsParams> {
  final IAnimalReportRepository _repository;

  GetMyReportsUsecase({required IAnimalReportRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<AnimalReportEntity>>> call(
      GetMyReportsParams params) {
    return _repository.getMyReports(params.userId);
  }
}
