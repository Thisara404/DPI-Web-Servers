
import { useState } from 'react';
import { generateDevToken } from '../api/ndxApi';

export const useAuth = () => {
  const [loading, setLoading] = useState(false);

  const login = async () => {
    try {
      setLoading(true);
      const response = await generateDevToken();
      
      if (response.data && response.data.token) {
        localStorage.setItem('jwt', response.data.token);
        return { success: true };
      } else {
        return { success: false, error: 'No token received from server' };
      }
    } catch (error) {
      console.error('Login failed:', error);
      let errorMessage = 'Failed to generate dev token';
      
      if (error.code === 'ERR_NETWORK') {
        errorMessage = 'Cannot connect to NDX server. Please ensure the server is running at ' + (import.meta.env.VITE_NDX_URL || 'http://localhost:3000');
      } else if (error.response?.data?.message) {
        errorMessage = error.response.data.message;
      } else if (error.message) {
        errorMessage = error.message;
      }
      
      return { success: false, error: errorMessage };
    } finally {
      setLoading(false);
    }
  };

  const logout = () => {
    localStorage.removeItem('jwt');
  };

  const isAuthenticated = () => {
    return !!localStorage.getItem('jwt');
  };

  return { login, logout, isAuthenticated, loading };
};
