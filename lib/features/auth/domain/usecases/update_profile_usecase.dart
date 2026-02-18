import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/core/usecases/app_usecase.dart';
import 'package:adoptnest/features/auth/data/repositories/auth_repository.dart';
import 'package:adoptnest/features/auth/domain/entities/auth_entity.dart';
import 'package:adoptnest/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateProfileUsecaseParams extends Equatable {
  final String fullName;
  final String phoneNumber;

  const UpdateProfileUsecaseParams({
    required this.fullName,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [fullName, phoneNumber];
}

// provider
final updateProfileUsecaseProvider =
    Provider<UpdateProfileUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return UpdateProfileUsecase(authRepository: authRepository);
});

class UpdateProfileUsecase
    implements UsecaseWithParams<bool, UpdateProfileUsecaseParams> {
  final IAuthRepository _authRepository;

  UpdateProfileUsecase({
    required IAuthRepository authRepository,
  }) : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateProfileUsecaseParams params) {
    return _authRepository.updateProfile(
      fullName: params.fullName,
      phoneNumber: params.phoneNumber,
    );
  }
}