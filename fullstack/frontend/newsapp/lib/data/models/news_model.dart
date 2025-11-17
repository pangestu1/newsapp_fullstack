import 'package:equatable/equatable.dart';
import 'package:newsapp/core/constants/app_constants.dart';

class News extends Equatable {
  final int id;
  final String title;
  final String content;
  final String? image;
  final int authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const News({
    required this.id,
    required this.title,
    required this.content,
    this.image,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      image: json['image'],
      authorId: json['author_id'],
      authorName: json['author_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'image': image,
    };
  }

  String get imageUrl => image != null 
      ? '${AppConstants.baseUrl.replaceFirst('/api', '')}/uploads/images/$image'
      : '';

  @override
  List<Object?> get props => [id, title, content, image, authorId, authorName];
}

class NewsResponse {
  final List<News> news;
  final int total;
  final int page;
  final int totalPages;

  NewsResponse({
    required this.news,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      news: (json['news'] as List).map((item) => News.fromJson(item)).toList(),
      total: json['total'],
      page: json['page'],
      totalPages: json['totalPages'],
    );
  }
}