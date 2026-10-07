import React from 'react';
import { Home, Grid, Heart, Gift, User, LogOut } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';

interface NavigationProps {
  currentPage: string;
  onNavigate: (page: string) => void;
}

const Navigation: React.FC<NavigationProps> = ({ currentPage, onNavigate }) => {
  const { user, logout } = useAuth();

  const navItems = [
    { id: 'home', label: 'Home', icon: Home },
    { id: 'browse', label: 'Browse', icon: Grid },
    { id: 'donate', label: 'Donate', icon: Heart },
    { id: 'money-box', label: 'Money Box', icon: Gift },
    { id: 'profile', label: 'Profile', icon: User },
  ];

  return (
    <nav className="bg-white shadow-lg sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <h1 className="text-2xl font-bold text-blue-600">DonateHub</h1>
            </div>
          </div>

          <div className="hidden md:block">
            <div className="ml-10 flex items-baseline space-x-4">
              {navItems.map((item) => {
                const Icon = item.icon;
                return (
                  <button
                    key={item.id}
                    onClick={() => onNavigate(item.id)}
                    className={`px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                      currentPage === item.id
                        ? 'bg-blue-600 text-white'
                        : 'text-gray-700 hover:bg-blue-50 hover:text-blue-600'
                    }`}
                  >
                    <div className="flex items-center space-x-2">
                      <Icon size={16} />
                      <span>{item.label}</span>
                    </div>
                  </button>
                );
              })}
            </div>
          </div>

          <div className="hidden md:block">
            <div className="ml-4 flex items-center md:ml-6 space-x-4">
              {user && (
                <>
                  <span className="text-gray-700">{user.name}</span>
                  <button
                    onClick={logout}
                    className="text-gray-700 hover:text-red-600 transition-colors"
                  >
                    <LogOut size={20} />
                  </button>
                </>
              )}
            </div>
          </div>

          {/* Mobile menu */}
          <div className="md:hidden">
            <div className="flex space-x-2">
              {navItems.map((item) => {
                const Icon = item.icon;
                return (
                  <button
                    key={item.id}
                    onClick={() => onNavigate(item.id)}
                    className={`p-2 rounded-md transition-colors ${
                      currentPage === item.id
                        ? 'bg-blue-600 text-white'
                        : 'text-gray-700 hover:bg-blue-50'
                    }`}
                  >
                    <Icon size={20} />
                  </button>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Navigation;