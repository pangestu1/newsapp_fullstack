const News = require('../models/News');

const createNews = (req, res) => {
  try {
    const { title, content } = req.body;
    const image = req.file ? req.file.filename : null;
    
    const newsData = {
      title,
      content,
      image,
      author_id: req.user.id
    };
    
    News.create(newsData, (err, results) => {
      if (err) {
        return res.status(500).json({ message: 'Error creating news' });
      }
      
      res.status(201).json({
        message: 'News created successfully',
        newsId: results.insertId
      });
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

const getNews = (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const search = req.query.search || '';
    
    News.getAll(page, limit, search, (err, result) => {
      if (err) {
        return res.status(500).json({ message: 'Error fetching news' });
      }
      
      res.json(result);
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

const getNewsById = (req, res) => {
  try {
    const { id } = req.params;
    
    News.getById(id, (err, results) => {
      if (err) {
        return res.status(500).json({ message: 'Error fetching news' });
      }
      
      if (results.length === 0) {
        return res.status(404).json({ message: 'News not found' });
      }
      
      res.json(results[0]);
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

const updateNews = (req, res) => {
  try {
    const { id } = req.params;
    const { title, content } = req.body;
    const image = req.file ? req.file.filename : undefined;
    
    News.getById(id, (err, results) => {
      if (err) {
        return res.status(500).json({ message: 'Error fetching news' });
      }
      
      if (results.length === 0) {
        return res.status(404).json({ message: 'News not found' });
      }
      
      const news = results[0];
      
      // Check if user is author or admin
      if (news.author_id !== req.user.id && req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Access denied' });
      }
      
      const updateData = {
        title: title || news.title,
        content: content || news.content,
        image: image || news.image
      };
      
      News.update(id, updateData, (err, results) => {
        if (err) {
          return res.status(500).json({ message: 'Error updating news' });
        }
        
        res.json({ message: 'News updated successfully' });
      });
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

const deleteNews = (req, res) => {
  try {
    const { id } = req.params;
    
    News.getById(id, (err, results) => {
      if (err) {
        return res.status(500).json({ message: 'Error fetching news' });
      }
      
      if (results.length === 0) {
        return res.status(404).json({ message: 'News not found' });
      }
      
      const news = results[0];
      
      // Check if user is author or admin
      if (news.author_id !== req.user.id && req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Access denied' });
      }
      
      News.delete(id, (err, results) => {
        if (err) {
          return res.status(500).json({ message: 'Error deleting news' });
        }
        
        res.json({ message: 'News deleted successfully' });
      });
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  createNews,
  getNews,
  getNewsById,
  updateNews,
  deleteNews
};