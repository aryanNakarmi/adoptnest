import 'dart:io';

import 'package:adoptnest/core/api/api_client.dart';
import 'package:adoptnest/core/api/api_endpoints.dart';
import 'package:adoptnest/core/services/storage/token_service.dart';
import 'package:adoptnest/features/report_animals/data/datasources/animal_report_datasource.dart';
import 'package:adoptnest/features/report_animals/data/models/animal_report_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final animalReportRemoteDatasourceProvider =
    Provider<AnimalReportRemoteDatasource>((ref) {
  return AnimalReportRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AnimalReportRemoteDatasource implements IAnimalReportRemoteDataSource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  AnimalReportRemoteDatasource({required ApiClient apiClient,
  required TokenService tokenService})
      : _apiClient = apiClient,
        _tokenService = tokenService
      ;

  @override
  Future<List<AnimalReportApiModel>> getAllAnimalReports() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.allReports);
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data
            .map((e) => AnimalReportApiModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<AnimalReportApiModel?> getAnimalReportById(String reportId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.reportById(reportId));
      if (response.data['success'] == true) {
        return AnimalReportApiModel.fromJson(response.data['data']);
      }
      return null;
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<List<AnimalReportApiModel>> getReportsBySpecies(String species) async {
    try {
      final response = await _apiClient.get('/reports/species/$species');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data
            .map((e) => AnimalReportApiModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<List<AnimalReportApiModel>> getMyReports() async {
    try {
      final response = await _apiClient.get('/reports/my-reports');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data
            .map((e) => AnimalReportApiModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<AnimalReportApiModel> createAnimalReport(
      AnimalReportApiModel report) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.createReport,
        data: report.toJson(),
      );
      if (response.data['success'] == true) {
        return AnimalReportApiModel.fromJson(response.data['data']);
      }
      return report;
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<AnimalReportApiModel?> updateReportStatus(
      String reportId, String newStatus) async {
    try {
      final response = await _apiClient.put(
        '/reports/$reportId/status',
        data: {'status': newStatus},
      );
      if (response.data['success'] == true) {
        return AnimalReportApiModel.fromJson(response.data['data']);
      }
      return null;
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<bool> deleteReport(String reportId) async {
    try {
      final response =
          await _apiClient.delete(ApiEndpoints.reportById(reportId));
      return response.data['success'] == true;
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<String> uploadPhoto(File photo) async {
    try {
      final formData = FormData.fromMap({
        'animalReport': await MultipartFile.fromFile(
          photo.path,
          filename: photo.path.split('/').last,
        ),
      });

      final response = await _apiClient.uploadFile(
        ApiEndpoints.uploadReportImage,
        formData: formData,
      );

      if (response.data['success'] == true) {
        return response.data['data'] as String;
      }
      return '';
    } on DioException {
      rethrow;
    }
  }
}