import React, { useState } from 'react';
import { updateScheduleLocation } from '@/api/ndxApi';

export default function UpdateLocationForm({ scheduleId } = {}) {
  const [lat, setLat] = useState('');
  const [lng, setLng] = useState('');
  const [loading, setLoading] = useState(false);

  if (!scheduleId) return <div className="text-sm text-red-500">Missing scheduleId</div>;

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!lat || !lng) return alert('Enter valid coordinates');
    setLoading(true);
    try {
      await updateScheduleLocation(scheduleId, { lat: parseFloat(lat), lng: parseFloat(lng) });
      alert('Location updated');
      setLat('');
      setLng('');
    } catch (err) {
      console.error(err);
      alert('Failed to update location');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-2">
      <h3 className="font-semibold">Update Location</h3>
      <input value={lat} onChange={(e) => setLat(e.target.value)} placeholder="Latitude" type="number" step="any" className="input" required />
      <input value={lng} onChange={(e) => setLng(e.target.value)} placeholder="Longitude" type="number" step="any" className="input" required />
      <button type="submit" className="btn" disabled={loading}>
        {loading ? 'Updating...' : 'Update Location'}
      </button>
    </form>
  );
}