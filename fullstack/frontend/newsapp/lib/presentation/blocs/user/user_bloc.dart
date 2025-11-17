import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<UpdateUserRoleEvent>(_onUpdateUserRole);
    on<SearchUsersEvent>(_onSearchUsers);
  }

  Future<void> _onLoadUsers(LoadUsersEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    final response = await userRepository.getAllUsers();
    
    if (response.success && response.data != null) {
      emit(UserLoaded(users: response.data!));
    } else {
      emit(UserError(message: response.message));
    }
  }

  Future<void> _onUpdateUserRole(UpdateUserRoleEvent event, Emitter<UserState> emit) async {
    final response = await userRepository.updateUserRole(
      userId: event.userId,
      newRole: event.newRole,
    );
    
    if (response.success) {
      // Reload users after successful update
      add(LoadUsersEvent());
      emit(UserOperationSuccess(message: response.message));
    } else {
      emit(UserError(message: response.message));
    }
  }

  Future<void> _onSearchUsers(SearchUsersEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    final response = await userRepository.searchUsers(event.query);
    
    if (response.success && response.data != null) {
      emit(UserLoaded(users: response.data!));
    } else {
      emit(UserError(message: response.message));
    }
  }
}