import 'package:dio/dio.dart';
import '../models/news_model.dart';
import '../models/api_response.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';

class NewsRepository {
  final DioClient _dioClient;

  NewsRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<ApiResponse<NewsResponse>> getNews({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.news,
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search,
        },
      );

      if (response.statusCode == 200) {
        final newsResponse = NewsResponse.fromJson(response.data);
        return ApiResponse(success: true, message: 'Success', data: newsResponse);
      } else {
        return ApiResponse(success: false, message: 'Failed to fetch news');
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false, 
        message: e.response?.data['message'] ?? 'Failed to fetch news',
        error: e.message,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'An error occurred', error: e.toString());
    }
  }

  Future<ApiResponse<News>> getNewsDetail(int id) async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.newsDetail(id));

      if (response.statusCode == 200) {
        final news = News.fromJson(response.data);
        return ApiResponse(success: true, message: 'Success', data: news);
      } else {
        return ApiResponse(success: false, message: 'News not found');
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false, 
        message: e.response?.data['message'] ?? 'Failed to fetch news',
        error: e.message,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'An error occurred', error: e.toString());
    }
  }

  Future<ApiResponse<News>> createNews({
    required String title,
    required String content,
    String? imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'content': content,
        if (imagePath != null)
          'image': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dioClient.dio.post(
        ApiEndpoints.news,
        data: formData,
      );

      if (response.statusCode == 201) {
        // Need to fetch the created news to get full data
        final newsId = response.data['newsId'];
        return getNewsDetail(newsId);
      } else {
        return ApiResponse(success: false, message: response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false, 
        message: e.response?.data['message'] ?? 'Failed to create news',
        error: e.message,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'An error occurred', error: e.toString());
    }
  }

  Future<ApiResponse<News>> updateNews({
    required int id,
    required String title,
    required String content,
    String? imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'content': content,
        if (imagePath != null)
          'image': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dioClient.dio.put(
        ApiEndpoints.newsDetail(id),
        data: formData,
      );

      if (response.statusCode == 200) {
        return getNewsDetail(id);
      } else {
        return ApiResponse(success: false, message: response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false, 
        message: e.response?.data['message'] ?? 'Failed to update news',
        error: e.message,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'An error occurred', error: e.toString());
    }
  }

  Future<ApiResponse<void>> deleteNews(int id) async {
    try {
      final response = await _dioClient.dio.delete(ApiEndpoints.newsDetail(id));

      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: response.data['message']);
      } else {
        return ApiResponse(success: false, message: response.data['message']);
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false, 
        message: e.response?.data['message'] ?? 'Failed to delete news',
        error: e.message,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'An error occurred', error: e.toString());
    }
  }
}