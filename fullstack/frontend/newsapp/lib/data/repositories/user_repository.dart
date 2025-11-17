import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/api_response.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';

class UserRepository {
  final DioClient _dioClient;

  UserRepository({required DioClient dioClient}) : _dioClient = dioClient;

  // Get all users (Admin only)
  Future<ApiResponse<List<User>>> getAllUsers() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.users);

      if (response.statusCode == 200) {
        final users = (response.data as List)
            .map((item) => User.fromJson(item))
            .toList();
        return ApiResponse(
          success: true,
          message: 'Success',
          data: users,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Failed to fetch users',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to fetch users',
        error: e.message,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An error occurred',
        error: e.toString(),
      );
    }
  }

  // Update user role (Admin only)
  Future<ApiResponse<User>> updateUserRole({
    required int userId,
    required String newRole,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        ApiEndpoints.userRole(userId),
        data: {
          'role': newRole,
        },
      );

      if (response.statusCode == 200) {
        // Fetch updated users list to get the updated user
        final usersResponse = await getAllUsers();
        if (usersResponse.success && usersResponse.data != null) {
          final updatedUser = usersResponse.data!
              .firstWhere((user) => user.id == userId, orElse: () => User(
                    id: userId,
                    name: '',
                    email: '',
                    role: newRole,
                  ));
          
          return ApiResponse(
            success: true,
            message: response.data['message'] ?? 'User role updated successfully',
            data: updatedUser,
          );
        } else {
          return ApiResponse(
            success: true,
            message: response.data['message'] ?? 'User role updated successfully',
            data: User(
              id: userId,
              name: '',
              email: '',
              role: newRole,
            ),
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Failed to update user role',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to update user role',
        error: e.message,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An error occurred',
        error: e.toString(),
      );
    }
  }

  // Get user profile (current user)
  Future<ApiResponse<User>> getCurrentUserProfile() async {
    try {
      // Since our API doesn't have a specific endpoint for current user profile,
      // we'll get all users and find the current one, or use the stored data
      final response = await _dioClient.dio.get(ApiEndpoints.users);

      if (response.statusCode == 200) {
        final users = (response.data as List)
            .map((item) => User.fromJson(item))
            .toList();
        
        // Get current user ID from stored data (you might need to pass this)
        // For now, return the first user as example
        if (users.isNotEmpty) {
          return ApiResponse(
            success: true,
            message: 'Success',
            data: users.first,
          );
        } else {
          return ApiResponse(
            success: false,
            message: 'User not found',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: 'Failed to fetch user profile',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to fetch user profile',
        error: e.message,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An error occurred',
        error: e.toString(),
      );
    }
  }

  // Delete user (Admin only) - Optional
  Future<ApiResponse<void>> deleteUser(int userId) async {
    try {
      // Note: This endpoint might not exist in your API
      // You'll need to create it in your backend first
      final response = await _dioClient.dio.delete(
        '/users/$userId', // Adjust endpoint as needed
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: response.data['message'] ?? 'User deleted successfully',
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Failed to delete user',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to delete user',
        error: e.message,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An error occurred',
        error: e.toString(),
      );
    }
  }

  // Search users (Optional)
  Future<ApiResponse<List<User>>> searchUsers(String query) async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.users,
        queryParameters: {
          'search': query,
        },
      );

      if (response.statusCode == 200) {
        final users = (response.data as List)
            .map((item) => User.fromJson(item))
            .toList();
        return ApiResponse(
          success: true,
          message: 'Success',
          data: users,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Failed to search users',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to search users',
        error: e.message,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An error occurred',
        error: e.toString(),
      );
    }
  }
}