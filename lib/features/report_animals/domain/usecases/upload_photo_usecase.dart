import 'dart:io';
import 'package:adoptnest/core/usecases/app_usecase.dart';
import 'package:adoptnest/features/report_animals/data/repositories/animal_report_repository.dart';
import 'package:adoptnest/features/report_animals/domain/repositories/animal_report_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/core/error/failures.dart';


class UploadPhotoParams extends Equatable {
  final File photo;
  const UploadPhotoParams({required this.photo});

  @override
  List<Object?> get props => [photo.path];
}

final uploadPhotoUsecaseProvider = Provider<UploadPhotoUsecase>((ref) {
  final repository = ref.read(animalReportRepositoryProvider);
  return UploadPhotoUsecase(repository: repository);
});


class UploadPhotoUsecase
    implements UsecaseWithParams<String, UploadPhotoParams> {
  final IAnimalReportRepository _repository;

  UploadPhotoUsecase({required IAnimalReportRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, String>> call(UploadPhotoParams params) {
    return _repository.uploadPhoto(params.photo);
  }
}