import React, { useState } from 'react';
import { searchLocations } from '@/api/ndxApi';
import { useToast } from '@/hooks/use-toast';
import { MapPin } from 'lucide-react';

export default function SearchLocationsForm({ onSearch } = {}) {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);
  const [selectedLocation, setSelectedLocation] = useState(null);
  const { toast } = useToast();

  const handleSearch = async (searchQuery) => {
    if (!searchQuery.trim()) {
      setResults([]);
      return;
    }

    try {
      setLoading(true);
      const response = await searchLocations(searchQuery);
      const data = response.data?.data || response.data || [];
      setResults(data);
      onSearch?.(data);
    } catch (error) {
      console.error('Search error:', error);
      toast({
        title: "Search Error",
        description: "Failed to search locations",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e) => {
    const value = e.target.value;
    setQuery(value);
    
    // Debounced search
    clearTimeout(window.searchTimeout);
    window.searchTimeout = setTimeout(() => {
      handleSearch(value);
    }, 300);
  };

  const handleLocationSelect = (location) => {
    setSelectedLocation(location);
    setQuery(location.name);
    setResults([]);
    
    toast({
      title: "Location Selected",
      description: `${location.name} (${location.lat}, ${location.lng})`,
    });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    handleSearch(query);
  };

  return (
    <div className="mb-4 glass rounded-3xl p-8 animate-fade-in">
      <h2 className="text-2xl font-semibold text-ndx-light mb-6">Search Locations</h2>
      
      <form onSubmit={handleSubmit} className="flex gap-2 mb-4">
        <input
          type="text"
          value={query}
          onChange={handleInputChange}
          placeholder="Search for stops and addresses..."
          className="input flex-1 h-14 px-6 bg-white/10 border border-white/20 rounded-2xl text-ndx-light placeholder-ndx-light/60 focus:outline-none focus:ring-2 focus:ring-ndx-primary/50 focus:border-ndx-primary/50 backdrop-blur-md transition-all duration-300"
        />
        <button type="submit" className="btn h-14 px-6 rounded-2xl" disabled={loading}>
          {loading ? 'Searching...' : 'Search'}
        </button>
      </form>

      {/* Search Results */}
      {results.length > 0 && (
        <div className="space-y-2">
          <h3 className="text-lg font-medium text-ndx-light">Search Results</h3>
          <div className="space-y-2 max-h-64 overflow-y-auto">
            {results.map((location, index) => (
              <div
                key={index}
                onClick={() => handleLocationSelect(location)}
                className="flex items-center space-x-4 p-4 bg-white/5 rounded-xl hover:bg-white/10 cursor-pointer transition-all duration-300 hover:scale-105"
              >
                <MapPin className="w-5 h-5 text-ndx-primary" />
                <div className="flex-1">
                  <div className="text-ndx-light font-medium">{location.name || location.display_name}</div>
                  <div className="text-ndx-light/60 text-sm">
                    {location.lat}, {location.lng}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Selected Location */}
      {selectedLocation && (
        <div className="p-6 bg-ndx-primary/10 rounded-2xl border border-ndx-primary/20">
          <h3 className="text-lg font-medium text-ndx-primary mb-2">Selected Location</h3>
          <div className="flex items-center space-x-4">
            <MapPin className="w-6 h-6 text-ndx-primary" />
            <div>
              <div className="text-ndx-light font-medium">{selectedLocation.name}</div>
              <div className="text-ndx-light/70">
                Coordinates: {selectedLocation.lat}, {selectedLocation.lng}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
