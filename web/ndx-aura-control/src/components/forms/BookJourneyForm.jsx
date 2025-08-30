import React, { useState } from "react";
import { bookJourney } from "@/api/ndxApi";

export default function BookJourneyForm({ onBooked } = {}) {
  const [form, setForm] = useState({
    passengerId: "",
    passengerName: "",
    scheduleId: "",
    originLat: "",
    originLng: "",
    destLat: "",
    destLng: "",
    fare: "",
    phone: "",
  });
  const [loading, setLoading] = useState(false);

  const handleChange = (e) =>
    setForm({ ...form, [e.target.name]: e.target.value });

  const validate = () => {
    if (!form.scheduleId && !form.routeId) {
      alert("Enter scheduleId or routeId.");
      return false;
    }
    if (!form.passengerName && !form.passengerId) {
      alert("Enter passenger name or passengerId.");
      return false;
    }
    return true;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validate()) return;
    setLoading(true);
    try {
      const payload = {
        passengerId: form.passengerId || undefined,
        passengerName: form.passengerName || undefined,
        scheduleId: form.scheduleId || undefined,
        origin:
          form.originLat && form.originLng
            ? { lat: parseFloat(form.originLat), lng: parseFloat(form.originLng) }
            : undefined,
        destination:
          form.destLat && form.destLng
            ? { lat: parseFloat(form.destLat), lng: parseFloat(form.destLng) }
            : undefined,
        fare: form.fare ? parseFloat(form.fare) : undefined,
        phone: form.phone || undefined,
      };
      Object.keys(payload).forEach((k) => payload[k] === undefined && delete payload[k]);

      await bookJourney(payload);
      setForm({
        passengerId: "",
        passengerName: "",
        scheduleId: "",
        originLat: "",
        originLng: "",
        destLat: "",
        destLng: "",
        fare: "",
        phone: "",
      });
      onBooked?.();
      alert("Journey booked successfully.");
    } catch (err) {
      console.error(err);
      alert("Failed to book journey.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-3">
      <div className="grid grid-cols-2 gap-2">
        <input
          name="passengerName"
          value={form.passengerName}
          onChange={handleChange}
          placeholder="Passenger name"
          className="input"
        />
        <input
          name="passengerId"
          value={form.passengerId}
          onChange={handleChange}
          placeholder="Passenger ID (optional)"
          className="input"
        />
        <input
          name="scheduleId"
          value={form.scheduleId}
          onChange={handleChange}
          placeholder="Schedule ID"
          className="input"
        />
        <input
          name="phone"
          value={form.phone}
          onChange={handleChange}
          placeholder="Phone (optional)"
          className="input"
        />
        <input
          name="fare"
          value={form.fare}
          onChange={handleChange}
          placeholder="Fare (optional)"
          type="number"
          className="input"
        />
        <input
          name="originLat"
          value={form.originLat}
          onChange={handleChange}
          placeholder="Origin lat"
          type="number"
          step="any"
          className="input"
        />
        <input
          name="originLng"
          value={form.originLng}
          onChange={handleChange}
          placeholder="Origin lng"
          type="number"
          step="any"
          className="input"
        />
        <input
          name="destLat"
          value={form.destLat}
          onChange={handleChange}
          placeholder="Dest lat"
          type="number"
          step="any"
          className="input"
        />
        <input
          name="destLng"
          value={form.destLng}
          onChange={handleChange}
          placeholder="Dest lng"
          type="number"
          step="any"
          className="input"
        />
      </div>

      <div className="flex gap-2">
        <button type="submit" className="btn" disabled={loading}>
          {loading ? "Booking..." : "Book Journey"}
        </button>
        <button
          type="button"
          className="btn-ghost"
          onClick={() =>
            setForm({
              passengerId: "",
              passengerName: "",
              scheduleId: "",
              originLat: "",
              originLng: "",
              destLat: "",
              destLng: "",
              fare: "",
              phone: "",
            })
          }
        >
          Reset
        </button>
      </div>
    </form>
  );
}