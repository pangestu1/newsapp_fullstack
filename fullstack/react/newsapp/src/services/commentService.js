// src/services/commentService.js
import api from './api';

// Mock data untuk testing
// 
const mockComments = [
  {
    id: 1,
    news_id: 1,
    user_id: 2,
    user_name: 'akbar',
    user_role: 'pembaca',
    content: 'Berita yang sangat informatif!',
    created_at: '2024-12-12T10:30:00.000Z'
  },
  {
    id: 2,
    news_id: 1,
    user_id: 1,
    user_name: 'admin',
    user_role: 'admin',
    content: 'Terima kasih sudah membaca!',
    created_at: '2024-12-12T11:00:00.000Z'
  },
  {
    id: 3,
    news_id: 2,
    user_id: 2,
    user_name: 'akbar',
    user_role: 'pembaca',
    content: 'Timnas Indonesia pasti bisa lebih baik lagi!',
    created_at: '2024-12-12T12:00:00.000Z'
  }
];

export const commentService = {
  // Get comments by news ID
  async getCommentsByNewsId(newsId) {
    try {
      const response = await api.get(`/comments/${newsId}`);
      console.log('Comments response from API:', response.data);
      return response.data;
    } catch (error) {
      console.warn('API comments not available, using mock data:', error.message);
      // Fallback ke mock data
      const filteredComments = mockComments.filter(comment => comment.news_id === parseInt(newsId));
      console.log('Using mock comments:', filteredComments);
      return filteredComments;
    }
  },

  // Create new comment
  async createComment(commentData) {
    try {
      console.log('Sending comment to API:', commentData);
      const response = await api.post('/comments', commentData);
      console.log('Comment created:', response.data);
      return response.data;
    } catch (error) {
      console.warn('API not available, simulating comment creation:', error.message);
      // Simulasi success response
      const mockResponse = {
        id: Date.now(),
        ...commentData,
        created_at: new Date().toISOString()
      };
      // Tambahkan ke mock data untuk future reference
      mockComments.push(mockResponse);
      return mockResponse;
    }
  },

  // Update comment
  async updateComment(id, commentData) {
    try {
      const response = await api.put(`/comments/${id}`, commentData);
      return response.data;
    } catch (error) {
      console.error('Error updating comment:', error);
      throw error;
    }
  },

  // Delete comment
  async deleteComment(id) {
    try {
      const response = await api.delete(`/comments/${id}`);
      return response.data;
    } catch (error) {
      console.warn('API not available, simulating comment deletion:', error.message);
      // Simulasi deletion dari mock data
      const index = mockComments.findIndex(comment => comment.id === parseInt(id));
      if (index !== -1) {
        mockComments.splice(index, 1);
      }
      return { success: true, message: 'Comment deleted (simulated)' };
    }
  },

  // Get comment count for news
  async getCommentCount(newsId) {
    try {
      const response = await api.get(`/comments/${newsId}/count`);
      return response.data;
    } catch (error) {
      console.warn('API not available, counting from mock data:', error.message);
      // Hitung dari mock data
      const count = mockComments.filter(comment => comment.news_id === parseInt(newsId)).length;
      return { count };
    }
  }
};