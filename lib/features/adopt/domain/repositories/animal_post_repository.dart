import 'package:dartz/dartz.dart';
import 'package:adoptnest/core/error/failures.dart';
import '../entities/animal_post_entity.dart';

abstract interface class IAnimalPostRepository {
  Future<Either<Failure, List<AnimalPostEntity>>> getAllAnimalPosts();
  Future<Either<Failure, AnimalPostEntity>> getAnimalPostById(String postId);
  Future<Either<Failure, List<AnimalPostEntity>>> getMyAdoptions();
}
