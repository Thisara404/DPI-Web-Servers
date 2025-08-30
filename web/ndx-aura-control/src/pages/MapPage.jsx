import React, { useEffect, useState } from "react";
import RouteMap from "@/components/RouteMap";
import { getRoutes, getSchedules } from "@/api/ndxApi";

export default function MapPage() {
  const [routes, setRoutes] = useState([]);
  const [schedules, setSchedules] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setLoading(true);
    try {
      const [routesRes, schedulesRes] = await Promise.all([
        getRoutes(),
        getSchedules(),
      ]);
      setRoutes(routesRes.data?.data || routesRes.data || []);
      setSchedules(schedulesRes.data?.data || schedulesRes.data || []);
    } catch (err) {
      console.error("Failed to load map data:", err);
    } finally {
      setLoading(false);
    }
  };

  if (loading)
    return (
      <div className="flex items-center justify-center min-h-screen">
        Loading map...
      </div>
    );

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold">Map</h1>
      <div style={{ height: 600 }} className="mt-4">
        <RouteMap routes={routes} schedules={schedules} />
      </div>
    </div>
  );
}