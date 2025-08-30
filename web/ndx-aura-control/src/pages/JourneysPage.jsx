import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { getJourneys } from '@/api/ndxApi';

export default function JourneysPage() {
  const [journeys, setJourneys] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadJourneys();
  }, []);

  const loadJourneys = async () => {
    setLoading(true);
    try {
      const res = await getJourneys();
      setJourneys(res.data?.data || res.data || []);
    } catch (err) {
      console.error('Failed to load journeys:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Journeys</h1>
        <Link to="/journeys/book" className="btn">Book Journey</Link>
      </div>

      {loading ? (
        <div>Loading journeys...</div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {journeys.map((journey) => (
            <div key={journey._id || journey.id} className="card p-4">
              <h3 className="font-semibold">{journey.passengerName || 'Passenger'}</h3>
              <p className="text-sm text-muted">From: {journey.origin?.lat}, {journey.origin?.lng}</p>
              <p className="text-sm text-muted">To: {journey.destination?.lat}, {journey.destination?.lng}</p>
              <p className="text-sm text-muted">Status: {journey.status}</p>
              <p className="text-sm text-muted">Fare: {journey.fare}</p>
              <Link to={`/journeys/${journey._id || journey.id}`} className="btn-small mt-2">View Details</Link>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}