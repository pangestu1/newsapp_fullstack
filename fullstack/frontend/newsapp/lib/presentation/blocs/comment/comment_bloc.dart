import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/comment_repository.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentRepository commentRepository;

  CommentBloc({required this.commentRepository}) : super(CommentInitial()) {
    on<LoadCommentsEvent>(_onLoadComments);
    on<CreateCommentEvent>(_onCreateComment);
    on<DeleteCommentEvent>(_onDeleteComment);
    on<UpdateCommentEvent>(_onUpdateComment);
  }

  Future<void> _onLoadComments(LoadCommentsEvent event, Emitter<CommentState> emit) async {
    emit(CommentLoading());
    final response = await commentRepository.getCommentsByNews(event.newsId);
    
    if (response.success && response.data != null) {
      emit(CommentLoaded(comments: response.data!));
    } else {
      emit(CommentError(message: response.message));
    }
  }

  Future<void> _onCreateComment(CreateCommentEvent event, Emitter<CommentState> emit) async {
    final response = await commentRepository.createComment(
      content: event.content,
      newsId: event.newsId,
    );
    
    if (response.success) {
      // Reload comments after successful creation
      add(LoadCommentsEvent(newsId: event.newsId));
      emit(CommentOperationSuccess(message: response.message));
    } else {
      emit(CommentError(message: response.message));
    }
  }

  Future<void> _onDeleteComment(DeleteCommentEvent event, Emitter<CommentState> emit) async {
    final response = await commentRepository.deleteComment(event.commentId);
    
    if (response.success) {
      // Reload comments after successful deletion
      add(LoadCommentsEvent(newsId: event.newsId));
      emit(CommentOperationSuccess(message: response.message));
    } else {
      emit(CommentError(message: response.message));
    }
  }

  Future<void> _onUpdateComment(UpdateCommentEvent event, Emitter<CommentState> emit) async {
    final response = await commentRepository.updateComment(
      commentId: event.commentId,
      content: event.content,
    );
    
    if (response.success) {
      // Reload comments after successful update
      add(LoadCommentsEvent(newsId: event.newsId));
      emit(CommentOperationSuccess(message: response.message));
    } else {
      emit(CommentError(message: response.message));
    }
  }
}