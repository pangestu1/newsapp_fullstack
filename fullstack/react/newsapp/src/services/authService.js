import api from './api';

export const authService = {
  async register(userData) {
    const response = await api.post('/auth/register', userData);
    console.log('Register response:', response.data);
    return response.data;
  },

  async login(credentials) {
    try {
      const response = await api.post('/auth/login', credentials);
      console.log('Login response:', response.data);
      
      const responseData = response.data;
      
      let token, user;
      
      if (responseData.token) {
        token = responseData.token;
        user = responseData.user || responseData;
      } else if (responseData.data && responseData.data.token) {
        token = responseData.data.token;
        user = responseData.data.user || responseData.data;
      }
      
      if (token) {
        localStorage.setItem('token', token);
        localStorage.setItem('user', JSON.stringify(user));
        console.log('Token saved:', token);
        console.log('User saved:', user);
      } else {
        console.warn('No token found in response');
      }
      
      return responseData;
    } catch (error) {
      console.error('Login error:', error.response?.data || error.message);
      throw error;
    }
  },

  logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  },

  getCurrentUser() {
    const userStr = localStorage.getItem('user');
    return userStr ? JSON.parse(userStr) : null;
  },

  isAuthenticated() {
    const token = localStorage.getItem('token');
    return !!token;
  }
};