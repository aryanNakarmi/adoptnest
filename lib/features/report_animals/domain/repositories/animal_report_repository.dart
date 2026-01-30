import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:adoptnest/core/error/failures.dart';
import '../entities/animal_report_entity.dart';

abstract interface class IAnimalReportRepository {
  // Get all reports
  Future<Either<Failure, List<AnimalReportEntity>>> getAllAnimalReports();

  // Get single report by ID
  Future<Either<Failure, AnimalReportEntity>> getAnimalReportById(String reportId);

  // get current user's reports (dashboard)
  Future<Either<Failure, List<AnimalReportEntity>>> getMyReports(String userId);

  // Create new report 
  Future<Either<Failure, AnimalReportEntity>> createAnimalReport(
    AnimalReportEntity report,  
  );

  // Update report status (pending -> in-progress -> rescued)
  Future<Either<Failure, AnimalReportEntity>> updateReportStatus(
    String reportId,
    String newStatus,
  );

  // Delete report
  Future<Either<Failure, bool>> deleteReport(String reportId);

  // Upload photo 
  Future<Either<Failure, String>> uploadPhoto(File photo);
}