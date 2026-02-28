import 'package:adoptnest/features/adopt/data/models/animal_post_api_model.dart';
import 'package:adoptnest/features/adopt/data/models/animal_post_hive_model.dart';

abstract interface class IAnimalPostLocalDataSource {
  Future<List<AnimalPostHiveModel>> getAllAnimalPosts();
  Future<AnimalPostHiveModel?> getAnimalPostById(String postId);
  Future<void> cachePosts(List<AnimalPostHiveModel> posts);
  Future<void> cachePost(AnimalPostHiveModel post);
}

abstract interface class IAnimalPostRemoteDataSource {
  Future<List<AnimalPostApiModel>> getAllAnimalPosts();
  Future<AnimalPostApiModel?> getAnimalPostById(String postId);
  Future<List<AnimalPostApiModel>> getMyAdoptions();
  Future<void> requestAdoption(String postId);
  Future<void> cancelAdoptionRequest(String postId);
}
