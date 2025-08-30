import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { getSchedules, getSchedulesByRoute, getActiveSchedules } from '@/api/ndxApi';

export default function SchedulesPage() {
  const [schedules, setSchedules] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all'); // 'all', 'active', 'route'

  useEffect(() => {
    loadSchedules();
  }, [filter]);

  const loadSchedules = async () => {
    setLoading(true);
    try {
      let res;
      if (filter === 'active') {
        res = await getActiveSchedules();
      } else if (filter === 'route') {
        // Assume a routeId; replace with dynamic input
        res = await getSchedulesByRoute('sampleRouteId');
      } else {
        res = await getSchedules();
      }
      setSchedules(res.data?.data || res.data || []);
    } catch (err) {
      console.error('Failed to load schedules:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Schedules</h1>
        <div className="flex gap-2">
          <select value={filter} onChange={(e) => setFilter(e.target.value)} className="input">
            <option value="all">All</option>
            <option value="active">Active</option>
            <option value="route">By Route</option>
          </select>
          <Link to="/schedules/create" className="btn">Create Schedule</Link>
        </div>
      </div>

      {loading ? (
        <div>Loading schedules...</div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {schedules.map((schedule) => (
            <div key={schedule._id || schedule.id} className="card p-4">
              <h3 className="font-semibold">{schedule.routeName || 'Route'}</h3>
              <p className="text-sm text-muted">Start: {schedule.startTime}</p>
              <p className="text-sm text-muted">Status: {schedule.status}</p>
              <p className="text-sm text-muted">Location: {schedule.currentLocation?.lat}, {schedule.currentLocation?.lng}</p>
              <Link to={`/schedules/${schedule._id || schedule.id}`} className="btn-small mt-2">View Details</Link>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}