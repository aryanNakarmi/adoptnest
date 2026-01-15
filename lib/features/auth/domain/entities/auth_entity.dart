import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable{

  final String? authId;
  final String fullName;
  final String email;
  final String? username;
  final String? phoneNumber;
  final String? password;
  final String? profilePicture;

  const AuthEntity({
  this.authId, 
  required this.fullName, 
  required this.email, 
  this.phoneNumber, 
  this.password, 
  this.profilePicture, 
  this.username, 
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

  ];

   
}