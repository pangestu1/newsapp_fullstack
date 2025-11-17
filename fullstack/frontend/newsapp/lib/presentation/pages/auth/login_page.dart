// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:newsapp/presentation/blocs/auth/auth_event.dart';
import 'package:newsapp/presentation/blocs/auth/auth_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import 'register_page.dart';
import '../news/news_list_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          print('🔔 [AUTH] State changed: ${state.runtimeType}');
          
          if (state is AuthError) {
            setState(() {
              _isLoading = false;
            });
            print('💥 [AUTH] Error: ${state.message}');
            _showErrorDialog(state.message);
          } else if (state is AuthAuthenticated) {
            setState(() {
              _isLoading = false;
            });
            print('✅ [AUTH] Login successful for: ${state.user.name}');
            _navigateToNewsList();
          } else if (state is AuthLoading) {
            print('⏳ [AUTH] Loading...');
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildLoginForm(),
                const SizedBox(height: 24),
                _buildRegisterLink(),
                
                // Test Connection Button
                const SizedBox(height: 16),
                _buildTestConnectionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.newspaper,
            size: 60,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Selamat Datang',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Masuk ke akun Anda untuk melanjutkan',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email harus diisi';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Format email tidak valid';
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Password Field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            obscureText: !_isPasswordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password harus diisi';
              }
              if (value.length < 6) {
                return 'Password minimal 6 karakter';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _login(),
          ),
          const SizedBox(height: 8),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordDialog,
              child: Text(
                'Lupa Password?',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'MASUK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum punya akun?',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: _navigateToRegister,
          child: Text(
            'Daftar di sini',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestConnectionButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _testConnection,
        icon: const Icon(Icons.wifi_find, size: 18),
        label: const Text('Test Koneksi Server'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.orange,
          side: const BorderSide(color: Colors.orange),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      print('🚀 [LOGIN] Attempting login for: ${_emailController.text}');
      
      context.read<AuthBloc>().add(
            AuthLoginEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  void _navigateToNewsList() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const NewsListPage()),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lupa Password'),
        content: const Text(
          'Fitur reset password sedang dalam pengembangan. '
          'Silakan hubungi administrator untuk reset password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // NEW METHOD: Test Connection
  void _testConnection() async {
    final dio = Dio();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi_find, color: Colors.blue),
            SizedBox(width: 8),
            Text('Testing Connection'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Testing connection to server...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    try {
      print('🧪 === MANUAL CONNECTION TEST START ===');
      
      // Test 1: Basic connectivity to server
      print('1. Testing basic connectivity to: http://192.168.1.105:5000');
      final response1 = await dio.get(
        'http://192.168.1.105:5000',
        options: Options(receiveTimeout: const Duration(seconds: 5))
      );
      print('   ✅ Basic connectivity: ${response1.statusCode}');
      
      // Test 2: API docs endpoint
      print('2. Testing API docs: http://192.168.1.105:5000/docs');
      final response2 = await dio.get(
        'http://192.168.1.105:5000/docs',
        options: Options(receiveTimeout: const Duration(seconds: 5))
      );
      print('   ✅ API docs: ${response2.statusCode}');
      
      // Test 3: News API endpoint
      print('3. Testing News API: http://192.168.1.105:5000/api/news');
      final response3 = await dio.get(
        'http://192.168.1.105:5000/api/news',
        options: Options(receiveTimeout: const Duration(seconds: 5))
      );
      print('   ✅ News API: ${response3.statusCode}');
      
      // Test 4: Auth login endpoint
      print('4. Testing Auth login: http://192.168.1.105:5000/api/auth/login');
      final response4 = await dio.post(
        'http://192.168.1.105:5000/api/auth/login',
        data: {
          'email': 'admin@newsapp.com',
          'password': 'admin123'
        },
        options: Options(receiveTimeout: const Duration(seconds: 5))
      );
      print('   ✅ Auth login: ${response4.statusCode}');
      
      print('🎉 ALL CONNECTION TESTS PASSED!');
      
      // Close loading dialog and show success
      Navigator.pop(context);
      _showConnectionResultDialog('✅ Koneksi Berhasil!\n\nSemua test berhasil:\n• Server accessible\n• API docs working\n• News API working\n• Auth endpoint working');
      
    } catch (e) {
      print('💥 CONNECTION TEST FAILED: $e');
      
      String errorMessage = 'Unknown error';
      if (e is DioException) {
        errorMessage = 'Dio Error: ${e.type}\nMessage: ${e.message}';
        if (e.response != null) {
          errorMessage += '\nStatus: ${e.response?.statusCode}';
        }
      } else {
        errorMessage = e.toString();
      }
      
      // Close loading dialog and show error
      Navigator.pop(context);
      _showConnectionResultDialog('❌ Koneksi Gagal!\n\nError: $errorMessage\n\nPastikan:\n1. Backend running di port 5000\n2. IP 192.168.1.105 benar\n3. Firewall dinonaktifkan');
    }
    
    print('🧪 === MANUAL CONNECTION TEST END ===');
  }

  void _showConnectionResultDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hasil Test Koneksi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}