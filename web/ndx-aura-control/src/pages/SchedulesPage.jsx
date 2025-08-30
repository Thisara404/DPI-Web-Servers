import React, { useEffect, useState } from "react";
import ndxApi from "@/api/ndxApi";
import { Link } from "react-router-dom";

export default function SchedulesPage() {
  const [schedules, setSchedules] = useState([]);
  const [loading, setLoading] = useState(true);

  async function load() {
    setLoading(true);
    try {
      const res = await ndxApi.get("/schedules");
      setSchedules(res.data?.data || res.data || []);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, []);

  return (
    <div className="p-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Schedules</h1>
        <button onClick={load} className="btn">Refresh</button>
      </div>
      {loading ? <div>Loading...</div> : (
        <div className="mt-4 space-y-3">
          {schedules.map(s => (
            <div key={s._id || s.id} className="card p-4">
              <div className="flex justify-between">
                <div>
                  <div className="font-semibold">{s.routeName || s.route}</div>
                  <div className="text-sm text-muted">{s.startTime} → {s.endTime}</div>
                </div>
                <div className="text-right">
                  <Link to={`/schedules/${s._id || s.id}`} className="btn-small">Details</Link>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}