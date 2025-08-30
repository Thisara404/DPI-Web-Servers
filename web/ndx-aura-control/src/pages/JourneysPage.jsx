import React, { useEffect, useState } from "react";
import ndxApi from "@/api/ndxApi";
import { Link } from "react-router-dom";

export default function JourneysPage() {
  const [journeys, setJourneys] = useState([]);
  const [loading, setLoading] = useState(true);

  async function load() {
    setLoading(true);
    try {
      const res = await ndxApi.get("/journeys");
      setJourneys(res.data?.data || res.data || []);
    } catch (e) { console.error(e); }
    setLoading(false);
  }

  useEffect(() => { load(); }, []);

  return (
    <div className="p-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold">Journeys</h1>
        <Link to="/journeys/book" className="btn">Book Journey</Link>
      </div>
      {loading ? <div>Loading...</div> : (
        <div className="mt-4 space-y-3">
          {journeys.map(j => (
            <div key={j._id || j.id} className="card p-4">
              <div className="flex justify-between">
                <div>
                  <div className="font-semibold">{j.passengerName || j.title}</div>
                  <div className="text-sm text-muted">{j.from} → {j.to}</div>
                </div>
                <div><Link to={`/journeys/${j._id || j.id}`} className="btn-small">View</Link></div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}