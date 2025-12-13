// backend/routes/comments.js
const express = require('express');
const router = express.Router();
const db = require('../config/database'); // Sesuaikan dengan konfigurasi database Anda

// GET /api/comments/:newsId - Get comments by news ID
router.get('/:newsId', async (req, res) => {
  try {
    const newsId = req.params.newsId;
    
    // Query untuk mengambil komentar berdasarkan news_id
    const [comments] = await db.query(
      `SELECT * FROM comments WHERE news_id = ? ORDER BY created_at DESC`,
      [newsId]
    );
    
    res.json(comments);
  } catch (error) {
    console.error('Error fetching comments:', error);
    res.status(500).json({ error: 'Gagal mengambil komentar' });
  }
});

// POST /api/comments - Create new comment
router.post('/', async (req, res) => {
  try {
    const { news_id, content, user_id, user_name, user_role } = req.body;
    
    // Validasi input
    if (!news_id || !content || !user_id || !user_name || !user_role) {
      return res.status(400).json({ error: 'Semua field harus diisi' });
    }
    
    // Insert ke database
    const [result] = await db.query(
      `INSERT INTO comments (news_id, content, user_id, user_name, user_role) 
       VALUES (?, ?, ?, ?, ?)`,
      [news_id, content, user_id, user_name, user_role]
    );
    
    // Ambil data komentar yang baru dibuat
    const [newComment] = await db.query(
      `SELECT * FROM comments WHERE id = ?`,
      [result.insertId]
    );
    
    res.status(201).json(newComment[0]);
  } catch (error) {
    console.error('Error creating comment:', error);
    res.status(500).json({ error: 'Gagal membuat komentar' });
  }
});

// DELETE /api/comments/:id - Delete comment
router.delete('/:id', async (req, res) => {
  try {
    const commentId = req.params.id;
    
    // Cek apakah komentar ada
    const [existingComment] = await db.query(
      `SELECT * FROM comments WHERE id = ?`,
      [commentId]
    );
    
    if (existingComment.length === 0) {
      return res.status(404).json({ error: 'Komentar tidak ditemukan' });
    }
    
    // Hapus komentar
    await db.query(`DELETE FROM comments WHERE id = ?`, [commentId]);
    
    res.json({ success: true, message: 'Komentar berhasil dihapus' });
  } catch (error) {
    console.error('Error deleting comment:', error);
    res.status(500).json({ error: 'Gagal menghapus komentar' });
  }
});

// GET /api/comments/:newsId/count - Get comment count for news
router.get('/:newsId/count', async (req, res) => {
  try {
    const newsId = req.params.newsId;
    
    const [[result]] = await db.query(
      `SELECT COUNT(*) as count FROM comments WHERE news_id = ?`,
      [newsId]
    );
    
    res.json(result);
  } catch (error) {
    console.error('Error counting comments:', error);
    res.status(500).json({ error: 'Gagal menghitung komentar' });
  }
});

module.exports = router;