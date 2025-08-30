import React, { useState } from "react";
import { searchNominatim, getRouteBetween } from '@/api/ndxApi';
import { useToast } from '@/hooks/use-toast';

export default function SearchLocationsForm({ onSearch } = {}) {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);
  const [selected, setSelected] = useState(null);
  const { toast } = useToast();

  const handleSearch = async (q) => {
    if (!q || q.trim().length < 2) return;
    setLoading(true);
    try {
      const res = await searchNominatim(q, 8);
      // Nominatim returns array of places with lat/lon
      const mapped = (res.data || []).map(r => ({
        id: r.place_id,
        name: r.display_name,
        lat: parseFloat(r.lat),
        lng: parseFloat(r.lon),
        type: r.type,
        raw: r
      }));
      setResults(mapped);
      onSearch?.(mapped);
    } catch (err) {
      console.error('Search error:', err);
      toast({ title: 'Search failed', description: err.message || 'Search error', variant: 'destructive' });
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e) => {
    const v = e.target.value;
    setQuery(v);
    clearTimeout(window.__ndx_search_timer);
    window.__ndx_search_timer = setTimeout(() => {
      handleSearch(v);
    }, 350);
  };

  const handleSelect = async (loc) => {
    setSelected(loc);
    // If there's an existing "from" location selected elsewhere, you can call routing here.
    // Example: compute route from dashboard center to selected location:
    try {
      // Example: from fixed point or previously selected origin
      // const origin = { lat: 6.9271, lng: 79.8612 };
      // const routeCoords = await getRouteBetween(origin, loc);
      // pass back location + optional route coords
      onSearch?.([loc]); // or onSearch?.({ location: loc, route: routeCoords })
    } catch (err) {
      console.error('Failed to compute route:', err);
    }
  };

  return (
    <div className="mb-4 glass rounded-3xl p-8 animate-fade-in">
      <form onSubmit={(e)=>{ e.preventDefault(); handleSearch(query); }} className="flex gap-2 mb-4">
        <input
          type="text"
          value={query}
          onChange={handleInputChange}
          placeholder="Search for stops and addresses..."
          className="input flex-1 h-14 px-6 bg-white/10 border border-white/20 rounded-2xl text-ndx-light placeholder-ndx-light/60 focus:outline-none focus:ring-2 focus:ring-ndx-primary/50 focus:border-ndx-primary/50 backdrop-blur-md transition-all duration-300"
        />
        <button className="btn h-14 px-6 rounded-2xl" type="submit" disabled={loading}>
          {loading ? 'Searching...' : 'Search'}
        </button>
      </form>

      <div className="space-y-2 max-h-64 overflow-y-auto">
        {results.map((r) => (
          <div key={r.id} onClick={() => handleSelect(r)} className="p-4 bg-white/5 rounded-xl hover:bg-white/10 cursor-pointer">
            <div className="font-medium">{r.name}</div>
            <div className="text-sm text-ndx-light/60">{r.lat}, {r.lng}</div>
          </div>
        ))}
      </div>
    </div>
  );
}
