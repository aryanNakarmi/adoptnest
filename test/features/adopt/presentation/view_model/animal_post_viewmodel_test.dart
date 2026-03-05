import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/features/adopt/domain/entities/animal_post_entity.dart';
import 'package:adoptnest/features/adopt/domain/usecases/cancel_adoption_request_usecase.dart';
import 'package:adoptnest/features/adopt/domain/usecases/get_all_animal_posts_usecase.dart';
import 'package:adoptnest/features/adopt/domain/usecases/get_animal_post_by_id_usecase.dart';
import 'package:adoptnest/features/adopt/domain/usecases/get_my_adoptions_usecase.dart';
import 'package:adoptnest/features/adopt/domain/usecases/request_adoption_usecase.dart';
import 'package:adoptnest/features/adopt/presentation/state/animal_post_state.dart';
import 'package:adoptnest/features/adopt/presentation/view_model/animal_post_viewmodel.dart';

// ─── Mocks ────────────────────────────────────────────────────────────────────
class MockGetAllPosts extends Mock implements GetAllAnimalPostsUsecase {}
class MockGetPostById extends Mock implements GetAnimalPostByIdUsecase {}
class MockGetMyAdoptions extends Mock implements GetMyAdoptionsUsecase {}
class MockRequestAdoption extends Mock implements RequestAdoptionUsecase {}
class MockCancelAdoption extends Mock implements CancelAdoptionRequestUsecase {}

// ─── Fake params ─────────────────────────────────────────────────────────────
class FakeGetByIdParams extends Fake implements GetAnimalPostByIdParams {}
class FakeRequestParams extends Fake implements RequestAdoptionParams {}
class FakeCancelParams extends Fake implements CancelAdoptionRequestParams {}

// ─── Helper ──────────────────────────────────────────────────────────────────
AnimalPostEntity makePost({String id = 'post-1', String species = 'Dog'}) =>
    AnimalPostEntity(
      postId: id,
      species: species,
      gender: 'Male',
      breed: 'Labrador',
      age: 2,
      location: 'Kathmandu',
      photos: const [],
      status: AnimalPostStatus.available,
      createdAt: DateTime(2024, 1, 1),
    );

ProviderContainer makeContainer({
  required GetAllAnimalPostsUsecase getAll,
  required GetAnimalPostByIdUsecase getById,
  required GetMyAdoptionsUsecase getMy,
  required RequestAdoptionUsecase request,
  required CancelAdoptionRequestUsecase cancel,
}) {
  return ProviderContainer(overrides: [
    getAllAnimalPostsUsecaseProvider.overrideWithValue(getAll),
    getAnimalPostByIdUsecaseProvider.overrideWithValue(getById),
    getMyAdoptionsUsecaseProvider.overrideWithValue(getMy),
    requestAdoptionUsecaseProvider.overrideWithValue(request),
    cancelAdoptionRequestUsecaseProvider.overrideWithValue(cancel),
  ]);
}

