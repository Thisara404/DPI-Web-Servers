import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { getRouteDetails } from "@/api/ndxApi";
import RouteMap from "@/components/RouteMap";

export default function RouteDetailsPage() {
  const { routeId } = useParams();
  const navigate = useNavigate();
  const [route, setRoute] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Guard: don't call API with missing/invalid routeId
    if (!routeId) {
      console.warn("RouteDetailsPage: missing routeId in URL");
      setError("No route ID provided in URL");
      setLoading(false);
      return;
    }

    setLoading(true);
    setError(null);

    getRouteDetails(routeId)
      .then((res) => setRoute(res.data?.data || res.data))
      .catch((err) => {
        console.error("Failed to load route details:", err);
        setError(
          err.response?.data?.message ||
            err.message ||
            "Failed to load route"
        );
        // optional: if id appears invalid, navigate back to list
        // navigate('/routes');
      })
      .finally(() => setLoading(false));
  }, [routeId, navigate]);

  if (loading)
    return (
      <div className="flex items-center justify-center min-h-screen">
        Loading route...
      </div>
    );
  if (error)
    return <div className="p-6 text-red-500">Error: {error}</div>;
  if (!route)
    return <div className="p-6 text-red-500">Route not found</div>;

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold">{route.name}</h1>
      <p className="text-sm text-muted">Distance: {route.distance} km</p>
      <p className="text-sm text-muted">
        Description: {route.description || "N/A"}
      </p>

      <div className="mt-6">
        <h2 className="text-xl font-semibold">Stops</h2>
        <ul className="list-disc pl-5">
          {(route.stops || []).map((stop, i) => (
            <li key={i}>
              {stop.name} - Lat: {stop.lat}, Lng: {stop.lng}
            </li>
          ))}
        </ul>
      </div>

      <div className="mt-6">
        <h2 className="text-xl font-semibold">Map</h2>
        <div style={{ height: 400 }}>
          <RouteMap route={route} />{" "}
          {/* Pass route data to RouteMap for rendering polyline/stops */}
        </div>
      </div>
    </div>
  );
}