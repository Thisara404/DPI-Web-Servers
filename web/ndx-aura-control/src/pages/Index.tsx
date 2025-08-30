
import Header from '../components/Header';
import MetricsCard from '../components/MetricsCard';
import RouteMap from '../components/RouteMap';
import RouteStatus from '../components/RouteStatus';
import ActionCard from '../components/ActionCard';
import FloatingControls from '../components/FloatingControls';
import { MapPin, Calendar, Ticket, BarChart3 } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const Index = () => {
  const navigate = useNavigate();

  const actionCards = [
    {
      icon: MapPin,
      title: "Search Locations",
      description: "Find stops and addresses",
      delay: "animate-stagger-1",
      onClick: () => navigate('/routes')
    },
    {
      icon: Calendar,
      title: "Manage Schedules",
      description: "Update driver locations",
      delay: "animate-stagger-2",
      onClick: () => navigate('/schedules')
    },
    {
      icon: Ticket,
      title: "Book Journey",
      description: "Create new bookings",
      delay: "animate-stagger-3",
      onClick: () => navigate('/journeys')
    },
    {
      icon: BarChart3,
      title: "Analytics",
      description: "View performance data",
      delay: "animate-stagger-4",
      onClick: () => navigate('/analytics')
    }
  ];

  return (
    <div className="min-h-screen">
      <div className="px-6 space-y-8">
        {/* Metrics Row */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <MetricsCard
            title="Active Routes"
            value="24"
            subtitle="Currently running"
            delay="animate-stagger-1"
          />
          <MetricsCard
            title="Schedule Efficiency"
            value="87"
            subtitle="On-time performance"
            type="progress"
            progress={87}
            delay="animate-stagger-2"
          />
          <MetricsCard
            title="Active Journeys"
            value="156"
            subtitle="Passengers traveling"
            delay="animate-stagger-3"
          />
        </div>

        {/* Main Content Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2">
            <RouteMap />
          </div>
          <div>
            <RouteStatus />
          </div>
        </div>

        {/* Action Cards */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 pb-8">
          {actionCards.map((card, index) => (
            <div key={index} onClick={card.onClick}>
              <ActionCard
                icon={card.icon}
                title={card.title}
                description={card.description}
                delay={card.delay}
              />
            </div>
          ))}
        </div>
      </div>

      {/* Floating Controls */}
      <FloatingControls />
    </div>
  );
};

export default Index;
