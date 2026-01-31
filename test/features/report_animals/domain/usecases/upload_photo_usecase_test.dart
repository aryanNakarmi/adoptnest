import 'dart:io';
import 'package:adoptnest/features/report_animals/domain/usecases/upload_photo_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/repositories/animal_report_repository.dart';
import 'package:adoptnest/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// 1. Mock Repository
class MockAnimalReportRepository extends Mock implements IAnimalReportRepository {}

void main() {
  late UploadPhotoUsecase usecase;
  late MockAnimalReportRepository mockRepository;

  setUp(() {
    mockRepository = MockAnimalReportRepository();
    usecase = UploadPhotoUsecase(repository: mockRepository);
  });

  final tFile = File('test/assets/sample_photo.jpg'); // can be any dummy file path
  final tParams = UploadPhotoParams(photo: tFile);
  const tUrl = 'https://fakeurl.com/photo.jpg';

  test('should call repository and return URL when upload succeeds', () async {
    // arrange
    when(() => mockRepository.uploadPhoto(tFile))
        .thenAnswer((_) async => const Right(tUrl));

    // act
    final result = await usecase.call(tParams);

    // assert
    expect(result, const Right(tUrl));
    verify(() => mockRepository.uploadPhoto(tFile)).called(1);
  });

  test('should return failure when repository fails', () async {
    // arrange
    final tFailure = NetworkFailure();
    when(() => mockRepository.uploadPhoto(tFile))
        .thenAnswer((_) async => Left(tFailure));

    // act
    final result = await usecase.call(tParams);

    // assert
    expect(result, Left(tFailure));
    verify(() => mockRepository.uploadPhoto(tFile)).called(1);
  });
}
