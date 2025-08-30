import React, { useState } from "react";
import ndxApi from "@/api/ndxApi";
import { useNavigate } from "react-router-dom";

export default function BookJourneyPage() {
  const [payload, setPayload] = useState({ routeId: "", passengerName: "", phone: "" });
  const [loading, setLoading] = useState(false);
  const nav = useNavigate();

  async function submit(e) {
    e.preventDefault();
    setLoading(true);
    try {
      await ndxApi.post("/journeys", payload);
      nav("/journeys");
    } catch (err) { console.error(err); alert("Failed to book"); }
    setLoading(false);
  }

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold">Book Journey</h1>
      <form onSubmit={submit} className="space-y-3 mt-4">
        <input value={payload.routeId} onChange={e=>setPayload({...payload, routeId:e.target.value})} placeholder="Route ID" className="input" />
        <input value={payload.passengerName} onChange={e=>setPayload({...payload, passengerName:e.target.value})} placeholder="Name" className="input" />
        <input value={payload.phone} onChange={e=>setPayload({...payload, phone:e.target.value})} placeholder="Phone" className="input" />
        <button className="btn" disabled={loading}>{loading ? "Booking..." : "Book"}</button>
      </form>
    </div>
  );
}