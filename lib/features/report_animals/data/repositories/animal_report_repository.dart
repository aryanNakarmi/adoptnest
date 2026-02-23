import 'dart:io';
import 'package:adoptnest/features/report_animals/data/datasources/animal_report_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/core/services/connectivity/network_info.dart';
import 'package:adoptnest/features/report_animals/data/datasources/local/local_animal_report_datasource.dart';
import 'package:adoptnest/features/report_animals/data/datasources/remote/remote_animal_report_datasource.dart';
import 'package:adoptnest/features/report_animals/data/models/animal_report_api_model.dart';
import 'package:adoptnest/features/report_animals/data/models/animal_report_hive_model.dart';
import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:adoptnest/features/report_animals/domain/repositories/animal_report_repository.dart';

final animalReportRepositoryProvider = Provider<IAnimalReportRepository>((ref) {
  return AnimalReportRepository(
    localDataSource: ref.read(animalReportLocalDatasourceProvider),
    remoteDataSource: ref.read(animalReportRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
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

  List<AnimalReportEntity> _apiToEntities(List<AnimalReportApiModel> models) =>
      models.map((e) => e.toEntity()).toList();

  List<AnimalReportEntity> _hiveToEntities(List<AnimalReportHiveModel> models) =>
      models.map((e) => e.toEntity()).toList();

  Future<void> _cacheList(List<AnimalReportApiModel> apiModels) async {
    for (var m in apiModels) {
      await _localDataSource.createAnimalReport(AnimalReportHiveModel.fromEntity(m.toEntity()));
    }
  }

  Future<void> _cacheSingle(AnimalReportApiModel m) async {
    await _localDataSource.createAnimalReport(AnimalReportHiveModel.fromEntity(m.toEntity()));
  }

  @override
  Future<Either<Failure, List<AnimalReportEntity>>> getAllAnimalReports() async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getAllAnimalReports();
        await _cacheList(remote);
        return Right(_apiToEntities(remote));
      } catch (_) {
        return _cachedAll();
      }
    }
    return _cachedAll();
  }

  Future<Either<Failure, List<AnimalReportEntity>>> _cachedAll() async {
    try {
      return Right(_hiveToEntities(await _localDataSource.getAllAnimalReports()));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to fetch reports: $e'));
    }
  }

  @override
  Future<Either<Failure, AnimalReportEntity>> getAnimalReportById(String reportId) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getAnimalReportById(reportId);
        if (remote != null) {
          await _cacheSingle(remote);
          return Right(remote.toEntity());
        }
        return Left(LocalDatabaseFailure(message: 'Report not found'));
      } catch (_) {
        return _cachedById(reportId);
      }
    }
    return _cachedById(reportId);
  }

  Future<Either<Failure, AnimalReportEntity>> _cachedById(String id) async {
    try {
      final local = await _localDataSource.getAnimalReportById(id);
      if (local != null) return Right(local.toEntity());
      return Left(LocalDatabaseFailure(message: 'Report not found'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to fetch report: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AnimalReportEntity>>> getReportsBySpecies(String species) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getReportsBySpecies(species);
        await _cacheList(remote);
        return Right(_apiToEntities(remote));
      } catch (_) {
        return _cachedBySpecies(species);
      }
    }
    return _cachedBySpecies(species);
  }

  Future<Either<Failure, List<AnimalReportEntity>>> _cachedBySpecies(String species) async {
    try {
      return Right(_hiveToEntities(await _localDataSource.getReportsBySpecies(species)));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to filter reports: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AnimalReportEntity>>> getMyReports(String userId) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getMyReports();
        await _cacheList(remote);
        return Right(_apiToEntities(remote));
      } catch (_) {
        return _cachedMyReports(userId);
      }
    }
    return _cachedMyReports(userId);
  }

  Future<Either<Failure, List<AnimalReportEntity>>> _cachedMyReports(String userId) async {
    try {
      return Right(_hiveToEntities(await _localDataSource.getMyReports(userId)));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to fetch user reports: $e'));
    }
  }

  @override
  Future<Either<Failure, AnimalReportEntity>> createAnimalReport(AnimalReportEntity report) async {
    if (await _networkInfo.isConnected) {
      try {
        final created = await _remoteDataSource.createAnimalReport(AnimalReportApiModel.fromEntity(report));
        await _cacheSingle(created);
        return Right(created.toEntity());
      } catch (e) {
        return Left(ApiFailure(message: 'Failed to create report: $e'));
      }
    } else {
      try {
        final created = await _localDataSource.createAnimalReport(AnimalReportHiveModel.fromEntity(report));
        return Right(created.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: 'Failed to create report: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, AnimalReportEntity>> updateReportStatus(String reportId, String newStatus) async {
    if (await _networkInfo.isConnected) {
      try {
        final updated = await _remoteDataSource.updateReportStatus(reportId, newStatus);
        if (updated != null) {
          await _cacheSingle(updated);
          return Right(updated.toEntity());
        }
        return Left(LocalDatabaseFailure(message: 'Failed to update report'));
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
        return Right(await _remoteDataSource.uploadPhoto(photo));
      } catch (e) {
        return Left(ApiFailure(message: 'Failed to upload photo: $e'));
      }
    }
    return Left(NetworkFailure(message: 'No internet connection'));
  }
}
