import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/core/services/connectivity/network_info.dart';
import 'package:adoptnest/features/report_animals/data/datasources/local/local_animal_report_datasource.dart';
import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:adoptnest/features/report_animals/domain/repositories/animal_report_repository.dart';
import 'package:adoptnest/features/report_animals/data/models/animal_report_hive_model.dart';

final animalReportRepositoryProvider =
    Provider<IAnimalReportRepository>((ref) {
  final localDataSource = ref.read(animalReportLocalDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return AnimalReportRepository(
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );
});

class AnimalReportRepository implements IAnimalReportRepository {
  final AnimalReportLocalDatasource _localDataSource;
  final NetworkInfo _networkInfo;

  AnimalReportRepository({
    required AnimalReportLocalDatasource localDataSource,
    required NetworkInfo networkInfo,
  })  : _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  List<AnimalReportEntity> _mapToEntities(List<AnimalReportHiveModel> models) =>
      models.map((e) => e.toEntity()).toList();

  
  @override
  Future<Either<Failure, List<AnimalReportEntity>>> getAllAnimalReports() async {
    try {
      final reports = await _localDataSource.getAllAnimalReports();
      return Right(_mapToEntities(reports));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to fetch reports: $e'));
    }
  }

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
      return Left(LocalDatabaseFailure(message: 'Failed to fetch report: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AnimalReportEntity>>> getReportsBySpecies(
      String species) async {
    try {
      final reports = await _localDataSource.getReportsBySpecies(species);
      return Right(_mapToEntities(reports));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to filter reports: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AnimalReportEntity>>> getMyReports(
      String userId) async {
    try {
      final reports = await _localDataSource.getMyReports(userId);
      return Right(_mapToEntities(reports));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to fetch user reports: $e'));
    }
  }

  @override
  Future<Either<Failure, AnimalReportEntity>> createAnimalReport(
      AnimalReportEntity report) async {
    try {
      final hiveModel = AnimalReportHiveModel.fromEntity(report);
      final createdReport = await _localDataSource.createAnimalReport(hiveModel);

      return Right(createdReport.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to create report: $e'));
    }
  }

  @override
  Future<Either<Failure, AnimalReportEntity>> updateReportStatus(
      String reportId, String newStatus) async {
    try {
      final updated = await _localDataSource.updateReportStatus(reportId, newStatus);
      if (updated == null) {
        return Left(LocalDatabaseFailure(message: 'Failed to update report'));
      }
      return Right(updated.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Error updating report: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteReport(String reportId) async {
    try {
      await _localDataSource.deleteReport(reportId);
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to delete report: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadPhoto(File photo) async {
    try {
      final path = await _localDataSource.uploadPhoto(photo);
      return Right(path);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to upload photo: $e'));
    }
  }
}
