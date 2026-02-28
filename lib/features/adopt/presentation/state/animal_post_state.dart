import 'package:equatable/equatable.dart';
import 'package:adoptnest/features/adopt/domain/entities/animal_post_entity.dart';

enum AnimalPostViewStatus {
  initial,
  loading,
  loaded,
  error,
  requestSent,
  requestCancelled,
}

class AnimalPostState extends Equatable {
  final AnimalPostViewStatus status;
  final List<AnimalPostEntity> posts;
  final List<AnimalPostEntity> myAdoptions;
  final AnimalPostEntity? selectedPost;
  final String? errorMessage;
  final bool hasRequested;
  final bool isRequestLoading;

  // Local filter state
  final String searchQuery;
  final String speciesFilter;
  final String genderFilter;
  final String statusFilter;

  const AnimalPostState({
    this.status = AnimalPostViewStatus.initial,
    this.posts = const [],
    this.myAdoptions = const [],
    this.selectedPost,
    this.errorMessage,
    this.hasRequested = false,
    this.isRequestLoading = false,
    this.searchQuery = '',
    this.speciesFilter = 'All',
    this.genderFilter = 'All',
    this.statusFilter = 'All',
  });

  List<AnimalPostEntity> get filteredPosts {
    List<AnimalPostEntity> result = [...posts];

    if (speciesFilter != 'All') {
      result = result
          .where((p) => p.species.toLowerCase() == speciesFilter.toLowerCase())
          .toList();
    }
    if (genderFilter != 'All') {
      result = result
          .where((p) => p.gender.toLowerCase() == genderFilter.toLowerCase())
          .toList();
    }
    if (statusFilter != 'All') {
      result = result
          .where((p) =>
              p.status.name.toLowerCase() == statusFilter.toLowerCase())
          .toList();
    }
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((p) {
        return [
          p.postId ?? '',
          p.breed,
          p.species,
          p.gender,
          p.location,
          p.description ?? '',
        ].any((field) => field.toLowerCase().contains(q));
      }).toList();
    }

    return result;
  }

  List<String> get availableSpecies {
    final species = posts.map((p) => p.species.trim()).toSet().toList();
    species.sort();
    return ['All', ...species];
  }

  AnimalPostState copyWith({
    AnimalPostViewStatus? status,
    List<AnimalPostEntity>? posts,
    List<AnimalPostEntity>? myAdoptions,
    AnimalPostEntity? selectedPost,
    bool resetSelectedPost = false,
    String? errorMessage,
    bool resetErrorMessage = false,
    bool? hasRequested,
    bool? isRequestLoading,
    String? searchQuery,
    String? speciesFilter,
    String? genderFilter,
    String? statusFilter,
  }) {
    return AnimalPostState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      myAdoptions: myAdoptions ?? this.myAdoptions,
      selectedPost:
          resetSelectedPost ? null : (selectedPost ?? this.selectedPost),
      errorMessage:
          resetErrorMessage ? null : (errorMessage ?? this.errorMessage),
      hasRequested: hasRequested ?? this.hasRequested,
      isRequestLoading: isRequestLoading ?? this.isRequestLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      speciesFilter: speciesFilter ?? this.speciesFilter,
      genderFilter: genderFilter ?? this.genderFilter,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  @override
  List<Object?> get props => [
        status,
        posts,
        myAdoptions,
        selectedPost,
        errorMessage,
        hasRequested,
        isRequestLoading,
        searchQuery,
        speciesFilter,
        genderFilter,
        statusFilter,
      ];
}
