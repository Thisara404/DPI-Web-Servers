import React from "react";
import RouteMap from "@/components/RouteMap";

export default function MapPage() {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold">Map</h1>
      <div style={{ height: 600 }} className="mt-4">
        <RouteMap />
      </div>
    </div>
  );
}