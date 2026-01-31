import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/create_animal_report_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:adoptnest/features/report_animals/domain/repositories/animal_report_repository.dart';
import 'package:adoptnest/core/error/failures.dart';

/// Mock repository
class MockAnimalReportRepository extends Mock implements IAnimalReportRepository {}

/// Fake for AnimalReportEntity to use with `any()`
class AnimalReportEntityFake extends Fake implements AnimalReportEntity {}

void main() {
  // Register fallback value for mocktail (required for custom classes)
  setUpAll(() {
    registerFallbackValue(AnimalReportEntityFake());
  });

  late CreateAnimalReportUsecase usecase;
  late MockAnimalReportRepository mockRepository;

  final sampleDate = DateTime.parse("2026-01-31T05:00:00Z");
  // Sample report entity for testing
  final sampleReport = AnimalReportEntity(
    reportId: '1',
    species: 'Dog',
    location: 'Kathmandu',
    description: 'Lost dog near park',
    imageUrl: 'url',
    status: AnimalReportStatus.pending,
    reportedBy: 'user123',
    createdAt: sampleDate,
    updatedAt: sampleDate,
  );

  final params = CreateReportParams(report: sampleReport);

  setUp(() {
    mockRepository = MockAnimalReportRepository();
    usecase = CreateAnimalReportUsecase(repository: mockRepository);
  });

  test('should create a report and return it when repository succeeds', () async {
    // Arrange
    when(() => mockRepository.createAnimalReport(sampleReport))
        .thenAnswer((_) async => Right(sampleReport));

    // Act
    final result = await usecase(params);

    // Assert
    expect(result, Right(sampleReport));
    verify(() => mockRepository.createAnimalReport(sampleReport)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // Arrange
    when(() => mockRepository.createAnimalReport(sampleReport))
        .thenAnswer((_) async => Left(NetworkFailure()));

    // Act
    final result = await usecase(params);

    // Assert
    expect(result, Left(NetworkFailure()));
    verify(() => mockRepository.createAnimalReport(sampleReport)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should call repository with correct parameters using any()', () async {
    // Arrange
    when(() => mockRepository.createAnimalReport(any()))
        .thenAnswer((_) async => Right(sampleReport));

    // Act
    await usecase(params);

    // Assert
    verify(() => mockRepository.createAnimalReport(params.report)).called(1);
  });
}
