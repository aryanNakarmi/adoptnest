import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:adoptnest/core/error/failures.dart';
import '../entities/animal_report_entity.dart';

abstract interface class IAnimalReportRepository {
  Future<Either<Failure, List<AnimalReportEntity>>> getAllAnimalReports();
  Future<Either<Failure, AnimalReportEntity>> getAnimalReportById(String reportId);
  Future<Either<Failure, List<AnimalReportEntity>>> getReportsBySpecies(String species);
  Future<Either<Failure, List<AnimalReportEntity>>> getMyReports(String userId);
  Future<Either<Failure, AnimalReportEntity>> createAnimalReport(AnimalReportEntity report);
  Future<Either<Failure, AnimalReportEntity>> updateReportStatus(String reportId, String newStatus);
  Future<Either<Failure, bool>> deleteReport(String reportId);
  Future<Either<Failure, String>> uploadPhoto(File photo);
}
