import 'package:adoptnest/core/api/api_client.dart';
import 'package:adoptnest/core/api/api_endpoints.dart';
import 'package:adoptnest/features/adopt/data/datasources/animal_post_datasource.dart';
import 'package:adoptnest/features/adopt/data/models/animal_post_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final animalPostRemoteDatasourceProvider =
    Provider<AnimalPostRemoteDatasource>((ref) {
  return AnimalPostRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
  );
});

class AnimalPostRemoteDatasource implements IAnimalPostRemoteDataSource {
  final ApiClient _apiClient;

  AnimalPostRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<AnimalPostApiModel>> getAllAnimalPosts() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.allAnimalPosts);
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data
            .map((e) => AnimalPostApiModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<AnimalPostApiModel?> getAnimalPostById(String postId) async {
    try {
      final response =
          await _apiClient.get(ApiEndpoints.animalPostById(postId));
      if (response.data['success'] == true) {
        return AnimalPostApiModel.fromJson(response.data['data']);
      }
      return null;
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<List<AnimalPostApiModel>> getMyAdoptions() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.myAdoptions);
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data
            .map((e) => AnimalPostApiModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }
}
