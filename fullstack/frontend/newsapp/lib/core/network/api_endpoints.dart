class ApiEndpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  
  // News
  static const String news = '/news';
  static String newsDetail(int id) => '/news/$id';
  
  // Comments
  static const String comments = '/comments';
  static String commentsByNews(int newsId) => '/comments/news/$newsId';
  static String commentDetail(int id) => '/comments/$id';
  
  // Users
  static const String users = '/users';
  static String userRole(int userId) => '/users/$userId/role';
}