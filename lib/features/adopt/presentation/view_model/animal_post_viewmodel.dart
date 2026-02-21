import 'package:adoptnest/features/adopt/domain/usecases/get_all_animal_posts_usecase.dart';
import 'package:adoptnest/features/adopt/domain/usecases/get_animal_post_by_id_usecase.dart';
import 'package:adoptnest/features/adopt/domain/usecases/get_my_adoptions_usecase.dart';
import 'package:adoptnest/features/adopt/presentation/state/animal_post_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final animalPostViewModelProvider =
    NotifierProvider<AnimalPostViewModel, AnimalPostState>(
  AnimalPostViewModel.new,
);

class AnimalPostViewModel extends Notifier<AnimalPostState> {
  late final GetAllAnimalPostsUsecase _getAllPostsUsecase;
  late final GetAnimalPostByIdUsecase _getPostByIdUsecase;
  late final GetMyAdoptionsUsecase _getMyAdoptionsUsecase;

  @override
  AnimalPostState build() {
    _getAllPostsUsecase = ref.read(getAllAnimalPostsUsecaseProvider);
    _getPostByIdUsecase = ref.read(getAnimalPostByIdUsecaseProvider);
    _getMyAdoptionsUsecase = ref.read(getMyAdoptionsUsecaseProvider);
    return const AnimalPostState();
  }

  Future<void> getAllPosts() async {
    state = state.copyWith(status: AnimalPostViewStatus.loading);
    final result = await _getAllPostsUsecase();
    result.fold(
      (failure) => state = state.copyWith(
        status: AnimalPostViewStatus.error,
        errorMessage: failure.message,
      ),
      (posts) => state = state.copyWith(
        status: AnimalPostViewStatus.loaded,
        posts: posts,
      ),
    );
  }

  Future<void> getPostById(String postId) async {
    state = state.copyWith(status: AnimalPostViewStatus.loading);
    final result = await _getPostByIdUsecase(
      GetAnimalPostByIdParams(postId: postId),
    );
    result.fold(
      (failure) => state = state.copyWith(
        status: AnimalPostViewStatus.error,
        errorMessage: failure.message,
      ),
      (post) => state = state.copyWith(
        status: AnimalPostViewStatus.loaded,
        selectedPost: post,
      ),
    );
  }

  Future<void> getMyAdoptions() async {
    state = state.copyWith(status: AnimalPostViewStatus.loading);
    final result = await _getMyAdoptionsUsecase();
    result.fold(
      (failure) => state = state.copyWith(
        status: AnimalPostViewStatus.error,
        errorMessage: failure.message,
      ),
      (adoptions) => state = state.copyWith(
        status: AnimalPostViewStatus.loaded,
        myAdoptions: adoptions,
      ),
    );
  }

  // Filter methods
  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);

  void setSpeciesFilter(String species) =>
      state = state.copyWith(speciesFilter: species);

  void setGenderFilter(String gender) =>
      state = state.copyWith(genderFilter: gender);

  void setStatusFilter(String status) =>
      state = state.copyWith(statusFilter: status);

  void clearFilters() => state = state.copyWith(
        searchQuery: '',
        speciesFilter: 'All',
        genderFilter: 'All',
        statusFilter: 'All',
      );

  void clearSelectedPost() => state = state.copyWith(resetSelectedPost: true);
}
