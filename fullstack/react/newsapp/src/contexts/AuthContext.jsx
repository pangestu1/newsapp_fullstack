import React, { createContext, useState, useContext, useEffect } from 'react';
import { authService } from '../services/authService';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const currentUser = authService.getCurrentUser();
    console.log('AuthProvider init - User:', currentUser);
    
    if (currentUser) {
      setUser(currentUser);
    }
    setLoading(false);
  }, []);

  const login = async (credentials) => {
    try {
      console.log('Login attempt with:', credentials);
      const data = await authService.login(credentials);
      console.log('Login successful, user data:', data.user);
      
      setUser(data.user);
      return { success: true };
    } catch (error) {
      console.error('Login error in context:', error);
      return { 
        success: false, 
        message: error.response?.data?.message || 'Login failed' 
      };
    }
  };

  const register = async (userData) => {
    try {
      const data = await authService.register(userData);
      return { success: true, data };
    } catch (error) {
      console.error('Register error:', error);
      return { 
        success: false, 
        message: error.response?.data?.message || 'Registration failed' 
      };
    }
  };

  const logout = () => {
    console.log('Logout called');
    authService.logout();
    setUser(null);
  };

  // Helper functions untuk cek role
  const isAdmin = () => user?.role === 'admin';
  const isPenulis = () => user?.role === 'penulis';
  const isPembaca = () => user?.role === 'pembaca';
  const canCreate = () => isAdmin() || isPenulis();
  const canEdit = (authorId) => isAdmin() || (isPenulis() && user?.id === authorId);
  const canDelete = (authorId) => isAdmin() || (isPenulis() && user?.id === authorId);

  return (
    <AuthContext.Provider value={{ 
      user, 
      login, 
      register, 
      logout, 
      loading,
      isAdmin,
      isPenulis,
      isPembaca,
      canCreate,
      canEdit,
      canDelete
    }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};