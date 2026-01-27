import 'dart:io';
import 'package:adoptnest/core/services/hive/hive_service.dart';
import 'package:adoptnest/features/report_animals/data/datasources/animal_report_datasource.dart';
import 'package:adoptnest/features/report_animals/data/models/animal_report_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final animalReportLocalDataSourceProvider =
    Provider<IAnimalReportDataSource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return AnimalReportLocalDataSource(hiveService: hiveService);
});


class AnimalReportLocalDataSource implements IAnimalReportDataSource {
  final HiveService hiveService;

  AnimalReportLocalDataSource({required this.hiveService});

  @override
  Future<List<AnimalReportHiveModel>> getAllAnimalReports() async {
    try {
      return await hiveService.getAllAnimalReports();
    } catch (e) {
      return []; // Return empty list on error
    }
  }

  @override
  Future<AnimalReportHiveModel?> getAnimalReportById(String reportId) async {
    try {
      if (reportId.isEmpty) return null;
      return await hiveService.getAnimalReportById(reportId);
    } catch (e) {
      return null; // Return null on error
    }
  }

  @override
  Future<List<AnimalReportHiveModel>> getReportsBySpecies(
      String species) async {
    try {
      if (species.isEmpty) return [];
      return await hiveService.getReportsBySpecies(species);
    } catch (e) {
      return []; // Return empty list on error
    }
  }

  @override
  Future<List<AnimalReportHiveModel>> getMyReports(String userId) async {
    try {
      if (userId.isEmpty) return [];
      return await hiveService.getMyAnimalReports(userId);
    } catch (e) {
      return []; // Return empty list on error
    }
  }

  @override
  Future<AnimalReportHiveModel?> createAnimalReport(
      AnimalReportHiveModel report) async {
    try {
      if (report.reportId.isEmpty) return null;
      return await hiveService.createAnimalReport(report);
    } catch (e) {
      return null; // Return null on error
    }
  }

  @override
  Future<AnimalReportHiveModel?> updateReportStatus(
      String reportId, String newStatus) async {
    try {
      if (reportId.isEmpty || newStatus.isEmpty) return null;
      
      final success = await hiveService.updateAnimalReportStatus(reportId, newStatus);
      
      if (success) {
        // Return the updated report
        return await hiveService.getAnimalReportById(reportId);
      }
      return null;
    } catch (e) {
      return null; // Return null on error
    }
  }

  @override
  Future<bool> deleteReport(String reportId) async {
    try {
      if (reportId.isEmpty) return false;
      return await hiveService.deleteAnimalReport(reportId);
    } catch (e) {
      return false; // Return false on error
    }
  }

  @override
  Future<String?> uploadPhoto(File photo) async {
    try {
      if (!photo.existsSync()) return null;
      return await hiveService.uploadPhoto(photo);
    } catch (e) {
      return null; // Return null on error
    }
  }
}