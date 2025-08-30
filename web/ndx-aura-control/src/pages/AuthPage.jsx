import React, { useState } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { useNavigate } from 'react-router-dom';
import { useToast } from '@/hooks/use-toast';

export default function AuthPage() {
  const { login, loading } = useAuth();
  const navigate = useNavigate();
  const { toast } = useToast();
  const [isLoading, setIsLoading] = useState(false);

  const handleLogin = async () => {
    setIsLoading(true);
    const result = await login();
    setIsLoading(false);
    
    if (result.success) {
      toast({
        title: "Success",
        description: "Dev token generated and saved successfully!",
      });
      navigate('/');
    } else {
      toast({
        title: "Connection Error",
        description: result.error || "Failed to generate dev token",
        variant: "destructive",
      });
    }
  };

  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-100">
      <div className="bg-white p-8 rounded-lg shadow-md w-full max-w-md">
        <h1 className="text-2xl font-bold text-center mb-6">NDX Dashboard Login</h1>
        <p className="text-sm text-gray-600 mb-4">
          Click to get a debug token from NDX server.
        </p>
        <button
          onClick={handleLogin}
          disabled={isLoading || loading}
          className="w-full bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-600 disabled:opacity-50"
        >
          {isLoading || loading ? 'Logging in...' : 'Get Debug Token'}
        </button>
      </div>
    </div>
  );
}
