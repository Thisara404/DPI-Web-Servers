import React, { useEffect, useState } from "react";
import { getJourneys, getSchedules } from "@/api/ndxApi";

export default function AnalyticsPage() {
  const [journeys, setJourneys] = useState([]);
  const [schedules, setSchedules] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setLoading(true);
    try {
      const [journeysRes, schedulesRes] = await Promise.all([
        getJourneys(),
        getSchedules(),
      ]);
      setJourneys(journeysRes.data?.data || journeysRes.data || []);
      setSchedules(schedulesRes.data?.data || schedulesRes.data || []);
    } catch (err) {
      console.error("Failed to load analytics data:", err);
    } finally {
      setLoading(false);
    }
  };

  const totalJourneys = journeys.length;
  const totalSchedules = schedules.length;
  const activeSchedules = schedules.filter(
    (s) => s.status === "in_progress"
  ).length;
  const completedJourneys = journeys.filter(
    (j) => j.status === "completed"
  ).length;

  if (loading)
    return (
      <div className="flex items-center justify-center min-h-screen">
        Loading analytics...
      </div>
    );

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold">Analytics</h1>
      <div className="mt-4 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="card p-4">
          <h3 className="font-semibold">Total Journeys</h3>
          <p className="text-2xl">{totalJourneys}</p>
        </div>
        <div className="card p-4">
          <h3 className="font-semibold">Total Schedules</h3>
          <p className="text-2xl">{totalSchedules}</p>
        </div>
        <div className="card p-4">
          <h3 className="font-semibold">Active Schedules</h3>
          <p className="text-2xl">{activeSchedules}</p>
        </div>
        <div className="card p-4">
          <h3 className="font-semibold">Completed Journeys</h3>
          <p className="text-2xl">{completedJourneys}</p>
        </div>
      </div>
      {/* Add charts here using a library like Chart.js or Recharts */}
      <div className="mt-6">
        <p>
          Charts for journeys by status, schedules by route, etc. (implement with
          preferred chart library).
        </p>
      </div>
    </div>
  );
}