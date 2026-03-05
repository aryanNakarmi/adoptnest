import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:adoptnest/features/report_animals/domain/repositories/animal_report_repository.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/update_report_status_usecase.dart';

class MockAnimalReportRepository extends Mock implements IAnimalReportRepository {}

final _location = LocationValue(address: 'Kathmandu', lat: 27.7, lng: 85.3);

AnimalReportEntity makeReport({AnimalReportStatus status = AnimalReportStatus.pending}) =>
    AnimalReportEntity(
      reportId: 'report-1',
      species: 'Cat',
      location: _location,
      imageUrl: '/animal_reports/cat.jpg',
      reportedBy: 'user-1',
      status: status,
      createdAt: DateTime(2024, 1, 1),
    );

void main() {
  late MockAnimalReportRepository repository;
  late UpdateReportStatusUsecase usecase;

  setUp(() {
    repository = MockAnimalReportRepository();
    usecase = UpdateReportStatusUsecase(repository: repository);
  });

  group('UpdateReportStatusUsecase', () {
    test('returns updated report with approved status', () async {
      final updated = makeReport(status: AnimalReportStatus.approved);
      when(() => repository.updateReportStatus('report-1', 'approved'))
          .thenAnswer((_) async => Right(updated));

      final result = await usecase(const UpdateReportStatusParams(
        reportId: 'report-1',
        newStatus: AnimalReportStatus.approved,
      ));

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected success'),
        (r) => expect(r.status, AnimalReportStatus.approved),
      );
    });

    test('returns updated report with rejected status', () async {
      final updated = makeReport(status: AnimalReportStatus.rejected);
      when(() => repository.updateReportStatus('report-1', 'rejected'))
          .thenAnswer((_) async => Right(updated));

      final result = await usecase(const UpdateReportStatusParams(
        reportId: 'report-1',
        newStatus: AnimalReportStatus.rejected,
      ));

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected success'),
        (r) => expect(r.status, AnimalReportStatus.rejected),
      );
    });

    test('returns ApiFailure when report not found', () async {
      const failure = ApiFailure(message: 'Report not found', statusCode: 404);
      when(() => repository.updateReportStatus('bad-id', 'approved'))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(const UpdateReportStatusParams(
        reportId: 'bad-id',
        newStatus: AnimalReportStatus.approved,
      ));

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect((f as ApiFailure).statusCode, 404),
        (_) => fail('Expected failure'),
      );
    });

    test('returns NetworkFailure when offline', () async {
      const failure = NetworkFailure();
      when(() => repository.updateReportStatus('report-1', 'approved'))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(const UpdateReportStatusParams(
        reportId: 'report-1',
        newStatus: AnimalReportStatus.approved,
      ));

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected failure'),
      );
    });
  });
}