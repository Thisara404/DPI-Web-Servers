import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import ndxApi from "@/api/ndxApi";

export default function JourneyDetailsPage() {
  const { id } = useParams();
  const [journey, setJourney] = useState(null);

  useEffect(() => {
    if (!id) return;
    ndxApi.get(`/journeys/${id}`).then(r => setJourney(r.data?.data || r.data)).catch(console.error);
  }, [id]);

  if (!journey) return <div>Loading...</div>;

  return (
    <div className="p-6">
      <h1 className="text-xl font-bold">Journey {journey._id || journey.id}</h1>
      <p>From: {journey.from}</p>
      <p>To: {journey.to}</p>
      <p>Status: {journey.status}</p>
    </div>
  );
}