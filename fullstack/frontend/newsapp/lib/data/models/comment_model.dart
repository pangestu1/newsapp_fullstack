import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final int id;
  final String content;
  final int newsId;
  final int userId;
  final String userName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Comment({
    required this.id,
    required this.content,
    required this.newsId,
    required this.userId,
    required this.userName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      newsId: json['news_id'],
      userId: json['user_id'],
      userName: json['user_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'news_id': newsId,
    };
  }

  @override
  List<Object?> get props => [id, content, newsId, userId, userName];
}