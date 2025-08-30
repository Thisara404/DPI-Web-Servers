import React, { useState, useRef } from "react";
import { useNavigate } from "react-router-dom";
import { createRoute, searchNominatim } from "@/api/ndxApi";
import RouteMap from "@/components/RouteMap";

/*
  CreateRoutePage:
  - Search places (Nominatim) OR click on the map to add stops.
  - Stops are stored as { name, location: { type: 'Point', coordinates: [lng, lat] } }.
  - Path is built from stops' coordinates (LineString).
  - Submit posts to NDX POST /api/routes (createRoute).
*/
export default function CreateRoutePage() {
  const nav = useNavigate();
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [searchQ, setSearchQ] = useState("");
  const [searchResults, setSearchResults] = useState([]);
  const [stops, setStops] = useState([]);
  const [loading, setLoading] = useState(false);
  const mapSelectedRef = useRef(null);

  const handleSearch = async (q) => {
    if (!q || q.trim().length < 2) return;
    try {
      const res = await searchNominatim(q, 8);
      const mapped = (res.data || []).map(r => ({
        id: r.place_id,
        name: r.display_name,
        lat: parseFloat(r.lat),
        lng: parseFloat(r.lon),
        raw: r
      }));
      setSearchResults(mapped);
    } catch (err) {
      console.error("Search error:", err);
      setSearchResults([]);
    }
  };

  const addStopFromResult = (r) => {
    const stop = {
      name: r.name || r.display_name || "Stop",
      location: { type: "Point", coordinates: [r.lng, r.lat] }
    };
    setStops(prev => [...prev, stop]);
  };

  const handleMapClick = ({ lat, lng }) => {
    mapSelectedRef.current = { lat, lng };
    const generatedName = `Point ${stops.length + 1}`;
    const stop = {
      name: generatedName,
      location: { type: "Point", coordinates: [lng, lat] }
    };
    setStops(prev => [...prev, stop]);
  };

  const removeStop = (index) => setStops(prev => prev.filter((_, i) => i !== index));

  const buildPathFromStops = () => {
    // LineString coordinates array: [[lng,lat], ...]
    return {
      type: "LineString",
      coordinates: stops.map(s => s.location.coordinates)
    };
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!name || stops.length < 2) {
      alert("Provide route name and at least 2 stops");
      return;
    }
    setLoading(true);
    try {
      const payload = {
        name,
        description,
        stops,
        path: buildPathFromStops(),
        // distance / estimatedDuration can be computed server-side; optional to include
      };
      const res = await createRoute(payload);
      if (res.data?.success) {
        nav("/routes");
      } else {
        alert("Failed to create route: " + (res.data?.message || "unknown"));
      }
    } catch (err) {
      console.error("Create route error:", err);
      alert(err?.response?.data?.message || err.message || "Failed to create route");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Create Route</h1>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-sm text-ndx-light/70">Route name</label>
          <input className="input w-full" value={name} onChange={(e)=>setName(e.target.value)} />
        </div>

        <div>
          <label className="block text-sm text-ndx-light/70">Description</label>
          <textarea className="input w-full" value={description} onChange={(e)=>setDescription(e.target.value)} />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm text-ndx-light/70">Search locations (Nominatim)</label>
            <div className="flex gap-2">
              <input className="input flex-1" value={searchQ} onChange={(e)=>{ setSearchQ(e.target.value); }} />
              <button type="button" className="btn" onClick={()=>handleSearch(searchQ)}>Search</button>
            </div>

            <div className="mt-3 max-h-56 overflow-y-auto space-y-2">
              {searchResults.map(r => (
                <div key={r.id} className="p-2 bg-white/5 rounded-lg flex justify-between items-center">
                  <div>
                    <div className="font-medium">{r.name}</div>
                    <div className="text-sm text-ndx-light/60">{r.lat}, {r.lng}</div>
                  </div>
                  <button type="button" className="btn" onClick={()=>addStopFromResult(r)}>Add</button>
                </div>
              ))}
            </div>
          </div>

          <div>
            <label className="block text-sm text-ndx-light/70">Map (click to add stop)</label>
            <div style={{ height: 300 }} className="mt-2 bg-black/5 rounded-lg overflow-hidden">
              <RouteMap onMapClick={handleMapClick} osmRouteCoords={stops.map(s => ({ lat: s.location.coordinates[1], lng: s.location.coordinates[0] }))} />
            </div>
            <div className="text-sm text-ndx-light/60 mt-2">Click on map to add a stop at that location.</div>
          </div>
        </div>

        <div>
          <h3 className="font-semibold">Stops ({stops.length})</h3>
          <ul className="list-decimal pl-5 mt-2 space-y-1">
            {stops.map((s, i) => (
              <li key={i} className="flex justify-between items-center">
                <div>{s.name} — {s.location.coordinates[1].toFixed(5)}, {s.location.coordinates[0].toFixed(5)}</div>
                <div>
                  <button type="button" className="btn mr-2" onClick={()=>{ navigator.clipboard?.writeText(`${s.location.coordinates[1]},${s.location.coordinates[0]}`); }}>Copy</button>
                  <button type="button" className="btn-destructive" onClick={()=>removeStop(i)}>Remove</button>
                </div>
              </li>
            ))}
          </ul>
        </div>

        <div className="flex gap-2">
          <button className="btn" type="submit" disabled={loading}>{loading ? 'Creating...' : 'Create Route'}</button>
          <button type="button" className="btn-ghost" onClick={()=>nav('/routes')}>Cancel</button>
        </div>
      </form>
    </div>
  );
}