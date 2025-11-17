import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthCheckEvent>(_onCheckAuth);
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final response = await authRepository.login(
      email: event.email,
      password: event.password,
    );
    
    if (response.success && response.data != null) {
      emit(AuthAuthenticated(user: response.data!));
    } else {
      emit(AuthError(message: response.message));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onRegister(AuthRegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final response = await authRepository.register(
      name: event.name,
      email: event.email,
      password: event.password,
      role: event.role,
    );
    
    if (response.success && response.data != null) {
      emit(AuthAuthenticated(user: response.data!));
    } else {
      emit(AuthError(message: response.message));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckAuth(AuthCheckEvent event, Emitter<AuthState> emit) async {
    final user = await authRepository.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}