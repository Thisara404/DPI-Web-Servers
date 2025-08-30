import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { getSchedules } from "@/api/ndxApi"; // Assuming getSchedules can fetch by ID; adjust if needed
import UpdateLocationForm from "@/components/forms/UpdateLocationForm";
import ChangeStatusForm from "@/components/forms/ChangeStatusForm";

export default function ScheduleDetailsPage() {
  const { id } = useParams();
  const [schedule, setSchedule] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!id) return;
    setLoading(true);
    getSchedules({ id }) // Adjust to GET /api/schedules/:id if available
      .then((res) => setSchedule(res.data?.data || res.data))
      .catch((err) => console.error("Failed to load schedule:", err))
      .finally(() => setLoading(false));
  }, [id]);

  if (loading)
    return (
      <div className="flex items-center justify-center min-h-screen">
        Loading schedule...
      </div>
    );
  if (!schedule)
    return <div className="text-red-500">Schedule not found</div>;

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold">
        Schedule {schedule._id || schedule.id}
      </h1>
      <p className="text-sm text-muted">Route: {schedule.routeName}</p>
      <p className="text-sm text-muted">
        Start Time: {schedule.startTime}
      </p>
      <p className="text-sm text-muted">End Time: {schedule.endTime}</p>
      <p className="text-sm text-muted">Status: {schedule.status}</p>
      <p className="text-sm text-muted">
        Current Location: {schedule.currentLocation?.lat},{" "}
        {schedule.currentLocation?.lng}
      </p>

      <div className="mt-6 space-y-4">
        <UpdateLocationForm scheduleId={id} />
        <ChangeStatusForm
          scheduleId={id}
          initialStatus={schedule.status}
        />
      </div>
    </div>
  );
}