import axios from 'axios';

const baseURL = import.meta.env.VITE_NDX_URL || 'http://localhost:3002';
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

// Replace getRouteDetails with a guard that rejects when routeId is falsy
export const getRouteDetails = (routeId) => {
  if (!routeId && typeof routeId !== 'number') {
    return Promise.reject(new Error('getRouteDetails: routeId is required'));
  }
  // encode routeId to avoid malformed URLs
  const id = encodeURIComponent(String(routeId));
  return client.get(`/api/routes/${id}/details`);
};
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
export const getJourneys = (params) => client.get('/api/journeys/passenger', { params, headers: authHeaders() });
export const getJourneyDetails = (journeyId) => client.get(`/api/journeys/${journeyId}`, { headers: authHeaders() });
export const bookJourney = (payload) => client.post('/api/journeys/book', payload, { headers: authHeaders() });
export const cancelJourney = (journeyId) => client.post(`/api/journeys/${journeyId}/cancel`, {}, { headers: authHeaders() });
export const verifyJourney = (journeyId) => client.post(`/api/journeys/${journeyId}/verify`, {}, { headers: authHeaders() });
export const trackJourney = (journeyId, payload) => client.post(`/api/journeys/${journeyId}/track`, payload, { headers: authHeaders() });
export const payJourney = (journeyId, payload) => client.post(`/api/journeys/${journeyId}/pay`, payload, { headers: authHeaders() });

// ---------- OpenStreetMap / Routing helpers ----------

// Nominatim search (OpenStreetMap) - no API key required, please respect rate limits
export const searchNominatim = (query, limit = 8) =>
  axios.get('https://nominatim.openstreetmap.org/search', {
    params: { q: query, format: 'json', limit },
    headers: { 'User-Agent': 'ndx-aura-control/1.0 (you@yourdomain.com)' }
  });

// Utility: decode encoded polyline (Google/OSRM polyline) -> array of [lat, lng]
function decodePolyline(encoded) {
  if (!encoded) return [];
  let index = 0, lat = 0, lng = 0, coordinates = [];
  while (index < encoded.length) {
    let b, shift = 0, result = 0;
    do {
      b = encoded.charCodeAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    const dlat = (result & 1) ? ~(result >> 1) : (result >> 1);
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.charCodeAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    const dlng = (result & 1) ? ~(result >> 1) : (result >> 1);
    lng += dlng;

    coordinates.push([lat / 1e5, lng / 1e5]);
  }
  // return as [{lat, lng}, ...]
  return coordinates.map(([lat, lng]) => ({ lat, lng }));
}

// Get route geometry between two points
// from/to should be objects { lat, lng } or arrays [lng,lat] / [lat,lng]
export async function getRouteBetween(from, to, profile = 'driving') {
  // prefer OpenRouteService if API key provided
  const ORS_KEY = import.meta.env.VITE_ORS_KEY;
  try {
    if (ORS_KEY) {
      // ORS expects [lng,lat]
      const coords = [
        [from.lng ?? from[1] ?? from[0], from.lat ?? from[0] ?? from[1]],
        [to.lng ?? to[1] ?? to[0], to.lat ?? to[0] ?? to[1]]
      ];
      const res = await axios.post(
        `https://api.openrouteservice.org/v2/directions/${profile}/geojson`,
        { coordinates: coords },
        { headers: { Authorization: ORS_KEY, 'Content-Type': 'application/json' } }
      );
      // geojson LineString coordinates are [lng,lat]
      const coordsArr = res.data?.features?.[0]?.geometry?.coordinates || [];
      return coordsArr.map(([lng, lat]) => ({ lat, lng }));
    } else {
      // Fallback to OSRM public demo server (no key). OSRM returns encoded polyline by default.
      const fromStr = `${from.lng ?? from[1] ?? from[0]},${from.lat ?? from[0] ?? from[1]}`;
      const toStr = `${to.lng ?? to[1] ?? to[0]},${to.lat ?? to[0] ?? to[1]}`;
      const osrmUrl = `https://router.project-osrm.org/route/v1/${profile}/${fromStr};${toStr}?overview=full&geometries=polyline`;
      const res = await axios.get(osrmUrl);
      if (res.data && res.data.routes && res.data.routes[0] && res.data.routes[0].geometry) {
        return decodePolyline(res.data.routes[0].geometry); // returns [{lat,lng},...]
      }
    }
  } catch (err) {
    console.error('Routing error:', err);
    throw err;
  }
  return [];
}

// Add createRoute helper (uses server route: POST /api/routes)
export const createRoute = (payload) =>
  client.post('/api/routes', payload, { headers: authHeaders() });

// Ensure searchNominatim exists (use directly from client if needed)
// export const searchNominatim = (query, limit = 8) => axios.get('https://nominatim.openstreetmap.org/search', { params: { q: query, format: 'json', limit } });

export default client;
