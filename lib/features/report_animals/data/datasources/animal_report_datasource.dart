import 'dart:io';

import 'package:adoptnest/features/report_animals/data/models/animal_report_api_model.dart';
import 'package:adoptnest/features/report_animals/data/models/animal_report_hive_model.dart';


abstract interface class IAnimalReportLocalDataSource {
 
  Future<List<AnimalReportHiveModel>> getAllAnimalReports();
  Future<AnimalReportHiveModel?> getAnimalReportById(String reportId);
  Future<List<AnimalReportHiveModel>> getReportsBySpecies(
    String species,
  );
  Future<List<AnimalReportHiveModel>> getMyReports(String userId);
  Future<AnimalReportHiveModel>createAnimalReport(
    AnimalReportHiveModel report,  
  );

  Future<AnimalReportHiveModel?> updateReportStatus(
    String reportId,
    String newStatus,
  );
  Future<bool> deleteReport(String reportId);
  Future<String> uploadPhoto(File photo);
}

abstract interface class IAnimalReportRemoteDataSource {
  Future<List<AnimalReportApiModel>> getAllAnimalReports();
  Future<AnimalReportApiModel?> getAnimalReportById(String reportId);
  Future<List<AnimalReportApiModel>> getReportsBySpecies(String species);
  Future<List<AnimalReportApiModel>> getMyReports();

  Future<AnimalReportApiModel> createAnimalReport(
    AnimalReportApiModel report,
  );

  Future<AnimalReportApiModel?> updateReportStatus(
    String reportId,
    String newStatus,
  );

  Future<bool> deleteReport(String reportId);
  Future<String> uploadPhoto(File photo);
}