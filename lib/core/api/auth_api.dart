import 'package:adoptnest/core/api/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for Auth API
final authApiProvider = Provider<AuthApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthApi(apiClient);
});

class AuthApi {
  final ApiClient _apiClient;

  AuthApi(this._apiClient);

  // Request Password Reset
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await _apiClient.post(
        '/auth/request-password-reset',
        data: {
          'email': email,
        },
      );

      return {
        'success': response.data['success'] ?? false,
        'message': response.data['message'] ?? 'Password reset email sent',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to send reset email',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Reset Password with Token
  Future<Map<String, dynamic>> resetPassword(
    String token,
    String newPassword,
  ) async {
    try {
      final response = await _apiClient.post(
        '/auth/reset-password/$token',
        data: {
          'newPassword': newPassword,
        },
      );

      return {
        'success': response.data['success'] ?? false,
        'message': response.data['message'] ?? 'Password reset successfully',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to reset password',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}