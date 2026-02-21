import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/core/services/connectivity/network_info.dart';
import 'package:adoptnest/features/adopt/data/datasources/local/local_animal_post_datasource.dart';
import 'package:adoptnest/features/adopt/data/datasources/remote/remote_animal_post_datasource.dart';
import 'package:adoptnest/features/adopt/data/models/animal_post_api_model.dart';
import 'package:adoptnest/features/adopt/data/models/animal_post_hive_model.dart';
import 'package:adoptnest/features/adopt/domain/entities/animal_post_entity.dart';
import 'package:adoptnest/features/adopt/domain/repositories/animal_post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final animalPostRepositoryProvider = Provider<IAnimalPostRepository>((ref) {
  return AnimalPostRepository(
    localDataSource: ref.read(animalPostLocalDatasourceProvider),
    remoteDataSource: ref.read(animalPostRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class AnimalPostRepository implements IAnimalPostRepository {
  final AnimalPostLocalDatasource _localDataSource;
  final AnimalPostRemoteDatasource _remoteDataSource;
  final NetworkInfo _networkInfo;

  AnimalPostRepository({
    required AnimalPostLocalDatasource localDataSource,
    required AnimalPostRemoteDatasource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  List<AnimalPostEntity> _apiToEntities(List<AnimalPostApiModel> models) =>
      models.map((e) => e.toEntity()).toList();

  List<AnimalPostEntity> _hiveToEntities(List<AnimalPostHiveModel> models) =>
      models.map((e) => e.toEntity()).toList();

  @override
  Future<Either<Failure, List<AnimalPostEntity>>> getAllAnimalPosts() async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getAllAnimalPosts();
        final hiveModels =
            remote.map((e) => AnimalPostHiveModel.fromEntity(e.toEntity())).toList();
        await _localDataSource.cachePosts(hiveModels);
        return Right(_apiToEntities(remote));
      } catch (e) {
        return _getCachedPosts();
      }
    } else {
      return _getCachedPosts();
    }
  }

  Future<Either<Failure, List<AnimalPostEntity>>> _getCachedPosts() async {
    try {
      final local = await _localDataSource.getAllAnimalPosts();
      return Right(_hiveToEntities(local));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to fetch posts: $e'));
    }
  }

  @override
  Future<Either<Failure, AnimalPostEntity>> getAnimalPostById(
      String postId) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getAnimalPostById(postId);
        if (remote != null) {
          await _localDataSource
              .cachePost(AnimalPostHiveModel.fromEntity(remote.toEntity()));
          return Right(remote.toEntity());
        }
        return Left(LocalDatabaseFailure(message: 'Post not found'));
      } catch (e) {
        return _getCachedPostById(postId);
      }
    } else {
      return _getCachedPostById(postId);
    }
  }

  Future<Either<Failure, AnimalPostEntity>> _getCachedPostById(
      String postId) async {
    try {
      final local = await _localDataSource.getAnimalPostById(postId);
      if (local != null) return Right(local.toEntity());
      return Left(LocalDatabaseFailure(message: 'Post not found'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to fetch post: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AnimalPostEntity>>> getMyAdoptions() async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getMyAdoptions();
        return Right(_apiToEntities(remote));
      } catch (e) {
        return Left(ApiFailure(message: 'Failed to fetch adoptions: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
