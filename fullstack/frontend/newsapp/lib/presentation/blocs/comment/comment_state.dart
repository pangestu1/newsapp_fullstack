import 'package:equatable/equatable.dart';
import '../../../data/models/comment_model.dart';

abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentLoaded extends CommentState {
  final List<Comment> comments;

  const CommentLoaded({required this.comments});

  @override
  List<Object> get props => [comments];
}

class CommentOperationSuccess extends CommentState {
  final String message;

  const CommentOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class CommentError extends CommentState {
  final String message;

  const CommentError({required this.message});

  @override
  List<Object> get props => [message];
}