import 'package:dio/dio.dart';
import '../models/comment_model.dart';
import '../models/api_response.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';

class CommentRepository {
  final DioClient _dioClient;

  CommentRepository({required DioClient dioClient}) : _dioClient = dioClient;

  // Get comments by news ID
  Future<ApiResponse<List<Comment>>> getCommentsByNews(int newsId) async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.commentsByNews(newsId),
      );

      if (response.statusCode == 200) {
        final comments = (response.data as List)
            .map((item) => Comment.fromJson(item))
            .toList();
        return ApiResponse(
          success: true,
          message: 'Success',
          data: comments,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Failed to fetch comments',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to fetch comments',
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

  // Create new comment
  Future<ApiResponse<Comment>> createComment({
    required String content,
    required int newsId,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.comments,
        data: {
          'content': content,
          'news_id': newsId,
        },
      );

      if (response.statusCode == 201) {
        // Since the API returns only commentId, we need to fetch the created comment
        final commentId = response.data['commentId'];
        // Wait a bit for the comment to be created then fetch all comments
        await Future.delayed(const Duration(milliseconds: 500));
        final commentsResponse = await getCommentsByNews(newsId);
        
        if (commentsResponse.success && commentsResponse.data != null) {
          final createdComment = commentsResponse.data!
              .firstWhere((comment) => comment.id == commentId);
          return ApiResponse(
            success: true,
            message: response.data['message'] ?? 'Comment created successfully',
            data: createdComment,
          );
        } else {
          return ApiResponse(
            success: true,
            message: response.data['message'] ?? 'Comment created successfully',
            data: Comment(
              id: commentId,
              content: content,
              newsId: newsId,
              userId: 0, // Will be updated when fetched
              userName: 'You',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Failed to create comment',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to create comment',
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

  // Delete comment (Admin only)
  Future<ApiResponse<void>> deleteComment(int commentId) async {
    try {
      final response = await _dioClient.dio.delete(
        ApiEndpoints.commentDetail(commentId),
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: response.data['message'] ?? 'Comment deleted successfully',
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Failed to delete comment',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to delete comment',
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

  // Update comment (Optional - jika backend support)
  Future<ApiResponse<Comment>> updateComment({
    required int commentId,
    required String content,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        ApiEndpoints.commentDetail(commentId),
        data: {
          'content': content,
        },
      );

      if (response.statusCode == 200) {
        // Fetch updated comment data
        // Note: This might need adjustment based on your API response
        return ApiResponse(
          success: true,
          message: response.data['message'] ?? 'Comment updated successfully',
          data: Comment.fromJson(response.data),
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Failed to update comment',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to update comment',
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