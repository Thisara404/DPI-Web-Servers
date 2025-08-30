
import { Search, Radio, LogOut, User } from "lucide-react";
import { useAuth } from "../hooks/useAuth";
import { useNavigate, useLocation } from "react-router-dom";

const Header = () => {
  const { logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = () => {
    logout();
    navigate('/auth');
  };

  const navItems = [
    { path: '/', label: 'Dashboard' },
    { path: '/routes', label: 'Routes' },
    { path: '/schedules', label: 'Schedules' },
    { path: '/journeys', label: 'Journeys' },
    { path: '/analytics', label: 'Analytics' },
  ];

  return (
    <header className="glass rounded-3xl mx-6 mt-6 mb-8 h-20 flex items-center justify-between px-8 animate-fade-in">
      {/* Brand */}
      <div className="flex items-center space-x-4">
        <div 
          className="w-10 h-10 rounded-xl bg-gradient-to-br from-ndx-primary to-ndx-secondary flex items-center justify-center cursor-pointer"
          onClick={() => navigate('/')}
        >
          <span className="text-white font-bold text-lg">N</span>
        </div>
        <h1 className="text-2xl font-semibold text-ndx-light">NDX Transport Dashboard</h1>
      </div>

      {/* Navigation */}
      <nav className="hidden md:flex items-center space-x-6">
        {navItems.map((item) => (
          <button
            key={item.path}
            onClick={() => navigate(item.path)}
            className={`px-4 py-2 rounded-lg font-medium transition-all duration-300 ${
              location.pathname === item.path
                ? 'bg-ndx-primary text-white'
                : 'text-ndx-light/70 hover:text-ndx-light hover:bg-white/10'
            }`}
          >
            {item.label}
          </button>
        ))}
      </nav>

      {/* Search Bar */}
      <div className="flex-1 max-w-md mx-12 hidden lg:block">
        <div className="relative">
          <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 text-ndx-light/60 h-5 w-5" />
          <input
            type="text"
            placeholder="Search routes, locations..."
            className="w-full h-12 pl-12 pr-6 bg-white/10 border border-white/20 rounded-2xl text-ndx-light placeholder-ndx-light/60 focus:outline-none focus:ring-2 focus:ring-ndx-primary/50 focus:border-ndx-primary/50 backdrop-blur-md transition-all duration-300"
          />
        </div>
      </div>

      {/* Status & User Actions */}
      <div className="flex items-center space-x-4">
        {/* Live Status */}
        <div className="flex items-center space-x-2">
          <div className="w-3 h-3 bg-ndx-primary rounded-full pulse-green"></div>
          <span className="text-ndx-primary font-medium text-sm tracking-wide">LIVE</span>
        </div>
        <Radio className="text-ndx-primary h-5 w-5" />
        
        {/* User Menu */}
        <div className="flex items-center space-x-2 pl-4 border-l border-white/20">
          <User className="w-5 h-5 text-ndx-light/60" />
          <button
            onClick={handleLogout}
            className="flex items-center space-x-2 px-3 py-2 rounded-lg text-ndx-light/70 hover:text-ndx-light hover:bg-white/10 transition-all duration-300"
            title="Logout"
          >
            <LogOut className="w-4 h-4" />
            <span className="hidden sm:inline">Logout</span>
          </button>
        </div>
      </div>
    </header>
  );
};

export default Header;
