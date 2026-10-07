import React from 'react';
import { Heart, Gift, Search, DollarSign, Users, Clock, MapPin, AlertCircle } from 'lucide-react';

interface HomePageProps {
  onNavigate: (page: string) => void;
}

const HomePage: React.FC<HomePageProps> = ({ onNavigate }) => {
  const quickActions = [
    {
      title: 'Donate Items',
      description: 'Share your unused items with fellow students',
      icon: Heart,
      color: 'bg-gradient-to-r from-pink-500 to-rose-500',
      action: 'donate',
    },
    {
      title: 'Browse Items',
      description: 'Find items you need from other students',
      icon: Search,
      color: 'bg-gradient-to-r from-blue-500 to-cyan-500',
      action: 'browse',
    },
    {
      title: 'Money Box',
      description: 'Contribute or request financial assistance',
      icon: DollarSign,
      color: 'bg-gradient-to-r from-green-500 to-emerald-500',
      action: 'money-box',
    },
    {
      title: 'Vouchers',
      description: 'Access gift cards and service vouchers',
      icon: Gift,
      color: 'bg-gradient-to-r from-purple-500 to-indigo-500',
      action: 'vouchers',
    },
  ];

  const urgentNeeds = [
    {
      title: 'Textbooks for Engineering',
      category: 'Books',
      location: 'Library Area',
      timeLeft: '2 days',
      icon: AlertCircle,
    },
    {
      title: 'Laptop for Online Classes',
      category: 'Electronics',
      location: 'Computer Lab',
      timeLeft: '5 days',
      icon: AlertCircle,
    },
    {
      title: 'Winter Clothing',
      category: 'Clothing',
      location: 'Student Center',
      timeLeft: '1 week',
      icon: AlertCircle,
    },
  ];

  const stats = [
    { label: 'Items Donated', value: '1,247', icon: Heart },
    { label: 'Active Users', value: '856', icon: Users },
    { label: 'Items Claimed', value: '934', icon: Gift },
    { label: 'Money Raised', value: '₹45,230', icon: DollarSign },
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Hero Section */}
      <div className="bg-gradient-to-r from-blue-600 via-purple-600 to-teal-600 text-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
          <div className="text-center">
            <h1 className="text-4xl md:text-6xl font-bold mb-6">
              Share. Care. Connect.
            </h1>
            <p className="text-xl md:text-2xl text-white/90 max-w-3xl mx-auto">
              Building a community where students support each other through donations, 
              resources, and kindness.
            </p>
          </div>
        </div>
      </div>

      {/* Stats Section */}
      <div className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {stats.map((stat, index) => {
              const Icon = stat.icon;
              return (
                <div key={index} className="text-center">
                  <div className="flex justify-center mb-2">
                    <Icon className="w-8 h-8 text-blue-600" />
                  </div>
                  <div className="text-2xl font-bold text-gray-900">{stat.value}</div>
                  <div className="text-sm text-gray-600">{stat.label}</div>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        {/* Quick Actions */}
        <div className="mb-16">
          <h2 className="text-3xl font-bold text-gray-900 text-center mb-12">
            How can we help you today?
          </h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {quickActions.map((action, index) => {
              const Icon = action.icon;
              return (
                <div
                  key={index}
                  onClick={() => onNavigate(action.action)}
                  className="group cursor-pointer bg-white rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 transform hover:-translate-y-2 overflow-hidden"
                >
                  <div className={`${action.color} p-6`}>
                    <Icon className="w-12 h-12 text-white mb-4 group-hover:scale-110 transition-transform duration-300" />
                  </div>
                  <div className="p-6">
                    <h3 className="text-xl font-semibold text-gray-900 mb-2">
                      {action.title}
                    </h3>
                    <p className="text-gray-600 text-sm">
                      {action.description}
                    </p>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Urgent Needs */}
        <div className="mb-16">
          <h2 className="text-3xl font-bold text-gray-900 text-center mb-12">
            Urgent Needs
          </h2>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {urgentNeeds.map((need, index) => (
              <div
                key={index}
                className="bg-white rounded-xl shadow-md hover:shadow-lg transition-shadow duration-300 p-6 border-l-4 border-orange-500"
              >
                <div className="flex items-start justify-between mb-4">
                  <AlertCircle className="w-6 h-6 text-orange-500 mt-1" />
                  <span className="text-sm text-orange-600 font-medium bg-orange-100 px-2 py-1 rounded-full">
                    {need.timeLeft} left
                  </span>
                </div>
                
                <h3 className="text-lg font-semibold text-gray-900 mb-2">
                  {need.title}
                </h3>
                
                <div className="space-y-2 text-sm text-gray-600">
                  <div className="flex items-center">
                    <Gift className="w-4 h-4 mr-2" />
                    {need.category}
                  </div>
                  <div className="flex items-center">
                    <MapPin className="w-4 h-4 mr-2" />
                    {need.location}
                  </div>
                </div>
                
                <button
                  onClick={() => onNavigate('donate')}
                  className="w-full mt-4 bg-orange-500 hover:bg-orange-600 text-white py-2 px-4 rounded-lg transition-colors duration-200 font-medium"
                >
                  Help Now
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* Footer */}
        <footer className="bg-white rounded-2xl shadow-lg p-8">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div>
              <h4 className="text-lg font-semibold text-gray-900 mb-4">About DonateHub</h4>
              <p className="text-gray-600 text-sm">
                Connecting students across campus to share resources, support each other, 
                and build a stronger community through the power of giving.
              </p>
            </div>
            
            <div>
              <h4 className="text-lg font-semibold text-gray-900 mb-4">Quick Links</h4>
              <ul className="space-y-2 text-sm">
                <li>
                  <button 
                    onClick={() => onNavigate('help')}
                    className="text-gray-600 hover:text-blue-600 transition-colors"
                  >
                    Help & FAQ
                  </button>
                </li>
                <li>
                  <button 
                    onClick={() => onNavigate('contact')}
                    className="text-gray-600 hover:text-blue-600 transition-colors"
                  >
                    Contact Support
                  </button>
                </li>
                <li>
                  <span className="text-gray-600">Community Guidelines</span>
                </li>
              </ul>
            </div>
            
            <div>
              <h4 className="text-lg font-semibold text-gray-900 mb-4">Get Started</h4>
              <p className="text-gray-600 text-sm mb-4">
                Ready to make a difference? Start donating or browsing items today.
              </p>
              <div className="space-x-2">
                <button
                  onClick={() => onNavigate('donate')}
                  className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm transition-colors"
                >
                  Donate Now
                </button>
                <button
                  onClick={() => onNavigate('browse')}
                  className="border border-blue-600 text-blue-600 hover:bg-blue-50 px-4 py-2 rounded-lg text-sm transition-colors"
                >
                  Browse Items
                </button>
              </div>
            </div>
          </div>
        </footer>
      </div>
    </div>
  );
};

export default HomePage;