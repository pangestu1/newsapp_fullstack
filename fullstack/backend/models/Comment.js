const db = require('../config/database');

const Comment = {
  create: (commentData, callback) => {
    const query = 'INSERT INTO comments (content, news_id, user_id) VALUES (?, ?, ?)';
    db.query(query, [commentData.content, commentData.news_id, commentData.user_id], callback);
  },
  
  getByNewsId: (newsId, callback) => {
    const query = 'SELECT c.*, u.name as user_name FROM comments c JOIN users u ON c.user_id = u.id WHERE c.news_id = ? ORDER BY c.created_at DESC';
    db.query(query, [newsId], callback);
  },
  
  delete: (id, callback) => {
    const query = 'DELETE FROM comments WHERE id = ?';
    db.query(query, [id], callback);
  }
};

module.exports = Comment;