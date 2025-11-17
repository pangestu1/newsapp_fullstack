// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsapp/presentation/blocs/auth/auth_event.dart';
import 'package:newsapp/presentation/blocs/auth/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'core/network/dio_client.dart';

// Data - Repositories
import 'data/repositories/auth_repository.dart';
import 'data/repositories/news_repository.dart';
import 'data/repositories/comment_repository.dart';
import 'data/repositories/user_repository.dart';

// Presentation - Blocs
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/news/news_bloc.dart';
import 'presentation/blocs/comment/comment_bloc.dart';
import 'presentation/blocs/user/user_bloc.dart';

// Presentation - Pages
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/news/news_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize shared preferences
  await SharedPreferences.getInstance();
  
  // Simple connection test
  await _testConnection();
  
  runApp(const MyApp());
}

// Simple connection test function
Future<void> _testConnection() async {
  print('🚀 Starting NewsApp...');
  print('💻 Backend URL: http://10.156.179.5:5000/api');
  print('⏰ ${DateTime.now()}');
  print('');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize DioClient
    final DioClient dioClient = DioClient();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(dioClient: dioClient),
        ),
        RepositoryProvider<NewsRepository>(
          create: (context) => NewsRepository(dioClient: dioClient),
        ),
        RepositoryProvider<CommentRepository>(
          create: (context) => CommentRepository(dioClient: dioClient),
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepository(dioClient: dioClient),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(AuthCheckEvent()),
          ),
          BlocProvider<NewsBloc>(
            create: (context) => NewsBloc(
              newsRepository: context.read<NewsRepository>(),
            ),
          ),
          BlocProvider<CommentBloc>(
            create: (context) => CommentBloc(
              commentRepository: context.read<CommentRepository>(),
            ),
          ),
          BlocProvider<UserBloc>(
            create: (context) => UserBloc(
              userRepository: context.read<UserRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'NewsApp',
          theme: _buildThemeData(),
          debugShowCheckedModeBanner: false,
          home: const AppContent(),
        ),
      ),
    );
  }
}

class AppContent extends StatelessWidget {
  const AppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return _buildLoadingScreen();
        }

        if (state is AuthUnauthenticated) {
          return const LoginPage();
        }

        if (state is AuthAuthenticated) {
          return const NewsListPage();
        }

        if (state is AuthError) {
          return _buildErrorScreen(state.message, context);
        }

        return _buildLoadingScreen();
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.newspaper,
                size: 50,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'NewsApp',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String message, BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                'Connection Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(AuthCheckEvent());
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

ThemeData _buildThemeData() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    useMaterial3: true,
  );
}