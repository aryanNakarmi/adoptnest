import 'dart:io';
import 'package:adoptnest/core/usecases/app_usecase.dart';
import 'package:adoptnest/features/report_animals/data/repositories/animal_report_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/core/error/failures.dart';
import '../repositories/animal_report_repository.dart';

final uploadPhotoUsecaseProvider = Provider<UploadPhotoUsecase>((ref) {
  final repository = ref.read(animalReportRepositoryProvider);
  return UploadPhotoUsecase(repository: repository);
});

class UploadPhotoUsecase implements UsecaseWithParams<String, File> {
  final IAnimalReportRepository _repository;

  UploadPhotoUsecase({required IAnimalReportRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, String>> call(File photo) {
    return _repository.uploadPhoto(photo);
  }
}
