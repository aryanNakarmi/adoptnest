import 'dart:io';

import 'package:adoptnest/features/report_animals/data/datasources/animal_report_datasource.dart';
import 'package:adoptnest/features/report_animals/data/datasources/local/local_animal_report_datasource.dart';
import 'package:adoptnest/features/report_animals/data/datasources/remote/remote_animal_report_datasource.dart';
import 'package:adoptnest/features/report_animals/data/models/animal_report_api_model.dart';
import 'package:adoptnest/features/report_animals/data/models/animal_report_hive_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/core/services/connectivity/network_info.dart';
import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:adoptnest/features/report_animals/domain/repositories/animal_report_repository.dart';

final animalReportRepositoryProvider =
    Provider<IAnimalReportRepository>((ref) {
  final localDataSource = ref.read(animalReportLocalDatasourceProvider);
  final remoteDataSource = ref.read(animalReportRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return AnimalReportRepository(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

class AnimalReportRepository implements IAnimalReportRepository {
  final IAnimalReportLocalDataSource _localDataSource;
  final IAnimalReportRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  AnimalReportRepository({
    required IAnimalReportLocalDataSource localDataSource,
    required IAnimalReportRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  List<AnimalReportEntity> _apiModelsToEntities(List<AnimalReportApiModel> models) =>
      models.map((e) => e.toEntity()).toList();

  List<AnimalReportEntity> _hiveModelsToEntities(List<AnimalReportHiveModel> models) =>
      models.map((e) => e.toEntity()).toList();

  Future<void> _cacheToLocal(List<AnimalReportApiModel> apiModels) async {
    for (var apiModel in apiModels) {
      final hiveModel = AnimalReportHiveModel.fromEntity(apiModel.toEntity());
      await _localDataSource.createAnimalReport(hiveModel);
    }
  }

  Future<void> _cacheSingleToLocal(AnimalReportApiModel apiModel) async {
    final hiveModel = AnimalReportHiveModel.fromEntity(apiModel.toEntity());
    await _localDataSource.createAnimalReport(hiveModel);
  }

  @override
  Future<Either<Failure, List<AnimalReportEntity>>> getAllAnimalReports() async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteReports = await _remoteDataSource.getAllAnimalReports();
        await _cacheToLocal(remoteReports);
        return Right(_apiModelsToEntities(remoteReports));
      } catch (e) {
        return _getCachedAllReports();
      }
    } else {
      return _getCachedAllReports();
    }
  }

  Future<Either<Failure, List<AnimalReportEntity>>> _getCachedAllReports() async {
    try {
      final localReports = await _localDataSource.getAllAnimalReports();
      return Right(_hiveModelsToEntities(localReports));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to fetch reports: $e'));
    }
  }

  @override
  Future<Either<Failure, AnimalReportEntity>> getAnimalReportById(String reportId) async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteReport = await _remoteDataSource.getAnimalReportById(reportId);
        if (remoteReport != null) {
          await _cacheSingleToLocal(remoteReport);
          return Right(remoteReport.toEntity());
        } else {
          return Left(LocalDatabaseFailure(message: 'Report not found'));
        }
      } catch (e) {
        return _getCachedReportById(reportId);
      }
    } else {
      return _getCachedReportById(reportId);
    }
  }

  Future<Either<Failure, AnimalReportEntity>> _getCachedReportById(String reportId) async {
    try {
      final localReport = await _localDataSource.getAnimalReportById(reportId);
      if (localReport != null) return Right(localReport.toEntity());
      return Left(LocalDatabaseFailure(message: 'Report not found'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to fetch report: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AnimalReportEntity>>> getReportsBySpecies(String species) async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteReports = await _remoteDataSource.getReportsBySpecies(species);
        await _cacheToLocal(remoteReports);
        return Right(_apiModelsToEntities(remoteReports));
      } catch (e) {
        return _getCachedReportsBySpecies(species);
      }
    } else {
      return _getCachedReportsBySpecies(species);
    }
  }

  Future<Either<Failure, List<AnimalReportEntity>>> _getCachedReportsBySpecies(String species) async {
    try {
      final localReports = await _localDataSource.getReportsBySpecies(species);
      return Right(_hiveModelsToEntities(localReports));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to filter reports: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AnimalReportEntity>>> getMyReports(String userId) async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteReports = await _remoteDataSource.getMyReports();
        await _cacheToLocal(remoteReports);
        return Right(_apiModelsToEntities(remoteReports));
      } catch (e) {
        return _getCachedMyReports(userId);
      }
    } else {
      return _getCachedMyReports(userId);
    }
  }

  Future<Either<Failure, List<AnimalReportEntity>>> _getCachedMyReports(String userId) async {
    try {
      final localReports = await _localDataSource.getMyReports(userId);
      return Right(_hiveModelsToEntities(localReports));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to fetch user reports: $e'));
    }
  }

  @override
  Future<Either<Failure, AnimalReportEntity>> createAnimalReport(AnimalReportEntity report) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = AnimalReportApiModel.fromEntity(report);
        final createdReport = await _remoteDataSource.createAnimalReport(apiModel);
        await _cacheSingleToLocal(createdReport);
        return Right(createdReport.toEntity());
      } catch (e) {
        return Left(ApiFailure(message: 'Failed to create report: $e'));
      }
    } else {
      try {
        final hiveModel = AnimalReportHiveModel.fromEntity(report);
        final createdReport = await _localDataSource.createAnimalReport(hiveModel);
        return Right(createdReport.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: 'Failed to create report: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, AnimalReportEntity>> updateReportStatus(String reportId, String newStatus) async {
    if (await _networkInfo.isConnected) {
      try {
        final updatedReport = await _remoteDataSource.updateReportStatus(reportId, newStatus);
        if (updatedReport != null) {
          await _cacheSingleToLocal(updatedReport);
          return Right(updatedReport.toEntity());
        } else {
          return Left(LocalDatabaseFailure(message: 'Failed to update report'));
        }
      } catch (e) {
        return Left(ApiFailure(message: 'Failed to update report: $e'));
      }
    } else {
      try {
        final updated = await _localDataSource.updateReportStatus(reportId, newStatus);
        if (updated != null) return Right(updated.toEntity());
        return Left(LocalDatabaseFailure(message: 'Failed to update report offline'));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: 'Error updating report: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> deleteReport(String reportId) async {
    if (await _networkInfo.isConnected) {
      try {
        final success = await _remoteDataSource.deleteReport(reportId);
        if (success) await _localDataSource.deleteReport(reportId);
        return Right(success);
      } catch (e) {
        return Left(ApiFailure(message: 'Failed to delete report: $e'));
      }
    } else {
      try {
        await _localDataSource.deleteReport(reportId);
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: 'Failed to delete report: $e'));
      }
    }
  }

  
  @override
  Future<Either<Failure, String>> uploadPhoto(File photo) async {
    if (await _networkInfo.isConnected) {
      try {
        final url = await _remoteDataSource.uploadPhoto(photo);
        return Right(url);
      } catch (e) {
        return Left(ApiFailure(message: 'Failed to upload photo: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
