import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/create_animal_report_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/delete_report_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/get_all_reports_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/get_my_report_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/get_report_by_id_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/get_report_by_species_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/update_report_status_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/upload_photo_usecase.dart';
import 'package:adoptnest/features/report_animals/presentation/state/animal_report_state.dart';
import 'package:adoptnest/features/report_animals/presentation/view_model/animal_report_viewmodel.dart';

class MockGetAllReports extends Mock implements GetAllAnimalReportsUsecase {}
class MockGetReportById extends Mock implements GetAnimalReportByIdUsecase {}
class MockGetBySpecies extends Mock implements GetReportsBySpeciesUsecase {}
class MockGetMyReports extends Mock implements GetMyReportsUsecase {}
class MockCreateReport extends Mock implements CreateAnimalReportUsecase {}
class MockUpdateStatus extends Mock implements UpdateReportStatusUsecase {}
class MockDeleteReport extends Mock implements DeleteReportUsecase {}
class MockUploadPhoto extends Mock implements UploadPhotoUsecase {}

// ─── Fake params ─────────────────────────────────────────────────────────────
class FakeGetByIdParams extends Fake implements GetAnimalReportByIdParams {}
class FakeGetBySpeciesParams extends Fake implements GetReportsBySpeciesParams {}
class FakeGetMyReportsParams extends Fake implements GetMyReportsParams {}
class FakeCreateParams extends Fake implements CreateReportParams {}
class FakeUpdateParams extends Fake implements UpdateReportStatusParams {}
class FakeDeleteParams extends Fake implements DeleteReportParams {}
class FakeUploadParams extends Fake implements UploadPhotoParams {}

// ─── Helpers ─────────────────────────────────────────────────────────────────
final _loc = LocationValue(address: 'KTM', lat: 27.7, lng: 85.3);

AnimalReportEntity makeReport({
  String id = 'r1',
  AnimalReportStatus status = AnimalReportStatus.pending,
}) =>
    AnimalReportEntity(
      reportId: id,
      species: 'Cat',
      location: _loc,
      imageUrl: '',
      reportedBy: 'user-1',
      status: status,
      createdAt: DateTime(2024, 1, 1),
    );

ProviderContainer makeContainer({
  required GetAllAnimalReportsUsecase getAll,
  required GetAnimalReportByIdUsecase getById,
  required GetReportsBySpeciesUsecase getBySpecies,
  required GetMyReportsUsecase getMy,
  required CreateAnimalReportUsecase create,
  required UpdateReportStatusUsecase updateStatus,
  required DeleteReportUsecase delete,
  required UploadPhotoUsecase upload,
}) {
  return ProviderContainer(overrides: [
    getAllAnimalReportsUsecaseProvider.overrideWithValue(getAll),
    getAnimalReportByIdUsecaseProvider.overrideWithValue(getById),
    getReportsBySpeciesUsecaseProvider.overrideWithValue(getBySpecies),
    getMyReportsUsecaseProvider.overrideWithValue(getMy),
    createAnimalReportUsecaseProvider.overrideWithValue(create),
    updateReportStatusUsecaseProvider.overrideWithValue(updateStatus),
    deleteReportUsecaseProvider.overrideWithValue(delete),
    uploadPhotoUsecaseProvider.overrideWithValue(upload),
  ]);
}

