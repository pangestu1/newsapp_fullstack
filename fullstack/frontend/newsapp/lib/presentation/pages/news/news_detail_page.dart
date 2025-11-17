import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:newsapp/presentation/blocs/auth/auth_state.dart';
import 'package:newsapp/presentation/blocs/comment/comment_event.dart';
import 'package:newsapp/presentation/blocs/comment/comment_state.dart';
import 'package:newsapp/presentation/blocs/news/news_event.dart';
import 'package:newsapp/presentation/blocs/news/news_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/news/news_bloc.dart';
import '../../blocs/comment/comment_bloc.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/comment_card.dart';
import 'edit_news_page.dart';

class NewsDetailPage extends StatefulWidget {
  final int newsId;

  const NewsDetailPage({super.key, required this.newsId});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadNewsDetail();
    _loadComments();
  }

  void _loadNewsDetail() {
    context.read<NewsBloc>().add(LoadNewsDetailEvent(newsId: widget.newsId));
  }

  void _loadComments() {
    context.read<CommentBloc>().add(LoadCommentsEvent(newsId: widget.newsId));
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    context.read<CommentBloc>().add(
          CreateCommentEvent(
            content: _commentController.text.trim(),
            newsId: widget.newsId,
          ),
        );

    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  void _deleteComment(int commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Komentar'),
        content: const Text('Apakah Anda yakin ingin menghapus komentar ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CommentBloc>().add(
                    DeleteCommentEvent(
                      commentId: commentId,
                      newsId: widget.newsId,
                    ),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _editNews() {
    final newsState = context.read<NewsBloc>().state;
    if (newsState is NewsDetailLoaded) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditNewsPage(news: newsState.news),
        ),
      );
    }
  }

  void _deleteNews() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Berita'),
        content: const Text('Apakah Anda yakin ingin menghapus berita ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NewsBloc>().add(DeleteNewsEvent(newsId: widget.newsId));
              Navigator.pop(context); // Kembali ke list
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Berita'),
        actions: [
          BlocBuilder<NewsBloc, NewsState>(
            builder: (context, state) {
              if (state is NewsDetailLoaded) {
                final currentUser = _getCurrentUser(context);
                final canEdit = currentUser?.role == 'admin' ||
                    currentUser?.id == state.news.authorId;

                if (canEdit) {
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editNews();
                      } else if (value == 'delete') {
                        _deleteNews();
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit Berita'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus Berita', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          if (state is NewsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NewsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadNewsDetail,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state is NewsDetailLoaded) {
            final news = state.news;
            final currentUser = _getCurrentUser(context);

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gambar berita
                        if (news.image != null)
                          CachedNetworkImage(
                            imageUrl: news.imageUrl,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 250,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 250,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          ),

                        // Konten berita
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Judul
                              Text(
                                news.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Info penulis dan waktu
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.blue[100],
                                    child: Text(
                                      news.authorName[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          news.authorName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('dd MMMM yyyy • HH:mm').format(news.createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Konten
                              Text(
                                news.content,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(height: 32),

                              // Section komentar
                              _buildCommentsSection(news.id, currentUser),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Input komentar
                if (currentUser != null) _buildCommentInput(),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildCommentsSection(int newsId, User? currentUser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Komentar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        BlocBuilder<CommentBloc, CommentState>(
          builder: (context, state) {
            if (state is CommentLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CommentError) {
              return Center(
                child: Column(
                  children: [
                    Text(state.message),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadComments,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            if (state is CommentLoaded) {
              final comments = state.comments;

              if (comments.isEmpty) {
                return const Center(
                  child: Column(
                    children: [
                      Icon(Icons.comment_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Belum ada komentar'),
                      SizedBox(height: 8),
                      Text(
                        'Jadilah yang pertama berkomentar!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: comments.map((comment) {
                  final isCurrentUser = currentUser?.id == comment.userId;
                  final canDelete = currentUser?.role == 'admin' || isCurrentUser;

                  return CommentCard(
                    comment: comment,
                    isCurrentUser: isCurrentUser,
                    onDelete: canDelete ? () => _deleteComment(comment.id) : null,
                    showActions: canDelete,
                  );
                }).toList(),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Tulis komentar...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _addComment(),
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<CommentBloc, CommentState>(
            builder: (context, state) {
              return IconButton(
                onPressed: state is CommentLoading ? null : _addComment,
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                icon: state is CommentLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send),
              );
            },
          ),
        ],
      ),
    );
  }

  User? _getCurrentUser(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user;
    }
    return null;
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}