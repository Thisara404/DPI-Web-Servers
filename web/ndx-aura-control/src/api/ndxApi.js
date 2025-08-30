import axios from 'axios';

const baseURL = import.meta.env.VITE_NDX_URL || 'http://localhost:3000'; // Use Vite env var
const client = axios.create({ baseURL, timeout: 10000 });

// Auth headers helper
function authHeaders() {
  const token = localStorage.getItem('jwt');
  return token ? { Authorization: `Bearer ${token}` } : {};
}

// Auth endpoint
export const getDevToken = () => client.get('/api/debug/generate-token');

// Routes endpoints
export const getRoutes = (params) => client.get('/api/routes', { params });
export const getRouteDetails = (routeId) => client.get(`/api/routes/${routeId}/details`);
export const searchLocations = (query) => client.get('/api/routes/search-locations', { params: { query } });
export const findRoutes = (from, to) => client.get('/api/routes/find-routes', { params: { from, to } });
export const getNearbyStops = (params) => client.get('/api/routes/nearby-stops', { params });

// Schedules endpoints
export const getSchedules = (params) => client.get('/api/schedules', { params });
export const getSchedulesByRoute = (routeId) => client.get(`/api/schedules/route/${routeId}`);
export const getActiveSchedules = () => client.get('/api/schedules/active');
export const updateScheduleLocation = (scheduleId, payload) => client.post(`/api/schedules/${scheduleId}/location`, payload, { headers: authHeaders() });
export const changeScheduleStatus = (scheduleId, payload) => client.patch(`/api/schedules/${scheduleId}/status`, payload, { headers: authHeaders() });
export const createSchedule = (payload) => client.post('/api/schedules', payload, { headers: authHeaders() });

// Journeys endpoints
export const getJourneys = (params) => client.get('/api/journeys', { params, headers: authHeaders() });
export const getJourneyDetails = (journeyId) => client.get(`/api/journeys/${journeyId}`, { headers: authHeaders() });
export const bookJourney = (payload) => client.post('/api/journeys', payload, { headers: authHeaders() });
export const cancelJourney = (journeyId) => client.post(`/api/journeys/${journeyId}/cancel`, {}, { headers: authHeaders() });
export const verifyJourney = (journeyId) => client.post(`/api/journeys/${journeyId}/verify`, {}, { headers: authHeaders() });
export const trackJourney = (journeyId, payload) => client.post(`/api/journeys/${journeyId}/track`, payload, { headers: authHeaders() });
export const payJourney = (journeyId, payload) => client.post(`/api/journeys/${journeyId}/pay`, payload, { headers: authHeaders() });

export default client;
