// ignore_for_file: unused_local_variable

import 'package:dio/dio.dart';

// ignore: avoid_classes_with_only_static_members
class ConnectionTest {
  static Future<void> testBackendConnection() async {
    final dio = Dio();
    
    // ignore: avoid_print
    print('🧪 ===== CONNECTION TEST STARTED =====');
    // ignore: avoid_print
    print('💻 Testing IP: 10.156.179.5:5000');

    // Test 1: Basic server connectivity
    try {
      // ignore: avoid_print
      print('1. Testing server connectivity...');
      final response = await dio.get(
        'http://10.156.179.5:5000',
        options: Options(receiveTimeout: const Duration(seconds: 5))
      );
      // ignore: avoid_print
      print('   ✅ Server is running');
    } catch (e) {
      // ignore: avoid_print
      print('   ❌ Cannot reach server: $e');
      return;
    }

    // Test 2: API endpoint
    try {
      // ignore: avoid_print
      print('2. Testing API endpoint...');
      final response = await dio.get(
        'http://10.156.179.5:5000/api/news',
        options: Options(receiveTimeout: const Duration(seconds: 5))
      );
      // ignore: avoid_print
      print('   ✅ API is working');
    } catch (e) {
      // ignore: avoid_print
      print('   ❌ API failed: $e');
    }

    // Test 3: Auth endpoints
    try {
      // ignore: avoid_print
      print('3. Testing Auth endpoint...');
      final response = await dio.post(
        'http://10.156.179.5:5000/api/auth/login',
        data: {
          'email': 'admin@newsapp.com',
          'password': 'admin123'
        },
        options: Options(receiveTimeout: const Duration(seconds: 5))
      );
      // ignore: avoid_print
      print('   ✅ Auth is working');
    } catch (e) {
      // ignore: avoid_print
      print('   ❌ Auth failed: $e');
    }

    // ignore: avoid_print
    print('🎯 Connection test completed');
  }
}