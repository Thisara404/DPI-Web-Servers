import React, { useState } from "react";
import ndxApi from "@/api/ndxApi";

const STATUSES = [
  { value: "upcoming", label: "Upcoming" },
  { value: "in_progress", label: "In Progress" },
  { value: "completed", label: "Completed" },
  { value: "cancelled", label: "Cancelled" },
];

export default function ChangeStatusForm({ scheduleId, initialStatus, onChanged } = {}) {
  const [status, setStatus] = useState(initialStatus || "in_progress");
  const [loading, setLoading] = useState(false);

  if (!scheduleId) return <div className="text-sm text-red-500">Missing scheduleId</div>;

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await ndxApi.patch(`/schedules/${scheduleId}/status`, { status });
      onChanged?.(status);
      alert("Status updated.");
    } catch (err) {
      console.error(err);
      alert("Failed to update status.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="flex items-center gap-2">
      <select value={status} onChange={(e) => setStatus(e.target.value)} className="input">
        {STATUSES.map(s => <option key={s.value} value={s.value}>{s.label}</option>)}
      </select>
      <button type="submit" className="btn" disabled={loading}>
        {loading ? "Updating..." : "Change Status"}
      </button>
    </form>