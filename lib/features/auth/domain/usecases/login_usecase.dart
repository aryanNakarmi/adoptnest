import 'package:adoptnest/features/auth/data/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class LoginUsecaseParams extends Equatable{
 
  final String email;
  final String password;
  
  const LoginUsecaseParams({

    required this.email, 
    required this.password
    });

  @override
  List<Object?> get props => [

    email,
    password
  ];
}
//provider
final loginUseCaseProvider =Provider<LoginUsecase>((ref){
  final authRepository = ref.read(AuthRepositoryProvider);
  return LoginUsecase(authRepository: authRepository);
});

class LoginUsecase implements UsecaseWithParams<AuthEntity, LoginUsecaseParams>{
  final IAuthRepository _authRepository;

  LoginUsecase({
    required IAuthRepository authRepository
  }): _authRepository= authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(LoginUsecaseParams params) {

    return _authRepository.login(params.email, params.password);
  }

} 