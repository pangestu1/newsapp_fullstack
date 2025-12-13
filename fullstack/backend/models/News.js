const db = require('../config/database');

const News = {
  create: (newsData, callback) => {
    const query = 'INSERT INTO news (title, content, image, author_id) VALUES (?, ?, ?, ?)';
    db.query(query, [newsData.title, newsData.content, newsData.image, newsData.author_id], callback);
  },
  
  getAll: (page, limit, search, callback) => {
    const offset = (page - 1) * limit;
    let query = 'SELECT n.*, u.name as author_name FROM news n JOIN users u ON n.author_id = u.id';
    let countQuery = 'SELECT COUNT(*) as total FROM news n JOIN users u ON n.author_id = u.id';
    
    if (search) {
      query += ` WHERE n.title LIKE '%${search}%' OR n.content LIKE '%${search}%'`;
      countQuery += ` WHERE n.title LIKE '%${search}%' OR n.content LIKE '%${search}%'`;
    }
    
    query += ' ORDER BY n.created_at DESC LIMIT ? OFFSET ?';
    
    db.query(countQuery, (err, countResult) => {
      if (err) return callback(err);
      
      db.query(query, [limit, offset], (err, results) => {
        if (err) return callback(err);
        
        callback(null, {
          news: results,
          total: countResult[0].total,
          page: page,
          totalPages: Math.ceil(countResult[0].total / limit)
        });
      });
    });
  },
  
  getById: (id, callback) => {
    const query = 'SELECT n.*, u.name as author_name FROM news n JOIN users u ON n.author_id = u.id WHERE n.id = ?';
    db.query(query, [id], callback);
  },
  
  update: (id, newsData, callback) => {
    const query = 'UPDATE news SET title = ?, content = ?, image = ? WHERE id = ?';
    db.query(query, [newsData.title, newsData.content, newsData.image, id], callback);
  },
  
  delete: (id, callback) => {
    const query = 'DELETE FROM news WHERE id = ?';
    db.query(query, [id], callback);
  }
};

module.exports = News;