void main() {
  late MockGetAllPosts mockGetAll;
  late MockGetPostById mockGetById;
  late MockGetMyAdoptions mockGetMy;
  late MockRequestAdoption mockRequest;
  late MockCancelAdoption mockCancel;

  setUpAll(() {
    registerFallbackValue(FakeGetByIdParams());
    registerFallbackValue(FakeRequestParams());
    registerFallbackValue(FakeCancelParams());
  });

  setUp(() {
    mockGetAll = MockGetAllPosts();
    mockGetById = MockGetPostById();
    mockGetMy = MockGetMyAdoptions();
    mockRequest = MockRequestAdoption();
    mockCancel = MockCancelAdoption();
  });

  ProviderContainer container() => makeContainer(
        getAll: mockGetAll,
        getById: mockGetById,
        getMy: mockGetMy,
        request: mockRequest,
        cancel: mockCancel,
      );

  // ── getAllPosts ────────────────────────────────────────────────────────────
  group('AnimalPostViewModel - getAllPosts()', () {
    test('TC-APVM-01: sets loaded state with posts on success', () async {
      final posts = [makePost(id: 'p1'), makePost(id: 'p2', species: 'Cat')];
      when(() => mockGetAll()).thenAnswer((_) async => Right(posts));

      final c = container();
      addTearDown(c.dispose);
      await c.read(animalPostViewModelProvider.notifier).getAllPosts();

      final state = c.read(animalPostViewModelProvider);
      expect(state.status, AnimalPostViewStatus.loaded);
      expect(state.posts.length, 2);
    });

    test('TC-APVM-02: sets error on failure', () async {
      when(() => mockGetAll())
          .thenAnswer((_) async => Left(ApiFailure(message: 'Server down')));

      final c = container();
      addTearDown(c.dispose);
      await c.read(animalPostViewModelProvider.notifier).getAllPosts();

      final state = c.read(animalPostViewModelProvider);
      expect(state.status, AnimalPostViewStatus.error);
      expect(state.errorMessage, 'Server down');
    });
  });

  // ── getPostById ───────────────────────────────────────────────────────────
  group('AnimalPostViewModel - getPostById()', () {
    test('TC-APVM-03: sets selectedPost on success', () async {
      final post = makePost(id: 'p-99');
      when(() => mockGetById(any())).thenAnswer((_) async => Right(post));

      final c = container();
      addTearDown(c.dispose);
      await c.read(animalPostViewModelProvider.notifier).getPostById('p-99');

      expect(c.read(animalPostViewModelProvider).selectedPost?.postId, 'p-99');
    });

    test('TC-APVM-04: sets error when post not found', () async {
      when(() => mockGetById(any()))
          .thenAnswer((_) async => Left(ApiFailure(message: 'Not found')));

      final c = container();
      addTearDown(c.dispose);
      await c.read(animalPostViewModelProvider.notifier).getPostById('bad');

      expect(c.read(animalPostViewModelProvider).status,
          AnimalPostViewStatus.error);
    });
  });

  // ── getMyAdoptions ────────────────────────────────────────────────────────
  group('AnimalPostViewModel - getMyAdoptions()', () {
    test('TC-APVM-05: populates myAdoptions on success', () async {
      final adoptions = [makePost(id: 'adopt-1')];
      when(() => mockGetMy()).thenAnswer((_) async => Right(adoptions));

      final c = container();
      addTearDown(c.dispose);
      await c.read(animalPostViewModelProvider.notifier).getMyAdoptions();

      expect(c.read(animalPostViewModelProvider).myAdoptions.length, 1);
    });

    test('TC-APVM-06: sets error on failure', () async {
      when(() => mockGetMy())
          .thenAnswer((_) async => Left(ApiFailure(message: 'Unauthorized')));

      final c = container();
      addTearDown(c.dispose);
      await c.read(animalPostViewModelProvider.notifier).getMyAdoptions();

      expect(c.read(animalPostViewModelProvider).status,
          AnimalPostViewStatus.error);
    });
  });

  // ── requestAdoption ───────────────────────────────────────────────────────
  group('AnimalPostViewModel - requestAdoption()', () {
    test('TC-APVM-07: sets requestSent and hasRequested=true on success',
        () async {
      when(() => mockRequest(any()))
          .thenAnswer((_) async => Right<Failure, void>(null));
      // getPostById is called internally after request
      when(() => mockGetById(any()))
          .thenAnswer((_) async => Right(makePost()));

      final c = container();
      addTearDown(c.dispose);
      final result = await c
          .read(animalPostViewModelProvider.notifier)
          .requestAdoption('post-1');

      expect(result, isTrue);
      expect(c.read(animalPostViewModelProvider).hasRequested, isTrue);
      expect(c.read(animalPostViewModelProvider).status,
          AnimalPostViewStatus.requestSent);
    });

    test('TC-APVM-08: returns false and sets error on failure', () async {
      when(() => mockRequest(any()))
          .thenAnswer((_) async => Left(ApiFailure(message: 'Already requested')));

      final c = container();
      addTearDown(c.dispose);
      final result = await c
          .read(animalPostViewModelProvider.notifier)
          .requestAdoption('post-1');

      expect(result, isFalse);
      expect(c.read(animalPostViewModelProvider).errorMessage,
          'Already requested');
    });
  });

  // ── cancelAdoptionRequest ─────────────────────────────────────────────────
  group('AnimalPostViewModel - cancelAdoptionRequest()', () {
    test('TC-APVM-09: sets requestCancelled and hasRequested=false on success',
        () async {
      when(() => mockCancel(any()))
          .thenAnswer((_) async => Right<Failure, void>(null));
      when(() => mockGetById(any()))
          .thenAnswer((_) async => Right(makePost()));

      final c = container();
      addTearDown(c.dispose);
      final result = await c
          .read(animalPostViewModelProvider.notifier)
          .cancelAdoptionRequest('post-1');

      expect(result, isTrue);
      expect(c.read(animalPostViewModelProvider).hasRequested, isFalse);
      expect(c.read(animalPostViewModelProvider).status,
          AnimalPostViewStatus.requestCancelled);
    });

    test('TC-APVM-10: returns false and sets error on failure', () async {
      when(() => mockCancel(any()))
          .thenAnswer((_) async => Left(ApiFailure(message: 'Not found')));

      final c = container();
      addTearDown(c.dispose);
      final result = await c
          .read(animalPostViewModelProvider.notifier)
          .cancelAdoptionRequest('post-1');

      expect(result, isFalse);
      expect(c.read(animalPostViewModelProvider).errorMessage, 'Not found');
    });
  });

  // ── filters ───────────────────────────────────────────────────────────────
  group('AnimalPostViewModel - filter methods', () {
    test('TC-APVM-11: setSpeciesFilter filters posts correctly', () async {
      final posts = [
        makePost(id: 'p1', species: 'Dog'),
        makePost(id: 'p2', species: 'Cat'),
        makePost(id: 'p3', species: 'Dog'),
      ];
      when(() => mockGetAll()).thenAnswer((_) async => Right(posts));

      final c = container();
      addTearDown(c.dispose);
      await c.read(animalPostViewModelProvider.notifier).getAllPosts();
      c.read(animalPostViewModelProvider.notifier).setSpeciesFilter('Dog');

      final filtered =
          c.read(animalPostViewModelProvider).filteredPosts;
      expect(filtered.length, 2);
      expect(filtered.every((p) => p.species == 'Dog'), isTrue);
    });

    test('TC-APVM-12: clearFilters resets all filters to All', () async {
      final c = container();
      addTearDown(c.dispose);
      c.read(animalPostViewModelProvider.notifier).setSpeciesFilter('Cat');
      c.read(animalPostViewModelProvider.notifier).setGenderFilter('Female');

      c.read(animalPostViewModelProvider.notifier).clearFilters();

      final state = c.read(animalPostViewModelProvider);
      expect(state.speciesFilter, 'All');
      expect(state.genderFilter, 'All');
    });
  });
}