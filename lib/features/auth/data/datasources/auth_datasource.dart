import 'package:adoptnest/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthDataSource{
  
  Future<bool> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();

  //get email exists
  Future<bool> isExistingEmail(String email);

}