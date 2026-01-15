import 'package:adoptnest/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:adoptnest/features/auth/domain/usecases/login_usecase.dart';
import 'package:adoptnest/features/auth/domain/usecases/logout_usecase.dart';
import 'package:adoptnest/features/auth/domain/usecases/register_usecase.dart';
import 'package:adoptnest/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(()=> AuthViewModel()
);

class AuthViewModel extends Notifier<AuthState>{

  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  late final LogoutUsecase _logoutUsecase;

  @override
  AuthState build() {
     _registerUsecase =ref.read(registerUseCaseProvider);
     _loginUsecase = ref.read(loginUseCaseProvider);
     _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
     _logoutUsecase = ref.read(logoutUsecaseProvider);
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
          (failure) => state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: failure.message,
          ),
          (success) => state = state.copyWith(status: AuthStatus.registered),
        );
      }

//Login
Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginUsecase(
      LoginUsecaseParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated,
           authEntity: user),
    );
    }

  Future<void> getCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _getCurrentUserUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, authEntity: user),
    );
  }
  
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        authEntity: null,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

  
