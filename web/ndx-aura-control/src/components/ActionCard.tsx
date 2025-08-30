
import { LucideIcon } from 'lucide-react';

interface ActionCardProps {
  icon: LucideIcon;
  title: string;
  description: string;
  delay?: string;
}

const ActionCard = ({ icon: Icon, title, description, delay }: ActionCardProps) => {
  return (
    <div className={`glass glass-hover rounded-3xl p-8 text-center cursor-pointer animate-fade-in ${delay}`}>
      <div className="w-16 h-16 mx-auto mb-6 rounded-2xl bg-gradient-to-br from-ndx-primary to-ndx-secondary flex items-center justify-center glow-green">
        <Icon className="w-8 h-8 text-white" />
      </div>
      <h4 className="text-lg font-semibold text-ndx-light mb-2">{title}</h4>
      <p className="text-ndx-light/70 text-sm">{description}</p>
    </div>
  );
};

export default ActionCard;
