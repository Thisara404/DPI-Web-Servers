
import { useState } from 'react';
import { useFetch } from '../hooks/useFetch';
import { getRoutes } from '../api/ndxApi';
import { useNavigate } from 'react-router-dom';
import SearchLocationsForm from '../components/forms/SearchLocationsForm';
import FindRoutesForm from '../components/forms/FindRoutesForm';

const RoutesPage = () => {
  const navigate = useNavigate();
  const { data: routes, loading, error, refetch } = useFetch(getRoutes);
  const [activeTab, setActiveTab] = useState('list');

  const handleRouteClick = (routeId) => {
    navigate(`/routes/${routeId}`);
  };

  if (loading) {
    return (
      <div className="min-h-screen px-6 pt-6">
        <div className="glass rounded-3xl p-8 animate-fade-in">
          <div className="flex items-center space-x-3">
            <div className="w-6 h-6 border-2 border-ndx-primary/30 border-t-ndx-primary rounded-full animate-spin"></div>
            <span className="text-ndx-light">Loading routes...</span>
          </div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen px-6 pt-6">
        <div className="glass rounded-3xl p-8 animate-fade-in">
          <div className="text-center">
            <p className="text-ndx-alert mb-4">Error loading routes: {error}</p>
            <button
              onClick={refetch}
              className="px-6 py-2 bg-ndx-primary text-white rounded-xl hover:bg-ndx-primary/80 transition-colors"
            >
              Retry
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen px-6 pt-6 space-y-6">
      {/* Tab Navigation */}
      <div className="glass rounded-3xl p-6 animate-fade-in">
        <div className="flex space-x-4">
          {[
            { key: 'list', label: 'Routes List' },
            { key: 'search', label: 'Search Locations' },
            { key: 'find', label: 'Find Routes' }
          ].map((tab) => (
            <button
              key={tab.key}
              onClick={() => setActiveTab(tab.key)}
              className={`px-6 py-3 rounded-xl font-medium transition-all duration-300 ${
                activeTab === tab.key
                  ? 'bg-ndx-primary text-white glow-green'
                  : 'text-ndx-light/70 hover:text-ndx-light hover:bg-white/10'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Tab Content */}
      {activeTab === 'list' && (
        <div className="glass rounded-3xl p-8 animate-fade-in">
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-2xl font-semibold text-ndx-light">Routes</h2>
            <span className="text-ndx-light/60">
              {routes?.length || 0} routes found
            </span>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-white/10">
                  <th className="text-left text-ndx-light/70 pb-4">Name</th>
                  <th className="text-left text-ndx-light/70 pb-4">Route ID</th>
                  <th className="text-left text-ndx-light/70 pb-4">Distance</th>
                  <th className="text-left text-ndx-light/70 pb-4">Stops</th>
                  <th className="text-left text-ndx-light/70 pb-4">Actions</th>
                </tr>
              </thead>
              <tbody>
                {routes?.map((route, index) => (
                  <tr
                    key={route.routeId || index}
                    className="border-b border-white/5 hover:bg-white/5 transition-colors cursor-pointer"
                    onClick={() => handleRouteClick(route.routeId)}
                  >
                    <td className="py-4 text-ndx-light">{route.name}</td>
                    <td className="py-4 text-ndx-light/70">{route.routeId}</td>
                    <td className="py-4 text-ndx-light/70">{route.distance}</td>
                    <td className="py-4 text-ndx-light/70">{route.stopsCount}</td>
                    <td className="py-4">
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleRouteClick(route.routeId);
                        }}
                        className="px-4 py-2 bg-ndx-primary/20 text-ndx-primary rounded-lg hover:bg-ndx-primary hover:text-white transition-all duration-300"
                      >
                        View Details
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {activeTab === 'search' && <SearchLocationsForm />}
      {activeTab === 'find' && <FindRoutesForm />}
    </div>
  );
};

export default RoutesPage;
