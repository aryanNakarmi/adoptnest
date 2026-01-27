import 'dart:io';

import 'package:adoptnest/features/report_animals/data/models/animal_report_hive_model.dart';


abstract interface class IAnimalReportDataSource {
 
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