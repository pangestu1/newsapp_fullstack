import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadUsersEvent extends UserEvent {}

class UpdateUserRoleEvent extends UserEvent {
  final int userId;
  final String newRole;

  const UpdateUserRoleEvent({required this.userId, required this.newRole});

  @override
  List<Object> get props => [userId, newRole];
}

class SearchUsersEvent extends UserEvent {
  final String query;

  const SearchUsersEvent({required this.query});

  @override
  List<Object> get props => [query];
}