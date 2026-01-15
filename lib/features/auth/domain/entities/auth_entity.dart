import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable{

  final String? authId;
  final String fullName;
  final String email;
  final String? username;
  final String? phoneNumber;
  final String? password;
  final String? profilePicture;
  final String? role;

  const AuthEntity({
  this.authId, 
  required this.fullName, 
  required this.email, 
  this.phoneNumber, 
  this.password, 
  this.profilePicture, 
  this.username, 
  this.role 
});
  
  @override
  List<Object?> get props => [
    authId,
    fullName,
    email,
    phoneNumber,
    username,
    password,
    profilePicture,
    role

  ];

   
}