void main() {
  late MockGetAllReports mockGetAll;
  late MockGetReportById mockGetById;
  late MockGetBySpecies mockGetBySpecies;
  late MockGetMyReports mockGetMy;
  late MockCreateReport mockCreate;
  late MockUpdateStatus mockUpdate;
  late MockDeleteReport mockDelete;
  late MockUploadPhoto mockUpload;

  setUpAll(() {
    registerFallbackValue(FakeGetByIdParams());
    registerFallbackValue(FakeGetBySpeciesParams());
    registerFallbackValue(FakeGetMyReportsParams());
    registerFallbackValue(FakeCreateParams());
    registerFallbackValue(FakeUpdateParams());
    registerFallbackValue(FakeDeleteParams());
    registerFallbackValue(FakeUploadParams());
  });

  setUp(() {
    mockGetAll = MockGetAllReports();
    mockGetById = MockGetReportById();
    mockGetBySpecies = MockGetBySpecies();
    mockGetMy = MockGetMyReports();
    mockCreate = MockCreateReport();
    mockUpdate = MockUpdateStatus();
    mockDelete = MockDeleteReport();
    mockUpload = MockUploadPhoto();
  });

  ProviderContainer container() => makeContainer(
        getAll: mockGetAll,
        getById: mockGetById,
        getBySpecies: mockGetBySpecies,
        getMy: mockGetMy,
        create: mockCreate,
        updateStatus: mockUpdate,
        delete: mockDelete,
        upload: mockUpload,
      );

  // ── getAllReports ──────────────────────────────────────────────────────────
  group('AnimalReportViewModel - getAllReports()', () {
    test('TC-ARVM-01: sets loaded state with reports on success', () async {
      final reports = [makeReport(id: '1'), makeReport(id: '2')];
      when(() => mockGetAll()).thenAnswer((_) async => Right(reports));

      final c = container();
      addTearDown(c.dispose);
      await c.read(animalReportViewModelProvider.notifier).getAllReports();

      final state = c.read(animalReportViewModelProvider);
      expect(state.status, AnimalReportViewStatus.loaded);
      expect(state.reports.length, 2);
    });

    test('TC-ARVM-02: sets error state on failure', () async {
      when(() => mockGetAll())
          .thenAnswer((_) async => Left(ApiFailure(message: 'Server error')));

      final c = container();
      addTearDown(c.dispose);
      await c.read(animalReportViewModelProvider.notifier).getAllReports();

      final state = c.read(animalReportViewModelProvider);
      expect(state.status, AnimalReportViewStatus.error);
      expect(state.errorMessage, 'Server error');
    });
  });

  // ── getReportById ──────────────────────────────────────────────────────────
  group('AnimalReportViewModel - getReportById()', () {
    test('TC-ARVM-03: sets selectedReport on success', () async {
      final report = makeReport(id: 'r-99');
      when(() => mockGetById(any())).thenAnswer((_) async => Right(report));

      final c = container();
      addTearDown(c.dispose);
      await c.read(animalReportViewModelProvider.notifier).getReportById('r-99');

      final state = c.read(animalReportViewModelProvider);
      expect(state.status, AnimalReportViewStatus.loaded);
      expect(state.selectedReport?.reportId, 'r-99');
    });

    test('TC-ARVM-04: sets error when report not found', () async {
      when(() => mockGetById(any()))
          .thenAnswer((_) async => Left(ApiFailure(message: 'Not found')));

      final c = container();
      addTearDown(c.dispose);
      await c.read(animalReportViewModelProvider.notifier).getReportById('bad');

      expect(c.read(animalReportViewModelProvider).status,
          AnimalReportViewStatus.error);
    });
  });

  // ── getMyReports ───────────────────────────────────────────────────────────
  group('AnimalReportViewModel - getMyReports()', () {
    test('TC-ARVM-05: populates myReports on success', () async {
      final reports = [makeReport(id: 'mine-1')];
      when(() => mockGetMy(any())).thenAnswer((_) async => Right(reports));

      final c = container();
      addTearDown(c.dispose);
      await c
          .read(animalReportViewModelProvider.notifier)
          .getMyReports('user-1');

      final state = c.read(animalReportViewModelProvider);
      expect(state.status, AnimalReportViewStatus.loaded);
      expect(state.myReports.first.reportId, 'mine-1');
    });

    test('TC-ARVM-06: sets error on failure', () async {
      when(() => mockGetMy(any()))
          .thenAnswer((_) async => Left(ApiFailure(message: 'Unauthorized')));

      final c = container();
      addTearDown(c.dispose);
      await c
          .read(animalReportViewModelProvider.notifier)
          .getMyReports('user-1');

      expect(c.read(animalReportViewModelProvider).status,
          AnimalReportViewStatus.error);
    });
  });

  // ── createReport ───────────────────────────────────────────────────────────
  group('AnimalReportViewModel - createReport()', () {
    test('TC-ARVM-07: sets created status on success', () async {
      when(() => mockCreate(any()))
          .thenAnswer((_) async => Right<Failure, AnimalReportEntity>(makeReport()));
      // getAllReports is called internally after create
      when(() => mockGetAll()).thenAnswer((_) async => Right<Failure, List<AnimalReportEntity>>([]));

      final c = container();
      addTearDown(c.dispose);
      await c
          .read(animalReportViewModelProvider.notifier)
          .createReport(makeReport());

      // createReport internally calls getAllReports() as an unawaited future.
      // Pump the microtask queue so it completes.
      await Future.delayed(Duration.zero);

      expect(c.read(animalReportViewModelProvider).status,
          AnimalReportViewStatus.loaded); // after getAllReports refresh
    });

    test('TC-ARVM-08: sets error on create failure', () async {
      when(() => mockCreate(any()))
          .thenAnswer((_) async => Left(ApiFailure(message: 'Create failed')));

      final c = container();
      addTearDown(c.dispose);
      await c
          .read(animalReportViewModelProvider.notifier)
          .createReport(makeReport());

      expect(c.read(animalReportViewModelProvider).status,
          AnimalReportViewStatus.error);
    });
  });

  // ── deleteReport ───────────────────────────────────────────────────────────
  group('AnimalReportViewModel - deleteReport()', () {
    test('TC-ARVM-09: sets deleted status and removes from myReports',
        () async {
      when(() => mockDelete(any()))
          .thenAnswer((_) async => Right<Failure, bool>(true));

      final c = container();
      addTearDown(c.dispose);
      // Seed myReports manually via state
      c.read(animalReportViewModelProvider.notifier).state = AnimalReportState(
        myReports: [makeReport(id: 'del-1'), makeReport(id: 'del-2')],
      );

      final result = await c
          .read(animalReportViewModelProvider.notifier)
          .deleteReport('del-1');

      expect(result, isTrue);
      expect(c.read(animalReportViewModelProvider).status,
          AnimalReportViewStatus.deleted);
      expect(
        c.read(animalReportViewModelProvider).myReports
            .any((r) => r.reportId == 'del-1'),
        isFalse,
      );
    });

    test('TC-ARVM-10: returns false and sets error on failure', () async {
      when(() => mockDelete(any()))
          .thenAnswer((_) async => Left(ApiFailure(message: 'Delete failed')));

      final c = container();
      addTearDown(c.dispose);
      final result = await c
          .read(animalReportViewModelProvider.notifier)
          .deleteReport('r1');

      expect(result, isFalse);
      expect(c.read(animalReportViewModelProvider).status,
          AnimalReportViewStatus.error);
    });
  });

  // ── clearSelectedReport / clearError / resetState ─────────────────────────
  group('AnimalReportViewModel - helper methods', () {
    test('TC-ARVM-11: clearSelectedReport removes selectedReport', () async {
      when(() => mockGetById(any()))
          .thenAnswer((_) async => Right(makeReport()));

      final c = container();
      addTearDown(c.dispose);
      await c
          .read(animalReportViewModelProvider.notifier)
          .getReportById('r1');
      expect(c.read(animalReportViewModelProvider).selectedReport, isNotNull);

      c.read(animalReportViewModelProvider.notifier).clearSelectedReport();
      expect(c.read(animalReportViewModelProvider).selectedReport, isNull);
    });

    test('TC-ARVM-12: resetState returns to initial', () async {
      when(() => mockGetAll())
          .thenAnswer((_) async => Right([makeReport()]));

      final c = container();
      addTearDown(c.dispose);
      await c.read(animalReportViewModelProvider.notifier).getAllReports();
      expect(c.read(animalReportViewModelProvider).reports, isNotEmpty);

      c.read(animalReportViewModelProvider.notifier).resetState();
      final state = c.read(animalReportViewModelProvider);
      expect(state.status, AnimalReportViewStatus.initial);
      expect(state.reports, isEmpty);
    });
  });
}