
import 'package:adoptnest/features/auth/domain/entities/auth_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'auth_api_model.g.dart';
@JsonSerializable()
class AuthApiModel {
  @JsonKey(name: '_id')
  final String? id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? password;
  final String? profilePicture;
  final String? role;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.password,
    this.profilePicture,
    this.role,

  });

  //toJSON
  Map<String, dynamic> toJson() => _$AuthApiModelToJson(this);

  //fromJSON
  factory AuthApiModel.fromJson(Map<String, dynamic> json) => _$AuthApiModelFromJson(json);

  //toEntity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
      role: role,
    );
  }

  //fromEntity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      password: entity.password,
      profilePicture: entity.profilePicture,
      role: entity.role
);
  }

  //toEntityList
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
