import 'package:equatable/equatable.dart';
import '../../../data/models/news_model.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final NewsResponse newsResponse;

  const NewsLoaded({required this.newsResponse});

  @override
  List<Object> get props => [newsResponse];
}

class NewsDetailLoaded extends NewsState {
  final News news;

  const NewsDetailLoaded({required this.news});

  @override
  List<Object> get props => [news];
}

class NewsOperationSuccess extends NewsState {
  final String message;

  const NewsOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class NewsError extends NewsState {
  final String message;

  const NewsError({required this.message});

  @override
  List<Object> get props => [message];
}