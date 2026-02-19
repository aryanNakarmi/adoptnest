import 'dart:io';

import 'package:adoptnest/core/api/api_client.dart';
import 'package:adoptnest/core/api/api_endpoints.dart';
import 'package:adoptnest/core/services/storage/token_service.dart';
import 'package:adoptnest/core/services/storage/user_session_service.dart';
import 'package:adoptnest/features/auth/data/datasources/auth_datasource.dart';
import 'package:adoptnest/features/auth/data/models/auth_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Provider
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider), 
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

  @override
  Future<AuthApiModel?> getUserById(String authId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);

      //Save user session
      await _userSessionService.saveUserSession(
        userId: user.id!,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
      );

       // Save token to TokenService
      final token = response.data['token'];
      // Later store token in secure storage
      await _tokenService.saveToken(token);
       
      return user;
      
      
    }

    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: user.toJson(),
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final registeredUser = AuthApiModel.fromJson(data);
      return registeredUser;
    }
    return user;
  }
  
  @override
  Future<bool> updateProfile({
    required String fullName,
    required String phoneNumber,
    File? profilePicture,
  }) async {
    final Map<String, dynamic> data = {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
    };

    // Only add profilePicture if it's provided
    if (profilePicture != null) {
      final formData = FormData.fromMap({
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'profilePicture': await MultipartFile.fromFile(
          profilePicture.path,
          filename: profilePicture.path.split('/').last,
        ),
      });

      final response = await _apiClient.put(
        '/auth/update-profile',
        data: formData,
      );

      if (response.data['success'] == true) {
        final newProfilePicture =
            response.data['data']?['profilePicture'] ??
            _userSessionService.getCurrentUserProfilePicture();

        await _userSessionService.saveUserSession(
          userId: _userSessionService.getCurrentUserId() ?? '',
          email: _userSessionService.getCurrentUserEmail() ?? '',
          fullName: fullName,
          phoneNumber: phoneNumber,
          profilePicture: newProfilePicture,
          role: _userSessionService.getCurrentUserRole(),
        );
        return true;
      }
    } else {
      // No image, just text
      final response = await _apiClient.put(
        '/auth/update-profile',
        data: data,
      );

      if (response.data['success'] == true) {
        await _userSessionService.saveUserSession(
          userId: _userSessionService.getCurrentUserId() ?? '',
          email: _userSessionService.getCurrentUserEmail() ?? '',
          fullName: fullName,
          phoneNumber: phoneNumber,
          profilePicture: _userSessionService.getCurrentUserProfilePicture(),
          role: _userSessionService.getCurrentUserRole(),
        );
        return true;
      }
    }

    return false;
  }
}