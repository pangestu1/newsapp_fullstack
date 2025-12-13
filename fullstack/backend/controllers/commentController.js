const Comment = require('../models/Comment');

const createComment = async (req, res) => {
  try {
    const { content, news_id } = req.body;
    
    // Data user harus diambil dari auth token/session
    const commentData = {
      content,
      news_id,
      user_id: req.user.id,
      user_name: req.user.name || req.user.username,
      user_role: req.user.role || 'user'
    };
    
    // Validasi
    if (!content || !news_id) {
      return res.status(400).json({ error: 'Content and news_id are required' });
    }
    
    const newComment = await Comment.create(commentData);
    res.status(201).json({
      message: 'Comment created successfully',
      comment: newComment
    });
  } catch (error) {
    console.error('Error creating comment:', error);
    res.status(500).json({ error: 'Failed to create comment' });
  }
};

const getCommentsByNews = async (req, res) => {
  try {
    const { newsId } = req.params;
    const comments = await Comment.getByNewsId(newsId);
    res.json(comments);
  } catch (error) {
    console.error('Error fetching comments:', error);
    res.status(500).json({ error: 'Failed to fetch comments' });
  }
};

const deleteComment = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Admin can delete any comment, users can only delete their own comments
    if (req.user.role !== 'admin') {
      // Cek apakah komentar milik user ini
      const comment = await Comment.getById(id);
      if (!comment) {
        return res.status(404).json({ error: 'Comment not found' });
      }
      
      if (comment.user_id !== req.user.id) {
        return res.status(403).json({ error: 'You can only delete your own comments' });
      }
    }
    
    const result = await Comment.delete(id);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Comment not found' });
    }
    
    res.json({ 
      success: true, 
      message: 'Comment deleted successfully' 
    });
  } catch (error) {
    console.error('Error deleting comment:', error);
    res.status(500).json({ error: 'Failed to delete comment' });
  }
};

const countCommentsByNews = async (req, res) => {
  try {
    const { newsId } = req.params;
    const result = await Comment.countByNewsId(newsId);
    res.json(result);
  } catch (error) {
    console.error('Error counting comments:', error);
    res.status(500).json({ error: 'Failed to count comments' });
  }
};

module.exports = {
  createComment,
  getCommentsByNews,
  deleteComment,
  countCommentsByNews
};