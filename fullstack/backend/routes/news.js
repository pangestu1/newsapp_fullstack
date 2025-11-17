const express = require('express');
const { createNews, getNews, getNewsById, updateNews, deleteNews } = require('../controllers/newsController');
const auth = require('../middleware/auth');
const upload = require('../middleware/upload');
const router = express.Router();

router.get('/', getNews);
router.get('/:id', getNewsById);
router.post('/', auth(['admin', 'penulis']), upload.single('image'), createNews);
router.put('/:id', auth(['admin', 'penulis']), upload.single('image'), updateNews);
router.delete('/:id', auth(['admin', 'penulis']), deleteNews);

module.exports = router;