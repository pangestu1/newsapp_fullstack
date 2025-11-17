import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/api_response.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_endpoints.dart';

class AuthRepository {
  final DioClient _dioClient;

  AuthRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<ApiResponse<User>> register({
    required String name,
    required String email,
    required String password,
    String role = 'pembaca',
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );

      if (response.statusCode == 201) {
        final user = User.fromJson(response.data['user']);
        final token = response.data['token'];
        
        // Save token and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, token);
        await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
        
        return ApiResponse(success: true, message: response.data['message'], data: user);
      } else {
        return ApiResponse(success: false, message: response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false, 
        message: e.response?.data['message'] ?? 'Registration failed',
        error: e.message,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'An error occurred', error: e.toString());
    }
  }

  Future<ApiResponse<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data['user']);
        final token = response.data['token'];
        
        // Save token and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, token);
        await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
        
        return ApiResponse(success: true, message: response.data['message'], data: user);
      } else {
        return ApiResponse(success: false, message: response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false, 
        message: e.response?.data['message'] ?? 'Login failed',
        error: e.message,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'An error occurred', error: e.toString());
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }
}