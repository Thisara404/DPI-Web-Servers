
import RouteStatusItem from './RouteStatusItem';

const RouteStatus = () => {
  const routes = [
    { route: 'Route 101', destination: 'City Center → Airport', status: 'ACTIVE' as const, time: 'Next: 8 min' },
    { route: 'Route 205', destination: 'Mall → University', status: 'DELAYED' as const, time: 'Delayed: 15 min' },
    { route: 'Route 78', destination: 'Harbor → Downtown', status: 'ACTIVE' as const, time: 'Next: 3 min' },
    { route: 'Route 142', destination: 'Station → Business Park', status: 'SCHEDULED' as const, time: 'Starts: 2:30 PM' },
    { route: 'Route 89', destination: 'Residential → Shopping', status: 'ACTIVE' as const, time: 'Next: 12 min' },
    { route: 'Route 356', destination: 'Industrial → Port', status: 'DELAYED' as const, time: 'Delayed: 8 min' },
  ];

  return (
    <div className="glass rounded-3xl p-6 h-96 animate-slide-up animate-stagger-2">
      <div className="flex items-center justify-between mb-6">
        <h3 className="text-xl font-semibold text-ndx-light">Live Route Status</h3>
        <div className="w-2 h-2 bg-ndx-primary rounded-full pulse-green"></div>
      </div>
      
      <div className="overflow-y-auto h-80 pr-2 scrollbar-thin scrollbar-track-transparent scrollbar-thumb-white/20">
        {routes.map((route, index) => (
          <RouteStatusItem key={index} {...route} />
        ))}
      </div>
    </div>
  );
};

export default RouteStatus;
