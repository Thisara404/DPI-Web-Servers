import React, { useEffect, useRef } from 'react';

export default function RouteMap({ routes = [], schedules = [], route = null, osmRouteCoords = [], onMapClick = null } = {}) {
  // Uses Google Maps JS API - requires VITE_GOOGLE_MAPS_KEY
  const mapRef = useRef(null);
  const mapInstance = useRef(null);
  const polylineRef = useRef(null);
  const markersRef = useRef([]);
  const clickListenerRef = useRef(null);

  useEffect(() => {
    const key = import.meta.env.VITE_GOOGLE_MAPS_KEY || import.meta.env.GOOGLE_MAPS_API_KEY;
    if (!key) {
      console.warn('Google Maps API key not set - Google Maps will not load');
      return;
    }

    // load script if not present
    const loadScript = () => new Promise((resolve, reject) => {
      if (window.google && window.google.maps) return resolve();
      const existing = document.getElementById('ndx-google-maps');
      if (existing) {
        existing.addEventListener('load', () => resolve());
        return;
      }
      const s = document.createElement('script');
      s.id = 'ndx-google-maps';
      s.src = `https://maps.googleapis.com/maps/api/js?key=${key}`;
      s.async = true;
      s.defer = true;
      s.onload = () => resolve();
      s.onerror = (e) => reject(e);
      document.head.appendChild(s);
    });

    (async () => {
      try {
        await loadScript();
        if (!mapInstance.current) {
          mapInstance.current = new window.google.maps.Map(mapRef.current, {
            center: { lat: 6.9271, lng: 79.8612 },
            zoom: 12,
            disableDefaultUI: false,
          });
        }

        // Remove old click listener if exists
        if (clickListenerRef.current) {
          window.google.maps.event.removeListener(clickListenerRef.current);
          clickListenerRef.current = null;
        }

        // Register click listener to add a temporary marker and call onMapClick(lat,lng)
        if (typeof onMapClick === 'function') {
          clickListenerRef.current = mapInstance.current.addListener('click', (e) => {
            const lat = e.latLng.lat();
            const lng = e.latLng.lng();

            // remove previous temp marker(s)
            markersRef.current.forEach(m => m.setMap(null));
            markersRef.current = [];

            const marker = new window.google.maps.Marker({
              position: { lat, lng },
              map: mapInstance.current,
              title: 'Selected location',
              icon: {
                path: window.google.maps.SymbolPath.CIRCLE,
                scale: 7,
                fillColor: '#00ff88',
                fillOpacity: 0.95,
                strokeWeight: 1,
                strokeColor: '#fff'
              }
            });
            markersRef.current.push(marker);

            onMapClick({ lat, lng });
          });
        }

        // clear old markers (non-temp)
        // Note: keep markersRef for temp marker; non-temp markers handled below
        // add route/stops markers if provided
        if (route && route.stops) {
          // clear non-temp markers first
          markersRef.current.forEach(m => m.setMap(null));
          markersRef.current = [];

          route.stops.forEach((s) => {
            const pos = { lat: s.location?.coordinates?.[1] ?? s.lat, lng: s.location?.coordinates?.[0] ?? s.lng };
            const marker = new window.google.maps.Marker({ position: pos, map: mapInstance.current, title: s.name });
            markersRef.current.push(marker);
          });
        }

        // draw osmRouteCoords polyline if provided (array of {lat,lng})
        if (osmRouteCoords && osmRouteCoords.length > 0) {
          if (polylineRef.current) {
            polylineRef.current.setMap(null);
          }
          polylineRef.current = new window.google.maps.Polyline({
            path: osmRouteCoords,
            geodesic: true,
            strokeColor: '#00FF88',
            strokeOpacity: 0.9,
            strokeWeight: 4,
            map: mapInstance.current
          });
          // fit bounds to polyline
          const bounds = new window.google.maps.LatLngBounds();
          osmRouteCoords.forEach(p => bounds.extend(p));
          mapInstance.current.fitBounds(bounds, 40);
        }
      } catch (e) {
        console.error('Google Maps load error', e);
      }
    })();

    return () => {
      if (clickListenerRef.current && window.google && window.google.maps) {
        try { window.google.maps.event.removeListener(clickListenerRef.current); } catch {}
        clickListenerRef.current = null;
      }
      // cleanup markers
      markersRef.current.forEach(m => m.setMap(null));
      markersRef.current = [];
      if (polylineRef.current) {
        polylineRef.current.setMap(null);
        polylineRef.current = null;
      }
    };
  }, [route, osmRouteCoords, routes, schedules, onMapClick]);

  return <div ref={mapRef} style={{ width: '100%', height: '100%' }} />;
}
