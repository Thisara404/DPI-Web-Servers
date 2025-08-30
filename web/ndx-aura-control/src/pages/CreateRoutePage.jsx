import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';

export default function CreateRoutePage() {
  const [form, setForm] = useState({ name: '', distance: '', stops: [] });
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    // TODO: Implement POST /api/routes with validation from Server/NDX/utils/dataValidator.js
    // For now, simulate
    setLoading(true);
    setTimeout(() => {
      alert('Route created (implement API call)');
      navigate('/routes');
      setLoading(false);
    }, 1000);
  };

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold">Create Route</h1>
      <form onSubmit={handleSubmit} className="mt-4 space-y-4">
        <input name="name" value={form.name} onChange={handleChange} placeholder="Route Name" className="input" required />
        <input name="distance" value={form.distance} onChange={handleChange} placeholder="Distance (km)" type="number" className="input" required />
        {/* Add stops input if needed */}
        <button type="submit" className="btn" disabled={loading}>
          {loading ? 'Creating...' : 'Create Route'}
        </button>
      </form>
    </div>
  );
}