import 'package:adoptnest/core/error/failures.dart';
import 'package:dartz/dartz.dart';


// Usecase with Parameters
abstract interface class UsecaseWithParams<SuccessType, Params>{
  Future<Either<Failure, SuccessType>> call(Params params);
}

//Use case without Parameters
abstract interface class UsecaseWithoutParams<SuccesType>{
  Future<Either<Failure, SuccesType>> call();
}