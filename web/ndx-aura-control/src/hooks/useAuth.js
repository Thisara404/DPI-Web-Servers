import { useState, useEffect } from 'react';
import { getDevToken } from '@/api/ndxApi';

export function useAuth() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem('jwt');
    setIsAuthenticated(!!token);
    setLoading(false);
  }, []);

  const login = async () => {
    try {
      const res = await getDevToken();
      if (res.data.success && res.data.token) {
        localStorage.setItem('jwt', res.data.token);
        setIsAuthenticated(true);
        return true;
      } else {
        throw new Error(res.data.message || 'Failed to get token');
      }
    } catch (err) {
      console.error('Login failed:', err);
      return false;
    }
  };

  const logout = () => {
    localStorage.removeItem('jwt');
    setIsAuthenticated(false);
  };

  return { isAuthenticated, loading, login, logout };
}
