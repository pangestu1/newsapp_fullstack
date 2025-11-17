import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsapp/presentation/blocs/auth/auth_event.dart';
import 'package:newsapp/presentation/blocs/auth/auth_state.dart';
import 'package:newsapp/presentation/blocs/news/news_event.dart';
import 'package:newsapp/presentation/blocs/news/news_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/news/news_bloc.dart';
import '../../../data/models/news_model.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/news_card.dart';
import '../profile/profile_page.dart';
import 'create_news_page.dart';
import 'news_detail_page.dart';
import 'edit_news_page.dart';

class NewsListPage extends StatefulWidget {
  const NewsListPage({super.key});

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  int _currentPage = 1;
  String _searchQuery = '';
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadNews();
    _scrollController.addListener(_onScroll);
  }

  void _loadNews() {
    context.read<NewsBloc>().add(
          LoadNewsEvent(
            page: _currentPage,
            limit: 10,
            search: _searchQuery,
          ),
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _hasMore &&
        !_isLoadingMore) {
      _loadMoreNews();
    }
  }

  void _loadMoreNews() {
    if (!_isLoadingMore && _hasMore) {
      setState(() {
        _isLoadingMore = true;
      });
      context.read<NewsBloc>().add(
            LoadNewsEvent(
              page: _currentPage + 1,
              limit: 10,
              search: _searchQuery,
            ),
          );
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
      _hasMore = true;
      _isLoadingMore = false;
    });
    context.read<NewsBloc>().add(
          LoadNewsEvent(
            page: 1,
            limit: 10,
            search: query,
          ),
        );
  }

  void _refreshNews() {
    setState(() {
      _currentPage = 1;
      _hasMore = true;
      _isLoadingMore = false;
    });
    context.read<NewsBloc>().add(
          LoadNewsEvent(
            page: 1,
            limit: 10,
            search: _searchQuery,
          ),
        );
  }

  void _showDeleteDialog(News news) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Berita'),
        content: Text('Apakah Anda yakin ingin menghapus "${news.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NewsBloc>().add(DeleteNewsEvent(newsId: news.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
    _refreshNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita Terkini'),
        actions: [
          // Search Icon
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NewsSearchDelegate(
                  onSearch: _onSearch,
                  searchController: _searchController,
                ),
              );
            },
          ),
          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNews,
          ),
          // User Menu
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return PopupMenuButton<String>(
                  icon: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      state.user.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'logout') {
                      _showLogoutDialog();
                    } else if (value == 'profile') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfilePage()),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'profile',
                      child: Row(
                        children: [
                          const Icon(Icons.person, size: 20),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.user.role.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Logout', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated &&
              (state.user.role == 'admin' || state.user.role == 'penulis')) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateNewsPage(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox();
        },
      ),
      body: BlocConsumer<NewsBloc, NewsState>(
        listener: (context, state) {
          if (state is NewsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
            setState(() {
              _isLoadingMore = false;
            });
          }
          
          if (state is NewsLoaded) {
            setState(() {
              _isLoadingMore = false;
              _currentPage = state.newsResponse.page;
              _hasMore = state.newsResponse.news.length < state.newsResponse.total;
            });
          }

          if (state is NewsOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            _refreshNews();
          }
        },
        builder: (context, state) {
          // Initial loading
          if (state is NewsLoading && _currentPage == 1) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat berita...'),
                ],
              ),
            );
          }

          // Error state on first load
          if (state is NewsError && _currentPage == 1) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _refreshNews,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          // Loaded state
          if (state is NewsLoaded) {
            final news = state.newsResponse.news;
            final totalNews = state.newsResponse.total;
            final hasReachedMax = !_hasMore;

            if (news.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Tidak ada berita ditemukan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (_searchQuery.isNotEmpty)
                      Column(
                        children: [
                          Text(
                            'Untuk pencarian: "$_searchQuery"',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _clearSearch,
                            child: const Text('Hapus Pencarian'),
                          ),
                        ],
                      )
                    else
                      const Text(
                        'Belum ada berita yang dipublikasikan',
                        style: TextStyle(color: Colors.grey),
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _refreshNews,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Muat Ulang'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Search info bar
                if (_searchQuery.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.blue[50],
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Menampilkan ${news.length} dari $totalNews hasil untuk "$_searchQuery"',
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: _clearSearch,
                        ),
                      ],
                    ),
                  ),

                // News list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _refreshNews();
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: news.length + (_isLoadingMore ? 1 : 0) + (hasReachedMax ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Loading more indicator
                        if (index == news.length && _isLoadingMore) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 8),
                                  Text('Memuat lebih banyak...'),
                                ],
                              ),
                            ),
                          );
                        }

                        // End of list indicator
                        if (index == news.length && hasReachedMax) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Column(
                                children: [
                                  const Icon(Icons.check_circle_outline, 
                                      size: 24, color: Colors.green),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Semua $totalNews berita telah dimuat',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // News items
                        if (index < news.length) {
                          final currentNews = news[index];
                          final currentUser = _getCurrentUser(context);

                          return NewsCard(
                            news: currentNews,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NewsDetailPage(newsId: currentNews.id),
                                ),
                              );
                            },
                            onEdit: (currentUser?.role == 'admin' ||
                                    currentUser?.id == currentNews.authorId)
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditNewsPage(news: currentNews),
                                      ),
                                    );
                                  }
                                : null,
                            onDelete: (currentUser?.role == 'admin' ||
                                    currentUser?.id == currentNews.authorId)
                                ? () => _showDeleteDialog(currentNews)
                                : null,
                            showActions: currentUser?.role == 'admin' ||
                                currentUser?.id == currentNews.authorId,
                            isAuthor: currentUser?.id == currentNews.authorId,
                          );
                        }

                        return const SizedBox();
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          // Default loading
          return const Center(child: CircularProgressIndicator());
        },
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutEvent());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class NewsSearchDelegate extends SearchDelegate {
  final Function(String) onSearch;
  final TextEditingController searchController;

  NewsSearchDelegate({
    required this.onSearch,
    required this.searchController,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            searchController.clear();
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildRecentSearches(context);
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return BlocBuilder<NewsBloc, NewsState>(
      builder: (context, state) {
        if (state is NewsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is NewsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
              ],
            ),
          );
        }

        if (state is NewsLoaded) {
          final news = state.newsResponse.news;
          final currentUser = _getCurrentUser(context);

          if (news.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Tidak ada hasil ditemukan',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Untuk "$query"',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: news.length,
            itemBuilder: (context, index) {
              final currentNews = news[index];
              return NewsCard(
                news: currentNews,
                onTap: () {
                  close(context, null);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailPage(newsId: currentNews.id),
                    ),
                  );
                },
                onEdit: (currentUser?.role == 'admin' ||
                        currentUser?.id == currentNews.authorId)
                    ? () {
                        close(context, null);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditNewsPage(news: currentNews),
                          ),
                        );
                      }
                    : null,
                onDelete: (currentUser?.role == 'admin' ||
                        currentUser?.id == currentNews.authorId)
                    ? () {
                        close(context, null);
                        _showDeleteDialog(context, currentNews);
                      }
                    : null,
                showActions: currentUser?.role == 'admin' ||
                    currentUser?.id == currentNews.authorId,
                isAuthor: currentUser?.id == currentNews.authorId,
              );
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    // Placeholder for recent searches
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Pencarian Terakhir',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Teknologi'),
                onTap: () {
                  query = 'Teknologi';
                  showResults(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Olahraga'),
                onTap: () {
                  query = 'Olahraga';
                  showResults(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Politik'),
                onTap: () {
                  query = 'Politik';
                  showResults(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  User? _getCurrentUser(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user;
    }
    return null;
  }

  void _showDeleteDialog(BuildContext context, News news) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Berita'),
        content: Text('Apakah Anda yakin ingin menghapus "${news.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NewsBloc>().add(DeleteNewsEvent(newsId: news.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}