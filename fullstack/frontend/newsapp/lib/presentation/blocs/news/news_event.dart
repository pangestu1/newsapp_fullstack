import 'package:equatable/equatable.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object> get props => [];
}

class LoadNewsEvent extends NewsEvent {
  final int page;
  final int limit;
  final String search;

  const LoadNewsEvent({
    this.page = 1,
    this.limit = 10,
    this.search = '',
  });

  @override
  List<Object> get props => [page, limit, search];
}

class LoadNewsDetailEvent extends NewsEvent {
  final int newsId;

  const LoadNewsDetailEvent({required this.newsId});

  @override
  List<Object> get props => [newsId];
}

class CreateNewsEvent extends NewsEvent {
  final String title;
  final String content;
  final String? imagePath;

  const CreateNewsEvent({
    required this.title,
    required this.content,
    this.imagePath,
  });

  @override
  List<Object> get props => [title, content];
}

class UpdateNewsEvent extends NewsEvent {
  final int newsId;
  final String title;
  final String content;
  final String? imagePath;

  const UpdateNewsEvent({
    required this.newsId,
    required this.title,
    required this.content,
    this.imagePath,
  });

  @override
  List<Object> get props => [newsId, title, content];
}

class DeleteNewsEvent extends NewsEvent {
  final int newsId;

  const DeleteNewsEvent({required this.newsId});

  @override
  List<Object> get props => [newsId];
}