
interface RouteStatusItemProps {
  route: string;
  destination: string;
  status: 'ACTIVE' | 'DELAYED' | 'SCHEDULED';
  time?: string;
}

const RouteStatusItem = ({ route, destination, status, time }: RouteStatusItemProps) => {
  const getStatusStyles = (status: string) => {
    switch (status) {
      case 'ACTIVE':
        return 'bg-ndx-primary text-white';
      case 'DELAYED':
        return 'bg-ndx-alert text-white';
      case 'SCHEDULED':
        return 'bg-ndx-secondary text-ndx-light';
      default:
        return 'bg-white/20 text-ndx-light';
    }
  };

  return (
    <div className="glass glass-hover rounded-2xl p-4 mb-3 transition-all duration-300 hover:border-ndx-primary/50">
      <div className="flex items-center justify-between mb-2">
        <h4 className="font-semibold text-ndx-light text-lg">{route}</h4>
        <span className={`px-3 py-1 rounded-full text-xs font-medium ${getStatusStyles(status)}`}>
          {status}
        </span>
      </div>
      <p className="text-ndx-light/70 text-sm mb-1">{destination}</p>
      {time && <p className="text-ndx-light/50 text-xs">{time}</p>}
    </div>
  );
};

export default RouteStatusItem;
