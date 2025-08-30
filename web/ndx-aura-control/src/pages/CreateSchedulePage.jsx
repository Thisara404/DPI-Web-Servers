import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { createSchedule } from '@/api/ndxApi';

export default function CreateSchedulePage() {
  const [form, setForm] = useState({ routeId: '', startTime: '', endTime: '', status: 'upcoming' });
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await createSchedule(form);
      alert('Schedule created');
      navigate('/schedules');
    } catch (err) {
      console.error(err);
      alert('Failed to create schedule');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold">Create Schedule</h1>
      <form onSubmit={handleSubmit} className="mt-4 space-y-4">
        <input name="routeId" value={form.routeId} onChange={handleChange} placeholder="Route ID" className="input" required />
        <input name="startTime" value={form.startTime} onChange={handleChange} type="datetime-local" className="input" required />
        <input name="endTime" value={form.endTime} onChange={handleChange} type="datetime-local" className="input" required />
        <select name="status" value={form.status} onChange={handleChange} className="input">
          <option value="upcoming">Upcoming</option>
          <option value="in_progress">In Progress</option>
          <option value="completed">Completed</option>
          <option value="cancelled">Cancelled</option>
        </select>
        <button type="submit" className="btn" disabled={loading}>
          {loading ? 'Creating...' : 'Create Schedule'}
        </button>
      </form>
    </div>
  );
}