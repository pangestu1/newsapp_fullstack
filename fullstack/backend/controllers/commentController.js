const Comment = require('../models/Comment');

const createComment = (req, res) => {
  try {
    const { content, news_id } = req.body;
    
    const commentData = {
      content,
      news_id,
      user_id: req.user.id
    };
    
    Comment.create(commentData, (err, results) => {
      if (err) {
        return res.status(500).json({ message: 'Error creating comment' });
      }
      
      res.status(201).json({
        message: 'Comment created successfully',
        commentId: results.insertId
      });
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

const getCommentsByNews = (req, res) => {
  try {
    const { newsId } = req.params;
    
    Comment.getByNewsId(newsId, (err, results) => {
      if (err) {
        return res.status(500).json({ message: 'Error fetching comments' });
      }
      
      res.json(results);
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

const deleteComment = (req, res) => {
  try {
    const { id } = req.params;
    
    // Admin can delete any comment, users can only delete their own comments
    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Access denied' });
    }
    
    Comment.delete(id, (err, results) => {
      if (err) {
        return res.status(500).json({ message: 'Error deleting comment' });
      }
      
      if (results.affectedRows === 0) {
        return res.status(404).json({ message: 'Comment not found' });
      }
      
      res.json({ message: 'Comment deleted successfully' });
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  createComment,
  getCommentsByNews,
  deleteComment
};