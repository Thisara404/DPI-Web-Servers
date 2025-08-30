
import { RefreshCw, Settings, Plus } from 'lucide-react';

const FloatingControls = () => {
  return (
    <div className="fixed bottom-8 right-8 flex flex-col space-y-4 z-50">
      <button className="w-14 h-14 glass rounded-full flex items-center justify-center text-white bg-gradient-to-br from-ndx-primary to-ndx-secondary hover:scale-110 transition-all duration-300 glow-green">
        <Plus className="w-6 h-6" />
      </button>
      <button className="w-14 h-14 glass rounded-full flex items-center justify-center text-white bg-gradient-to-br from-ndx-primary to-ndx-secondary hover:scale-110 transition-all duration-300 glow-green">
        <Settings className="w-6 h-6" />
      </button>
      <button className="w-14 h-14 glass rounded-full flex items-center justify-center text-white bg-gradient-to-br from-ndx-primary to-ndx-secondary hover:scale-110 transition-all duration-300 glow-green float">
        <RefreshCw className="w-6 h-6" />
      </button>
    </div>
  );
};

export default FloatingControls;
