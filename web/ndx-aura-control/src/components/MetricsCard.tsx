
interface MetricsCardProps {
  title: string;
  value: string | number;
  subtitle: string;
  type?: 'number' | 'progress';
  progress?: number;
  delay?: string;
}

const MetricsCard = ({ title, value, subtitle, type = 'number', progress, delay }: MetricsCardProps) => {
  return (
    <div className={`glass glass-hover rounded-3xl p-8 text-center animate-fade-in ${delay}`}>
      <h3 className="text-ndx-light/80 text-lg font-medium mb-6">{title}</h3>
      
      {type === 'number' ? (
        <div className="mb-4">
          <span className="text-6xl font-bold text-ndx-primary pulse-green">{value}</span>
        </div>
      ) : (
        <div className="mb-6 flex justify-center">
          <div className="relative w-24 h-24">
            {/* Background circle */}
            <svg className="w-24 h-24 transform -rotate-90" viewBox="0 0 100 100">
              <circle
                cx="50"
                cy="50"
                r="40"
                stroke="rgba(238,238,238,0.2)"
                strokeWidth="8"
                fill="transparent"
              />
              <circle
                cx="50"
                cy="50"
                r="40"
                stroke="url(#gradient)"
                strokeWidth="8"
                fill="transparent"
                strokeDasharray={`${2 * Math.PI * 40}`}
                strokeDashoffset={`${2 * Math.PI * 40 * (1 - (progress || 0) / 100)}`}
                className="transition-all duration-1000 ease-out"
                strokeLinecap="round"
              />
              <defs>
                <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" stopColor="hsl(var(--ndx-primary))" />
                  <stop offset="100%" stopColor="hsl(var(--ndx-secondary))" />
                </linearGradient>
              </defs>
            </svg>
            {/* Center text */}
            <div className="absolute inset-0 flex items-center justify-center">
              <span className="text-2xl font-bold text-ndx-primary">{value}%</span>
            </div>
          </div>
        </div>
      )}
      
      <p className="text-ndx-light/70 text-sm font-medium">{subtitle}</p>
    </div>
  );
};

export default MetricsCard;
