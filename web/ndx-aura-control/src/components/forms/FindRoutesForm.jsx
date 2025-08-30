import React, { useState } from 'react';
import { findRoutes } from '@/api/ndxApi';
import { useToast } from '@/hooks/use-toast';
import { MapPin, Route } from 'lucide-react';

export default function FindRoutesForm({ onFind } = {}) {
  const [formData, setFormData] = useState({
    originLat: '',
    originLng: '',
    destLat: '',
    destLng: ''
  });
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);
  const { toast } = useToast();

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!formData.originLat || !formData.originLng || !formData.destLat || !formData.destLng) {
      toast({
        title: "Validation Error",
        description: "Please fill in all coordinate fields",
        variant: "destructive",
      });
      return;
    }

    try {
      setLoading(true);
      const from = `${formData.originLat},${formData.originLng}`;
      const to = `${formData.destLat},${formData.destLng}`;
      
      const response = await findRoutes(from, to);
      const data = response.data?.data || response.data || [];
      setResults(data);
      onFind?.(data);
      
      toast({
        title: "Routes Found",
        description: `Found ${response.data?.length || 0} routes`,
      });
    } catch (error) {
      console.error('Find routes error:', error);
      toast({
        title: "Search Error",
        description: "Failed to find routes",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="mb-4 glass rounded-3xl p-8 animate-fade-in">
      <h2 className="text-2xl font-semibold text-ndx-light mb-6">Find Routes</h2>
      
      <form onSubmit={handleSubmit} className="flex gap-2">
        {/* Origin Coordinates */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-ndx-light/70 mb-2">Origin Latitude</label>
            <input
              type="number"
              name="originLat"
              value={formData.originLat}
              onChange={handleInputChange}
              step="any"
              placeholder="e.g. 40.7128"
              className="input"
            />
          </div>
          <div>
            <label className="block text-ndx-light/70 mb-2">Origin Longitude</label>
            <input
              type="number"
              name="originLng"
              value={formData.originLng}
              onChange={handleInputChange}
              step="any"
              placeholder="e.g. -74.0060"
              className="input"
            />
          </div>
        </div>

        {/* Destination Coordinates */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-ndx-light/70 mb-2">Destination Latitude</label>
            <input
              type="number"
              name="destLat"
              value={formData.destLat}
              onChange={handleInputChange}
              step="any"
              placeholder="e.g. 40.7831"
              className="input"
            />
          </div>
          <div>
            <label className="block text-ndx-light/70 mb-2">Destination Longitude</label>
            <input
              type="number"
              name="destLng"
              value={formData.destLng}
              onChange={handleInputChange}
              step="any"
              placeholder="e.g. -73.9712"
              className="input"
            />
          </div>
        </div>

        <button
          type="submit"
          disabled={loading}
          className="w-full h-14 bg-gradient-to-r from-ndx-primary to-ndx-secondary text-white font-semibold rounded-2xl hover:scale-105 transition-all duration-300 glow-green disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {loading ? (
            <div className="flex items-center justify-center space-x-2">
              <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
              <span>Finding Routes...</span>
            </div>
          ) : (
            'Find Routes'
          )}
        </button>
      </form>

      {/* Results */}
      {results.length > 0 && (
        <div className="mt-8 space-y-4">
          <h3 className="text-lg font-medium text-ndx-light">Available Routes</h3>
          <div className="space-y-3">
            {results.map((route, index) => (
              <div
                key={route.routeId || index}
                className="flex items-center justify-between p-4 bg-white/5 rounded-xl hover:bg-white/10 transition-all duration-300"
              >
                <div className="flex items-center space-x-4">
                  <Route className="w-5 h-5 text-ndx-primary" />
                  <div>
                    <div className="text-ndx-light font-medium">{route.name}</div>
                    <div className="text-ndx-light/60 text-sm">Route ID: {route.routeId}</div>
                  </div>
                </div>
                <div className="text-right">
                  <div className="text-ndx-light">{route.distance}</div>
                  <div className="text-ndx-light/60 text-sm">{route.estimatedTime}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
