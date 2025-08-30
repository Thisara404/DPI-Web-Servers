
import { useState } from 'react';
import { useAuth } from '../hooks/useAuth';
import { useNavigate } from 'react-router-dom';
import { useToast } from '@/hooks/use-toast';

const AuthPage = () => {
  const { login, loading } = useAuth();
  const navigate = useNavigate();
  const { toast } = useToast();
  const [isLoading, setIsLoading] = useState(false);

  const handleGetDevToken = async () => {
    setIsLoading(true);
    const result = await login();
    
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
    setIsLoading(false);
  };

  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="glass rounded-3xl p-12 text-center max-w-md w-full mx-6 animate-fade-in">
        <div className="w-20 h-20 mx-auto mb-8 rounded-2xl bg-gradient-to-br from-ndx-primary to-ndx-secondary flex items-center justify-center glow-green">
          <span className="text-white font-bold text-2xl">N</span>
        </div>
        
        <h1 className="text-3xl font-semibold text-ndx-light mb-4">
          NDX Dashboard
        </h1>
        
        <p className="text-ndx-light/70 mb-8">
          Generate a development token to access the operator dashboard
        </p>
        
        <button
          onClick={handleGetDevToken}
          disabled={isLoading || loading}
          className="w-full h-14 bg-gradient-to-r from-ndx-primary to-ndx-secondary text-white font-semibold rounded-2xl hover:scale-105 transition-all duration-300 glow-green disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {isLoading || loading ? (
            <div className="flex items-center justify-center space-x-2">
              <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
              <span>Generating...</span>
            </div>
          ) : (
            'Get Dev Token'
          )}
        </button>
        
        <p className="text-ndx-light/50 text-sm mt-6">
          This will connect to {import.meta.env.VITE_NDX_URL || 'http://localhost:3000'}
        </p>
        
        <div className="mt-6 p-4 bg-ndx-alert/10 rounded-xl border border-ndx-alert/20">
          <p className="text-ndx-alert text-sm">
            <strong>Note:</strong> Make sure the NDX server is running before generating a token.
          </p>
        </div>
      </div>
    </div>
  );
};

export default AuthPage;
