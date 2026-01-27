import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/features/report_animals/data/datasources/local/local_animal_report_datasource.dart';
import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:adoptnest/features/report_animals/domain/repositories/animal_report_repository.dart';
import 'package:adoptnest/features/report_animals/data/models/animal_report_hive_model.dart';

final animalReportRepositoryProvider =
    Provider<IAnimalReportRepository>((ref) {
  final localDataSource = ref.read(animalReportLocalDatasourceProvider);
  return AnimalReportRepository(localDataSource: localDataSource);
});

class AnimalReportRepository implements IAnimalReportRepository {
  final AnimalReportLocalDatasource _localDataSource;

  AnimalReportRepository({required AnimalReportLocalDatasource localDataSource})
      : _localDataSource = localDataSource;

  // ================= Get All Reports =================
  @override
  Future<Either<Failure, List<AnimalReportEntity>>> getAllAnimalReports() async {
    try {
      final reports = await _localDataSource.getAllAnimalReports();
      return Right(reports.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to fetch reports'));
    }
  }

  // ================= Get Report By ID =================
  @override
  Future<Either<Failure, AnimalReportEntity>> getAnimalReportById(
      String reportId) async {
    try {
      final report = await _localDataSource.getAnimalReportById(reportId);
      if (report == null) {
        return Left(LocalDatabaseFailure(message: 'Report not found'));
      }
      return Right(report.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to fetch report'));
    }
  }

  // ================= Get Reports By Species =================
  @override
  Future<Either<Failure, List<AnimalReportEntity>>> getReportsBySpecies(
      String species) async {
    try {
      final reports = await _localDataSource.getReportsBySpecies(species);
      return Right(reports.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to filter reports'));
    }
  }

  // ================= Get My Reports =================
  @override
  Future<Either<Failure, List<AnimalReportEntity>>> getMyReports(
      String userId) async {
    try {
      final reports = await _localDataSource.getMyReports(userId);
      return Right(reports.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to fetch user reports'));
    }
  }

  // ================= Create Report =================
  @override
  Future<Either<Failure, AnimalReportEntity>> createAnimalReport(
      AnimalReportEntity report) async {
    try {
      final hiveModel = AnimalReportHiveModel.fromEntity(report);
      final created = await _localDataSource.createAnimalReport(hiveModel);
      return Right(created.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to create report'));
    }
  }

  // ================= Update Status =================
  @override
  Future<Either<Failure, AnimalReportEntity>> updateReportStatus(
      String reportId, String newStatus) async {
    try {
      final updated =
          await _localDataSource.updateReportStatus(reportId, newStatus);
      if (updated == null) {
        return Left(LocalDatabaseFailure(message: 'Failed to update report'));
      }
      return Right(updated.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Error updating report status'));
    }
  }

  // ================= Delete Report =================
  @override
  Future<Either<Failure, bool>> deleteReport(String reportId) async {
    try {
      final success = await _localDataSource.deleteReport(reportId);
      return Right(success);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to delete report'));
    }
  }

  // ================= Upload Photo =================
  @override
  Future<Either<Failure, String>> uploadPhoto(File photo) async {
    try {
      final path = await _localDataSource.uploadPhoto(photo);
      return Right(path);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to upload photo'));
    }
  }
}
