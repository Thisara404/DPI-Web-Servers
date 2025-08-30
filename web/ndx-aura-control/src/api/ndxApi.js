
import axios from 'axios';

const baseURL = import.meta.env.VITE_NDX_URL || 'http://localhost:3000';

const api = axios.create({
  baseURL,
  timeout: 10000,
});

// Auth headers helper
const getAuthHeaders = () => {
  const token = localStorage.getItem('jwt');
  return token ? { Authorization: `Bearer ${token}` } : {};
};

// Request interceptor to add auth headers
api.interceptors.request.use((config) => {
  config.headers = { ...config.headers, ...getAuthHeaders() };
  return config;
});

// Response interceptor for global error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('jwt');
      window.location.href = '/auth';
    }
    return Promise.reject(error);
  }
);

// Auth / Debug endpoints
export const generateDevToken = () => api.get('/api/debug/generate-token');

// Routes endpoints
export const getRoutes = () => api.get('/api/routes');
export const searchLocations = (query) => api.get('/api/routes/search-locations', { params: { query } });
export const findRoutes = (from, to) => api.get('/api/routes/find-routes', { params: { from, to } });
export const getRouteDetails = (routeId) => api.get(`/api/routes/${routeId}/details`);

// Schedules endpoints
export const getSchedules = () => api.get('/api/schedules');
export const getSchedulesByRoute = (routeId) => api.get(`/api/schedules/route/${routeId}`);
export const updateScheduleLocation = (scheduleId, data) => api.post(`/api/schedules/${scheduleId}/location`, data);
export const updateScheduleStatus = (scheduleId, data) => api.patch(`/api/schedules/${scheduleId}/status`, data);
export const getActiveSchedules = () => api.get('/api/schedules/active');

// Journeys endpoints
export const getJourneys = () => api.get('/api/journeys');
export const createJourney = (data) => api.post('/api/journeys', data);
export const getJourneyDetails = (journeyId) => api.get(`/api/journeys/${journeyId}`);

export default api;
