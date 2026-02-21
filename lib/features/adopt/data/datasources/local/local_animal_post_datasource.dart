import 'package:adoptnest/core/services/hive/hive_service.dart';
import 'package:adoptnest/features/adopt/data/datasources/animal_post_datasource.dart';
import 'package:adoptnest/features/adopt/data/models/animal_post_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final animalPostLocalDatasourceProvider =
    Provider<AnimalPostLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return AnimalPostLocalDatasource(hiveService: hiveService);
});

class AnimalPostLocalDatasource implements IAnimalPostLocalDataSource {
  final HiveService _hiveService;

  AnimalPostLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<List<AnimalPostHiveModel>> getAllAnimalPosts() async {
    try {
      return _hiveService.getAllAnimalPosts();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<AnimalPostHiveModel?> getAnimalPostById(String postId) async {
    try {
      return _hiveService.getAnimalPostById(postId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cachePosts(List<AnimalPostHiveModel> posts) async {
    try {
      for (final post in posts) {
        await _hiveService.cacheAnimalPost(post);
      }
    } catch (e) {
      // Silently fail cache
    }
  }

  @override
  Future<void> cachePost(AnimalPostHiveModel post) async {
    try {
      await _hiveService.cacheAnimalPost(post);
    } catch (e) {
      // Silently fail cache
    }
  }
}
