import 'package:adoptnest/core/constants/hive_table_constant.dart';
import 'package:adoptnest/features/auth/domain/entities/auth_entity.dart';
import 'package:hive/hive.dart';

import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject{

  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? phoneNumber;

  @HiveField(4)
  final String? password;

  @HiveField(5)
  final String? profilePicture;

  @HiveField(6)
  final String? role;

  AuthHiveModel({
    String? authId, 
    required this.fullName, 
    required this.email, 
    this.phoneNumber,  
    this.password, 
    this.profilePicture, 
    this.role
    }): authId = authId?? Uuid().v4();

//From Entity
factory AuthHiveModel.fromEntity(AuthEntity entity){
  return AuthHiveModel(
      authId: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      password: entity.password,
      profilePicture: entity.profilePicture,
      role: entity.role
  );
}
//To entity
AuthEntity toEntity({AuthEntity? batchEntity}){
  return AuthEntity(
    authId: authId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      profilePicture: profilePicture,
      role: role
     );
}

//To entity list
static List<AuthEntity> toEntityList(List<AuthHiveModel> models){
  return models.map((model)=> model.toEntity()).toList();
}
}