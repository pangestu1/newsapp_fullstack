const db = require('../config/database');

const Comment = {
  // Create a new comment
  create: async (commentData) => {
    const { news_id, content, user_id, user_name, user_role } = commentData;
    
    const [result] = await db.query(
      `INSERT INTO comments (news_id, content, user_id, user_name, user_role) 
       VALUES (?, ?, ?, ?, ?)`,
      [news_id, content, user_id, user_name, user_role]
    );
    
    // Return the newly created comment
    const [newComment] = await db.query(
      `SELECT * FROM comments WHERE id = ?`,
      [result.insertId]
    );
    
    return newComment[0];
  },

  // Get comments by news ID
  getByNewsId: async (newsId) => {
    const [comments] = await db.query(
      `SELECT * FROM comments WHERE news_id = ? ORDER BY created_at DESC`,
      [newsId]
    );
    return comments;
  },

  // Get single comment by ID
  getById: async (id) => {
    const [comments] = await db.query(
      `SELECT * FROM comments WHERE id = ?`,
      [id]
    );
    return comments[0];
  },

  // Delete comment
  delete: async (id) => {
    const [result] = await db.query(
      `DELETE FROM comments WHERE id = ?`,
      [id]
    );
    return result;
  },

  // Count comments by news ID
  countByNewsId: async (newsId) => {
    const [[result]] = await db.query(
      `SELECT COUNT(*) as count FROM comments WHERE news_id = ?`,
      [newsId]
    );
    return result;
  },

  // Update comment (jika diperlukan di masa depan)
  update: async (id, content) => {
    const [result] = await db.query(
      `UPDATE comments SET content = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?`,
      [content, id]
    );
    
    if (result.affectedRows > 0) {
      const [updatedComment] = await db.query(
        `SELECT * FROM comments WHERE id = ?`,
        [id]
      );
      return updatedComment[0];
    }
    return null;
  }
};

module.exports = Comment;