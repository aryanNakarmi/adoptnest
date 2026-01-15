

import 'package:adoptnest/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? username;
  final String? password;
  final String? profilePicture;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.username,
    this.phoneNumber,
    this.password,
    this.profilePicture,

  });

  //toJSON
  Map<String, dynamic> toJson() {
    return {
      'name': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'username': username,
      'password': password,
      'profilePicture': profilePicture,
    };
  }

  //fromJSON
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'],
      fullName: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      username: json['username'],
      profilePicture: json['profilePicture']
      );
 
  }

  //toEntity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      username: username,
      profilePicture: profilePicture,
    );
  }

  //fromEntity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      username: entity.username,
      password: entity.password,
      profilePicture: entity.profilePicture,
);
  }

  //toEntityList
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
