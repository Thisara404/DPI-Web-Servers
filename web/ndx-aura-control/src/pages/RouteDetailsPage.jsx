import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import ndxApi from "@/api/ndxApi";

export default function RouteDetailsPage() {
  const { routeId } = useParams();
  const [route, setRoute] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!routeId) return;
    setLoading(true);
    ndxApi.get(`/routes/${routeId}/details`)
      .then((r) => setRoute(r.data || r.data?.data))
      .catch((e) => console.error(e))
      .finally(() => setLoading(false));
  }, [routeId]);

  if (loading) return <div>Loading route...</div>;
  if (!route) return <div>Route not found</div>;

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold">{route.name || route.routeName}</h1>
      <p className="text-sm text-muted">Distance: {route.distance}</p>
      <div className="mt-4">
        <h2 className="font-semibold">Stops</h2>
        <ul>
          {(route.stops || []).map((s) => (
            <li key={s._id || s.id}>{s.name} — {s.lat},{s.lng}</li>
          ))}
        </ul>
      </div>
      <div className="mt-6">
        <h2 className="font-semibold">Map</h2>
        {/* reuse RouteMap component */}
        <div style={{ height: 400 }}>
          {/* RouteMap expects geometry/stops — adjust props if needed */}
          <iframe title="map" srcDoc={`<div>Map placeholder (implement RouteMap)</div>`} style={{width:'100%',height:'100%',border:0}} />
        </div>
      </div>
    </div>
  );
}