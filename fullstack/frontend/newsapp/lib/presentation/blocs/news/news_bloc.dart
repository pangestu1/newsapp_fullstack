import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/news_repository.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository newsRepository;

  NewsBloc({required this.newsRepository}) : super(NewsInitial()) {
    on<LoadNewsEvent>(_onLoadNews);
    on<LoadNewsDetailEvent>(_onLoadNewsDetail);
    on<CreateNewsEvent>(_onCreateNews);
    on<UpdateNewsEvent>(_onUpdateNews);
    on<DeleteNewsEvent>(_onDeleteNews);
  }

  Future<void> _onLoadNews(LoadNewsEvent event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    final response = await newsRepository.getNews(
      page: event.page,
      limit: event.limit,
      search: event.search,
    );
    
    if (response.success && response.data != null) {
      emit(NewsLoaded(newsResponse: response.data!));
    } else {
      emit(NewsError(message: response.message));
    }
  }

  Future<void> _onLoadNewsDetail(LoadNewsDetailEvent event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    final response = await newsRepository.getNewsDetail(event.newsId);
    
    if (response.success && response.data != null) {
      emit(NewsDetailLoaded(news: response.data!));
    } else {
      emit(NewsError(message: response.message));
    }
  }

  Future<void> _onCreateNews(CreateNewsEvent event, Emitter<NewsState> emit) async {
    final response = await newsRepository.createNews(
      title: event.title,
      content: event.content,
      imagePath: event.imagePath,
    );
    
    if (response.success) {
      emit(NewsOperationSuccess(message: response.message));
      // Reload news list after creation
      add(const LoadNewsEvent());
    } else {
      emit(NewsError(message: response.message));
    }
  }

  Future<void> _onUpdateNews(UpdateNewsEvent event, Emitter<NewsState> emit) async {
    final response = await newsRepository.updateNews(
      id: event.newsId,
      title: event.title,
      content: event.content,
      imagePath: event.imagePath,
    );
    
    if (response.success) {
      emit(NewsOperationSuccess(message: response.message));
      // Reload news detail after update
      add(LoadNewsDetailEvent(newsId: event.newsId));
    } else {
      emit(NewsError(message: response.message));
    }
  }

  Future<void> _onDeleteNews(DeleteNewsEvent event, Emitter<NewsState> emit) async {
    final response = await newsRepository.deleteNews(event.newsId);
    
    if (response.success) {
      emit(NewsOperationSuccess(message: response.message));
      // Reload news list after deletion
      add(const LoadNewsEvent());
    } else {
      emit(NewsError(message: response.message));
    }
  }
}