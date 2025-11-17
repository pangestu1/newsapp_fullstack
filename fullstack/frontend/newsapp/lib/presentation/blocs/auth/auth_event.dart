import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String role;

  const AuthRegisterEvent({
    required this.name,
    required this.email,
    required this.password,
    this.role = 'pembaca',
  });

  @override
  List<Object> get props => [name, email, password, role];
}

class AuthLogoutEvent extends AuthEvent {}

class AuthCheckEvent extends AuthEvent {}