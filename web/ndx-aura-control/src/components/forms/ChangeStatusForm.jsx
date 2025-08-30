import React, { useState } from "react";
import { changeScheduleStatus } from "@/api/ndxApi";

const STATUSES = ["upcoming", "in_progress", "completed", "cancelled"];

export default function ChangeStatusForm({ scheduleId, initialStatus, onChanged } = {}) {
  const [status, setStatus] = useState(initialStatus || "in_progress");
  const [loading, setLoading] = useState(false);

  if (!scheduleId) return <div className="text-sm text-red-500">Missing scheduleId</div>;

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await changeScheduleStatus(scheduleId, { status });
      onChanged?.(status);
      alert("Status updated");
    } catch (err) {
      console.error(err);
      alert("Failed to update status");
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-2">
      <h3 className="font-semibold">Change Status</h3>
      <select value={status} onChange={(e) => setStatus(e.target.value)} className="input">
        {STATUSES.map((s) => (
          <option key={s} value={s}>
            {s}
          </option>
        ))}
      </select>
      <button type="submit" className="btn" disabled={loading}>
        {loading ? "Updating..." : "Change Status"}
      </button>
    </form>
  );
}