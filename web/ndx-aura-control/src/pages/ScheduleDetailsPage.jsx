import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import ndxApi from "@/api/ndxApi";

export default function ScheduleDetailsPage() {
  const { id } = useParams();
  const [schedule, setSchedule] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!id) return;
    setLoading(true);
    ndxApi.get(`/schedules/${id}`)
      .then(r => setSchedule(r.data?.data || r.data))
      .catch(e => console.error(e))
      .finally(() => setLoading(false));
  }, [id]);

  async function updateLocation() {
    // quick example: update location to random coords (replace with real UI)
    try {
      await ndxApi.post(`/schedules/${id}/location`, { lat: 6.9, lng: 79.8 });
      alert("Location updated");
    } catch (err) { console.error(err); alert("Failed"); }
  }

  if (loading) return <div>Loading...</div>;
  if (!schedule) return <div>Schedule not found</div>;

  return (
    <div className="p-6">
      <h1 className="text-xl font-bold">Schedule {schedule._id || schedule.id}</h1>
      <p>Route: {schedule.routeName}</p>
      <p>Status: {schedule.status}</p>
      <button onClick={updateLocation} className="btn mt-4">Update Location (demo)</button>
    </div>
  );
}