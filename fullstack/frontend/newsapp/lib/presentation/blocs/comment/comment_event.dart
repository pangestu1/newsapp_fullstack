// ignore_for_file: unused_import

import 'package:equatable/equatable.dart';
import '../../../data/models/comment_model.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object> get props => [];
}

class LoadCommentsEvent extends CommentEvent {
  final int newsId;

  const LoadCommentsEvent({required this.newsId});

  @override
  List<Object> get props => [newsId];
}

class CreateCommentEvent extends CommentEvent {
  final String content;
  final int newsId;

  const CreateCommentEvent({required this.content, required this.newsId});

  @override
  List<Object> get props => [content, newsId];
}

class DeleteCommentEvent extends CommentEvent {
  final int commentId;
  final int newsId; // Untuk refresh list setelah delete

  const DeleteCommentEvent({required this.commentId, required this.newsId});

  @override
  List<Object> get props => [commentId, newsId];
}

class UpdateCommentEvent extends CommentEvent {
  final int commentId;
  final String content;
  final int newsId;

  const UpdateCommentEvent({
    required this.commentId,
    required this.content,
    required this.newsId,
  });

  @override
  List<Object> get props => [commentId, content, newsId];
}