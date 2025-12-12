import api from './api';

export const newsService = {
  async getAllNews() {
    try {
      const response = await api.get('/news');
      if (response.data && Array.isArray(response.data.news)) {
        return response.data.news;
      } else {
        console.error('Data tidak valid atau news bukan array:', response.data);
        return [];
      }
    } catch (error) {
      console.error('Error fetching news:', error);
      return [];
    }
  },

  async getNewsById(id) {
    try {
      const response = await api.get(`/news/${id}`);
      return response.data;
    } catch (error) {
      console.error('Error fetching news by id:', error);
      throw error;
    }
  },

  async createNews(newsData) {
    try {
      const formData = new FormData();
      formData.append('title', newsData.title);
      formData.append('content', newsData.content);
      
      if (newsData.image) {
        formData.append('image', newsData.image);
      }
      
      const response = await api.post('/news', formData, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      });
      return response.data;
    } catch (error) {
      console.error('Error creating news:', error);
      throw error;
    }
  },

  async updateNews(id, newsData) {
    try {
      const formData = new FormData();
      formData.append('title', newsData.title);
      formData.append('content', newsData.content);
      
      if (newsData.image) {
        formData.append('image', newsData.image);
      }
      
      if (newsData.removeImage) {
        formData.append('removeImage', 'true');
      }
      
      const response = await api.put(`/news/${id}`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      });
      return response.data;
    } catch (error) {
      console.error('Error updating news:', error);
      throw error;
    }
  },

  async deleteNews(id) {
    try {
      const response = await api.delete(`/news/${id}`);
      return response.data;
    } catch (error) {
      console.error('Error deleting news:', error);
      throw error;
    }
  }
};