export const isValidCoordinates = (lat, lng) => {
  return typeof lat === 'number' && typeof lng === 'number' && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
};

export const validateJourneyPayload = (payload) => {
  if (!payload.scheduleId && !payload.routeId) return 'ScheduleId or RouteId required';
  if (!payload.passengerName && !payload.passengerId) return 'Passenger name or ID required';
  if (payload.origin && !isValidCoordinates(payload.origin.lat, payload.origin.lng)) return 'Invalid origin coordinates';
  if (payload.destination && !isValidCoordinates(payload.destination.lat, payload.destination.lng)) return 'Invalid destination coordinates';
  return null;
};

export const validateSchedulePayload = (payload) => {
  if (!payload.routeId) return 'RouteId required';
  if (!payload.startTime || !payload.endTime) return 'Start and end times required';
  return null;
};