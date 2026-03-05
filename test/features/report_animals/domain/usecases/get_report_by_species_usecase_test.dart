import 'package:adoptnest/features/report_animals/domain/usecases/get_report_by_species_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:adoptnest/features/report_animals/domain/repositories/animal_report_repository.dart';

class MockAnimalReportRepository extends Mock implements IAnimalReportRepository {}

final _location = LocationValue(address: 'Kathmandu', lat: 27.7, lng: 85.3);

AnimalReportEntity makeReport(String id) => AnimalReportEntity(
      reportId: id,
      species: 'Cat',
      location: _location,
      imageUrl: '/animal_reports/cat.jpg',
      reportedBy: 'user-1',
      status: AnimalReportStatus.pending,
      createdAt: DateTime(2024, 1, 1),
    );

void main() {
  late MockAnimalReportRepository repository;
  late GetReportsBySpeciesUsecase usecase;

  setUp(() {
    repository = MockAnimalReportRepository();
    usecase = GetReportsBySpeciesUsecase(repository: repository);
  });

  group('GetReportsBySpeciesUsecase', () {
    test('returns list of reports matching species', () async {
      final reports = [makeReport('1'), makeReport('2')];
      when(() => repository.getReportsBySpecies('Cat'))
          .thenAnswer((_) async => Right(reports));

      final result = await usecase(
          const GetReportsBySpeciesParams(species: 'Cat'));

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected success'),
        (list) => expect(list.length, 2),
      );
      verify(() => repository.getReportsBySpecies('Cat')).called(1);
    });

    test('returns empty list when no reports match species', () async {
      when(() => repository.getReportsBySpecies('Dragon'))
          .thenAnswer((_) async => const Right([]));

      final result = await usecase(
          const GetReportsBySpeciesParams(species: 'Dragon'));

      expect(result, const Right<Failure, List<AnimalReportEntity>>([]));
    });

    test('returns NetworkFailure when offline', () async {
      const failure = NetworkFailure();
      when(() => repository.getReportsBySpecies('Cat'))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(
          const GetReportsBySpeciesParams(species: 'Cat'));

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test('passes correct species string to repository', () async {
      when(() => repository.getReportsBySpecies('Dog'))
          .thenAnswer((_) async => const Right([]));

      await usecase(const GetReportsBySpeciesParams(species: 'Dog'));

      verify(() => repository.getReportsBySpecies('Dog')).called(1);
      verifyNever(() => repository.getReportsBySpecies('Cat'));
    });
  });
}