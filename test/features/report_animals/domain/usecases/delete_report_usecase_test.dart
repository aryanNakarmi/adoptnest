import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/features/report_animals/domain/repositories/animal_report_repository.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/delete_report_usecase.dart';

class MockAnimalReportRepository extends Mock implements IAnimalReportRepository {}

void main() {
  late MockAnimalReportRepository repository;
  late DeleteReportUsecase usecase;

  setUp(() {
    repository = MockAnimalReportRepository();
    usecase = DeleteReportUsecase(repository: repository);
  });

  group('DeleteReportUsecase', () {
    test('returns true on successful deletion', () async {
      when(() => repository.deleteReport('report-1'))
          .thenAnswer((_) async => const Right(true));

      final result =
          await usecase(const DeleteReportParams(reportId: 'report-1'));

      expect(result, const Right<Failure, bool>(true));
      verify(() => repository.deleteReport('report-1')).called(1);
    });

    test('returns ApiFailure with 404 when report not found', () async {
      const failure = ApiFailure(message: 'Report not found', statusCode: 404);
      when(() => repository.deleteReport('bad-id'))
          .thenAnswer((_) async => const Left(failure));

      final result =
          await usecase(const DeleteReportParams(reportId: 'bad-id'));

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect((f as ApiFailure).statusCode, 404),
        (_) => fail('Expected failure'),
      );
    });

    test('returns ApiFailure with 403 when not authorized', () async {
      const failure =
          ApiFailure(message: 'Not authorized to delete', statusCode: 403);
      when(() => repository.deleteReport('report-1'))
          .thenAnswer((_) async => const Left(failure));

      final result =
          await usecase(const DeleteReportParams(reportId: 'report-1'));

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect((f as ApiFailure).statusCode, 403),
        (_) => fail('Expected failure'),
      );
    });

    test('returns NetworkFailure when offline', () async {
      const failure = NetworkFailure();
      when(() => repository.deleteReport('report-1'))
          .thenAnswer((_) async => const Left(failure));

      final result =
          await usecase(const DeleteReportParams(reportId: 'report-1'));

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected failure'),
      );
    });
  });
}