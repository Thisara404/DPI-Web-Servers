
const RouteMap = () => {
  return (
    <div className="glass glass-hover rounded-3xl p-6 h-96 relative overflow-hidden animate-slide-up animate-stagger-1">
      {/* Control Panels */}
      <div className="absolute top-6 left-6 z-10">
        <div className="glass rounded-2xl p-3 flex space-x-2">
          <button className="px-4 py-2 bg-ndx-primary/20 text-ndx-primary rounded-xl text-sm font-medium hover:bg-ndx-primary/30 transition-all duration-300">
            Routes
          </button>
          <button className="px-4 py-2 text-ndx-light/60 rounded-xl text-sm font-medium hover:bg-white/10 transition-all duration-300">
            Traffic
          </button>
          <button className="px-4 py-2 text-ndx-light/60 rounded-xl text-sm font-medium hover:bg-white/10 transition-all duration-300">
            Stops
          </button>
        </div>
      </div>

      <div className="absolute top-6 right-6 z-10">
        <div className="glass rounded-2xl p-2 flex flex-col space-y-1">
          <button className="w-8 h-8 flex items-center justify-center text-ndx-light/60 hover:text-ndx-primary hover:bg-ndx-primary/20 rounded-lg transition-all duration-300">
            +
          </button>
          <button className="w-8 h-8 flex items-center justify-center text-ndx-light/60 hover:text-ndx-primary hover:bg-ndx-primary/20 rounded-lg transition-all duration-300">
            −
          </button>
        </div>
      </div>

      {/* Map Background */}
      <div className="w-full h-full bg-gradient-to-br from-ndx-dark/50 to-ndx-secondary/30 rounded-2xl relative overflow-hidden">
        {/* Mock Route Lines */}
        <svg className="absolute inset-0 w-full h-full" viewBox="0 0 400 300">
          <defs>
            <linearGradient id="routeGradient" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stopColor="hsl(var(--ndx-primary))" />
              <stop offset="50%" stopColor="hsl(var(--ndx-secondary))" />
              <stop offset="100%" stopColor="hsl(var(--ndx-alert))" />
            </linearGradient>
          </defs>
          
          {/* Route Line 1 */}
          <path
            d="M50 100 Q150 50 250 120 T350 80"
            stroke="url(#routeGradient)"
            strokeWidth="3"
            fill="none"
            className="route-line opacity-80"
          />
          
          {/* Route Line 2 */}
          <path
            d="M80 200 Q180 160 280 200 T380 180"
            stroke="url(#routeGradient)"
            strokeWidth="3"
            fill="none"
            className="route-line opacity-60"
            style={{ animationDelay: '5s' }}
          />
          
          {/* Route Line 3 */}
          <path
            d="M30 250 Q130 220 230 250 T330 230"
            stroke="url(#routeGradient)"
            strokeWidth="2"
            fill="none"
            className="route-line opacity-40"
            style={{ animationDelay: '10s' }}
          />
        </svg>

        {/* Bus Markers */}
        <div className="absolute top-20 left-32 w-4 h-4 bg-ndx-primary rounded-full border-2 border-white pulse-green shadow-lg"></div>
        <div className="absolute top-36 right-24 w-4 h-4 bg-ndx-primary rounded-full border-2 border-white pulse-green shadow-lg" style={{ animationDelay: '1s' }}></div>
        <div className="absolute bottom-20 left-20 w-4 h-4 bg-ndx-alert rounded-full border-2 border-white pulse-green shadow-lg" style={{ animationDelay: '2s' }}></div>
        <div className="absolute bottom-32 right-16 w-4 h-4 bg-ndx-primary rounded-full border-2 border-white pulse-green shadow-lg" style={{ animationDelay: '0.5s' }}></div>

        {/* Grid Overlay */}
        <div className="absolute inset-0 opacity-10">
          <div className="grid grid-cols-8 grid-rows-6 h-full">
            {Array.from({ length: 48 }).map((_, i) => (
              <div key={i} className="border border-white/20"></div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default RouteMap;
