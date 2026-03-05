import 'package:adoptnest/features/report_animals/domain/usecases/get_report_by_id_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:adoptnest/features/report_animals/domain/repositories/animal_report_repository.dart';

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
  late GetAnimalReportByIdUsecase usecase;

  setUp(() {
    repository = MockAnimalReportRepository();
    usecase = GetAnimalReportByIdUsecase(repository: repository);
  });

  group('GetAnimalReportByIdUsecase', () {
    test('returns report when valid id is provided', () async {
      final report = makeReport();
      when(() => repository.getAnimalReportById('report-1'))
          .thenAnswer((_) async => Right(report));

      final result = await usecase(
          const GetAnimalReportByIdParams(reportId: 'report-1'));

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected success'),
        (r) => expect(r.reportId, 'report-1'),
      );
      verify(() => repository.getAnimalReportById('report-1')).called(1);
    });

    test('returns ApiFailure with 404 when report not found', () async {
      const failure = ApiFailure(message: 'Report not found', statusCode: 404);
      when(() => repository.getAnimalReportById('bad-id'))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(
          const GetAnimalReportByIdParams(reportId: 'bad-id'));

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect((f as ApiFailure).statusCode, 404),
        (_) => fail('Expected failure'),
      );
    });

    test('returns NetworkFailure when offline', () async {
      const failure = NetworkFailure();
      when(() => repository.getAnimalReportById('report-1'))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(
          const GetAnimalReportByIdParams(reportId: 'report-1'));

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected failure'),
      );
    });
  });
}