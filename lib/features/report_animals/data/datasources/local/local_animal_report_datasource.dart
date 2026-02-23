import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/core/services/hive/hive_service.dart';
import 'package:adoptnest/features/report_animals/data/datasources/animal_report_datasource.dart';
import 'package:adoptnest/features/report_animals/data/models/animal_report_hive_model.dart';

final animalReportLocalDatasourceProvider =
    Provider<AnimalReportLocalDatasource>((ref) {
  return AnimalReportLocalDatasource(hiveService: ref.read(hiveServiceProvider));
});

class AnimalReportLocalDatasource implements IAnimalReportLocalDataSource {
  final HiveService _hiveService;
  AnimalReportLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<AnimalReportHiveModel> createAnimalReport(AnimalReportHiveModel report) async {
    try {
      return await _hiveService.createAnimalReport(report);
    } catch (e) {
      throw Exception('Failed to create animal report');
    }
  }

  @override
  Future<bool> deleteReport(String reportId) async {
    try {
      await _hiveService.deleteAnimalReport(reportId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<AnimalReportHiveModel>> getAllAnimalReports() async {
    try {
      return _hiveService.getAllAnimalReports();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<AnimalReportHiveModel?> getAnimalReportById(String reportId) async {
    try {
      return _hiveService.getAnimalReportById(reportId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<AnimalReportHiveModel>> getMyReports(String userId) async {
    try {
      return _hiveService.getMyAnimalReports(userId);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<AnimalReportHiveModel>> getReportsBySpecies(String species) async {
    try {
      return _hiveService.getReportsBySpecies(species);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<AnimalReportHiveModel?> updateReportStatus(String reportId, String newStatus) async {
    try {
      final success = await _hiveService.updateAnimalReportStatus(reportId, newStatus);
      if (!success) return null;
      return _hiveService.getAnimalReportById(reportId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> uploadPhoto(File photo) async {
    try {
      return await _hiveService.uploadPhoto(photo);
    } catch (e) {
      throw Exception('Photo upload failed');
    }
  }
}
