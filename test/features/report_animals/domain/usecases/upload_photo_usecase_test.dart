import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/features/report_animals/domain/repositories/animal_report_repository.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/upload_photo_usecase.dart';

class MockAnimalReportRepository extends Mock implements IAnimalReportRepository {}
class MockFile extends Mock implements File {}

void main() {
  late MockAnimalReportRepository repository;
  late UploadPhotoUsecase usecase;
  late MockFile mockFile;

  setUp(() {
    repository = MockAnimalReportRepository();
    usecase = UploadPhotoUsecase(repository: repository);
    mockFile = MockFile();
  });

  group('UploadPhotoUsecase', () {
    test('returns image URL string on successful upload', () async {
      when(() => repository.uploadPhoto(mockFile))
          .thenAnswer((_) async => const Right('/animal_reports/cat.jpg'));

      final result = await usecase(UploadPhotoParams(photo: mockFile));

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected success'),
        (url) => expect(url, '/animal_reports/cat.jpg'),
      );
      verify(() => repository.uploadPhoto(mockFile)).called(1);
    });

    test('returns ApiFailure when upload fails', () async {
      const failure = ApiFailure(message: 'Upload failed', statusCode: 500);
      when(() => repository.uploadPhoto(mockFile))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(UploadPhotoParams(photo: mockFile));

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f.message, 'Upload failed'),
        (_) => fail('Expected failure'),
      );
    });

    test('returns NetworkFailure when offline', () async {
      const failure = NetworkFailure();
      when(() => repository.uploadPhoto(mockFile))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(UploadPhotoParams(photo: mockFile));

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test('passes correct file to repository', () async {
      final anotherFile = MockFile();
      when(() => repository.uploadPhoto(anotherFile))
          .thenAnswer((_) async => const Right('/animal_reports/dog.jpg'));

      await usecase(UploadPhotoParams(photo: anotherFile));

      verify(() => repository.uploadPhoto(anotherFile)).called(1);
      verifyNever(() => repository.uploadPhoto(mockFile));
    });
  });
}