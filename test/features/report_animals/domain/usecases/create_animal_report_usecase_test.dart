import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:adoptnest/features/report_animals/domain/repositories/animal_report_repository.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/create_animal_report_usecase.dart';

class MockAnimalReportRepository extends Mock implements IAnimalReportRepository {}

final _location = LocationValue(address: 'Kathmandu', lat: 27.7, lng: 85.3);

AnimalReportEntity makeReport() => AnimalReportEntity(
      reportId: 'report-1',
      species: 'Cat',
      location: _location,
      imageUrl: '/animal_reports/cat.jpg',
      reportedBy: 'user-1',
      status: AnimalReportStatus.pending,
      createdAt: DateTime(2024, 1, 1),
    );

void main() {
  late MockAnimalReportRepository repository;
  late CreateAnimalReportUsecase usecase;

  setUp(() {
    repository = MockAnimalReportRepository();
    usecase = CreateAnimalReportUsecase(repository: repository);
  });

  group('CreateAnimalReportUsecase', () {
    test('returns created report on success', () async {
      final report = makeReport();
      when(() => repository.createAnimalReport(report))
          .thenAnswer((_) async => Right(report));

      final result = await usecase(CreateReportParams(report: report));

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected success'),
        (r) => expect(r.species, 'Cat'),
      );
      verify(() => repository.createAnimalReport(report)).called(1);
    });

    test('returns ApiFailure when report creation fails', () async {
      final report = makeReport();
      const failure = ApiFailure(message: 'Failed to create report', statusCode: 500);
      when(() => repository.createAnimalReport(report))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(CreateReportParams(report: report));

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f.message, 'Failed to create report'),
        (_) => fail('Expected failure'),
      );
    });

    test('returns NetworkFailure when offline', () async {
      final report = makeReport();
      const failure = NetworkFailure();
      when(() => repository.createAnimalReport(report))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(CreateReportParams(report: report));

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected failure'),
      );
    });
  });
}