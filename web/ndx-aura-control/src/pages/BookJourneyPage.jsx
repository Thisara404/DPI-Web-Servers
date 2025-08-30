import React from 'react';
import { useNavigate } from 'react-router-dom';
import BookJourneyForm from '@/components/forms/BookJourneyForm';

export default function BookJourneyPage() {
  const navigate = useNavigate();

  const handleBooked = () => {
    navigate('/journeys');
  };

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold">Book Journey</h1>
      <div className="mt-4">
        <BookJourneyForm onBooked={handleBooked} />
      </div>
    </div>
  );
}