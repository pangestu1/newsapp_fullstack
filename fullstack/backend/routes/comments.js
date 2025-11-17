const express = require('express');
const { createComment, getCommentsByNews, deleteComment } = require('../controllers/commentController');
const auth = require('../middleware/auth');
const router = express.Router();

router.post('/', auth(['admin', 'penulis', 'pembaca']), createComment);
router.get('/news/:newsId', getCommentsByNews);
router.delete('/:id', auth(['admin']), deleteComment);

module.exports = router;