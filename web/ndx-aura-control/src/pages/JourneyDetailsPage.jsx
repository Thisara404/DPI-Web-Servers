import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { getJourneyDetails, cancelJourney, verifyJourney, trackJourney, payJourney } from "@/api/ndxApi";

export default function JourneyDetailsPage() {
  const { id } = useParams();
  const [journey, setJourney] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!id) return;
    setLoading(true);
    getJourneyDetails(id)
      .then((res) => setJourney(res.data?.data || res.data))
      .catch((err) => console.error("Failed to load journey:", err))
      .finally(() => setLoading(false));
  }, [id]);

  const handleCancel = async () => {
    try {
      await cancelJourney(id);
      alert("Journey cancelled");
      // Refresh journey data
      const res = await getJourneyDetails(id);
      setJourney(res.data?.data || res.data);
    } catch (err) {
      console.error(err);
      alert("Failed to cancel");
    }
  };

  const handleVerify = async () => {
    try {
      await verifyJourney(id);
      alert("Journey verified");
      const res = await getJourneyDetails(id);
      setJourney(res.data?.data || res.data);
    } catch (err) {
      console.error(err);
      alert("Failed to verify");
    }
  };

  const handleTrack = async () => {
    // Example: Track with sample location
    try {
      await trackJourney(id, { lat: 6.9, lng: 79.8 });
      alert("Location tracked");
    } catch (err) {
      console.error(err);
      alert("Failed to track");
    }
  };

  const handlePay = async () => {
    try {
      await payJourney(id, { amount: journey.fare });
      alert("Payment initiated");
      const res = await getJourneyDetails(id);
      setJourney(res.data?.data || res.data);
    } catch (err) {
      console.error(err);
      alert("Failed to pay");
    }
  };

  if (loading) return <div className="flex items-center justify-center min-h-screen">Loading journey...</div>;
  if (!journey) return <div className="text-red-500">Journey not found</div>;

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold">Journey {journey._id || journey.id}</h1>
      <p className="text-sm text-muted">Passenger: {journey.passengerName}</p>
      <p className="text-sm text-muted">From: {journey.origin?.lat}, {journey.origin?.lng}</p>
      <p className="text-sm text-muted">To: {journey.destination?.lat}, {journey.destination?.lng}</p>
      <p className="text-sm text-muted">Status: {journey.status}</p>
      <p className="text-sm text-muted">Fare: {journey.fare}</p>
      <p className="text-sm text-muted">Payment Status: {journey.paymentStatus || "N/A"}</p>

      <div className="mt-6 space-x-2">
        <button onClick={handleCancel} className="btn" disabled={journey.status === "cancelled"}>Cancel</button>
        <button onClick={handleVerify} className="btn" disabled={journey.status === "verified"}>Verify</button>
        <button onClick={handleTrack} className="btn">Track Location</button>
        <button onClick={handlePay} className="btn" disabled={journey.paymentStatus === "paid"}>Pay</button>
      </div>
    </div>
  );
}