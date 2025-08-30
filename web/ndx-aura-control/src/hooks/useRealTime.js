import { useEffect, useState } from 'react';
import { getSchedules } from '@/api/ndxApi';

export function useRealTimeSchedules(interval = 5000) {
  const [schedules, setSchedules] = useState([]);

  useEffect(() => {
    const fetchSchedules = async () => {
      try {
        const res = await getSchedules();
        setSchedules(res.data?.data || res.data || []);
      } catch (err) {
        console.error('Failed to fetch real-time schedules:', err);
      }
    };

    fetchSchedules();
    const timer = setInterval(fetchSchedules, interval);
    return () => clearInterval(timer);
  }, [interval]);

  return schedules;
}