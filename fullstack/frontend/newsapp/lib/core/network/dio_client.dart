import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class DioClient {
  late Dio _dio;
  
  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
    ));
    
    // Add comprehensive debug interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        print('🚀 [DIO] === REQUEST START ===');
        print('📡 [DIO] Method: ${options.method}');
        print('🌐 [DIO] URL: ${options.uri}');
        print('📦 [DIO] Headers: ${options.headers}');
        if (options.data != null) {
          print('📦 [DIO] Body: ${options.data}');
        }
        
        // Add token to headers
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          print('🔑 [DIO] Token added to headers');
        } else {
          print('🔑 [DIO] No token found');
        }
        print('🚀 [DIO] === REQUEST END ===');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ [DIO] === RESPONSE START ===');
        print('📡 [DIO] Status: ${response.statusCode} ${response.statusMessage}');
        print('📨 [DIO] Headers: ${response.headers}');
        print('📨 [DIO] Data: ${response.data}');
        print('✅ [DIO] === RESPONSE END ===');
        return handler.next(response);
      },
      onError: (DioException error, handler) async {
        print('❌ [DIO] === ERROR START ===');
        print('💥 [DIO] Error Type: ${error.type}');
        print('💥 [DIO] Error Message: ${error.message}');
        print('💥 [DIO] Error Response: ${error.response?.data}');
        print('💥 [DIO] Error Status: ${error.response?.statusCode}');
        print('💥 [DIO] Stack Trace: ${error.stackTrace}');
        print('❌ [DIO] === ERROR END ===');
        
        // Handle token expiration
        if (error.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(AppConstants.tokenKey);
          await prefs.remove(AppConstants.userKey);
          print('🔐 [DIO] Token expired, cleared local storage');
        }
        return handler.next(error);
      },
    ));
  }
  
  Dio get dio => _dio;
}