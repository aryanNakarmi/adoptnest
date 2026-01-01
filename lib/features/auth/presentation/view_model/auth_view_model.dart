import 'package:adoptnest/features/auth/domain/usecases/login_usecase.dart';
import 'package:adoptnest/features/auth/domain/usecases/register_usecase.dart';
import 'package:adoptnest/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(()=> AuthViewModel()
);

class AuthViewModel extends Notifier<AuthState>{

  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;

  @override
  AuthState build() {
     _registerUsecase =ref.read(registerUseCaseProvider);
     _loginUsecase = ref.read(loginUseCaseProvider);
     return AuthState();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    //wait for 2 seconds
    await Future.delayed(Duration(seconds: 2));

    final params = 
      RegisterUsecaseParams(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber
      );
      final result =await _registerUsecase(params);
      result.fold(
        (failure){
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: failure.message,
          );
        }, (isRegistered){
           
              state = state.copyWith(status: AuthStatus.registered);
        
        
        }
        );
  }


//Login
Future<void> login({

    required String email,
    required String password,

  }) async {
    state = state.copyWith(status: AuthStatus.loading);

await Future.delayed(Duration(seconds: 2));

    final params = 
      LoginUsecaseParams(
  
        email: email,
        password: password,

      );
      final result =await _loginUsecase(params);
      result.fold(
        (failure){
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: failure.message,
          );
        }, (authEntity){
              state = state.copyWith(
                status: AuthStatus.authenticated,
                authEntity:authEntity,
              );
            }
        
        );
  }



  
}