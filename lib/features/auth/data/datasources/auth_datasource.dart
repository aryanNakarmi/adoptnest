import 'package:adoptnest/features/auth/data/models/auth_api_model.dart';
import 'package:adoptnest/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthLocalDataSource{
  
  Future<bool> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();
  //get email exists
  Future<AuthHiveModel?> getUserById(String authId);
  Future<AuthHiveModel?> getUserByEmail(String email);
  Future<bool> updateUser(AuthHiveModel user);
  Future<bool> deleteUser(String authId);
}

abstract interface class IAuthRemoteDataSource {
  Future<AuthApiModel> register(AuthApiModel user);
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel?> getUserById(String authId);
}
