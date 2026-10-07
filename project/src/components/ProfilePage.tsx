import React, { useState } from 'react';
import { ArrowLeft, User, Mail, Calendar, Settings, Package, Heart, LogOut, Edit } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';

interface ProfilePageProps {
  onNavigate: (page: string, data?: any) => void;
}

const ProfilePage: React.FC<ProfilePageProps> = ({ onNavigate }) => {
  const { user, logout } = useAuth();
  const [isEditing, setIsEditing] = useState(false);
  const [formData, setFormData] = useState({
    name: user?.name || '',
    email: user?.email || '',
  });

  // Mock data for demonstration
  const profileStats = {
    itemsDonated: 12,
    itemsClaimed: 5,
    moneyDonated: 2500,
    vouchersShared: 3,
  };

  const donationHistory = [
    {
      id: '1',
      type: 'item',
      name: 'Engineering Mathematics Textbook',
      date: '2024-01-15',
      status: 'claimed',
    },
    {
      id: '2',
      type: 'money',
      amount: 500,
      date: '2024-01-14',
      purpose: 'For students facing financial difficulties',
    },
    {
      id: '3',
      type: 'voucher',
      name: 'Amazon Gift Card ₹1000',
      date: '2024-01-12',
      status: 'available',
    },
  ];

  const claimHistory = [
    {
      id: '1',
      name: 'Laptop Stand - Adjustable',
      donor: 'Mike Chen',
      date: '2024-01-10',
      status: 'completed',
    },
    {
      id: '2',
      name: 'Winter Jacket - Medium',
      donor: 'Emma Davis',
      date: '2024-01-08',
      status: 'completed',
    },
  ];

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSaveProfile = () => {
    // In a real app, this would update the user profile via API
    alert('Profile updated successfully!');
    setIsEditing(false);
  };

  const handleLogout = () => {
    if (window.confirm('Are you sure you want to logout?')) {
      logout();
      onNavigate('auth');
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-IN', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'available':
        return 'bg-green-100 text-green-800';
      case 'claimed':
        return 'bg-blue-100 text-blue-800';
      case 'completed':
        return 'bg-gray-100 text-gray-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Header */}
        <div className="mb-8">
          <button
            onClick={() => onNavigate('home')}
            className="flex items-center text-gray-600 hover:text-gray-900 transition-colors mb-4"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back to Home
          </button>
          
          <h1 className="text-4xl font-bold text-gray-900 mb-2">
            My Profile
          </h1>
          <p className="text-gray-600 text-lg">
            Manage your account and view your donation activity
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Profile Information */}
          <div className="lg:col-span-1">
            <div className="bg-white rounded-2xl shadow-lg overflow-hidden">
              {/* Profile Header */}
              <div className="bg-gradient-to-r from-blue-600 to-purple-600 p-6 text-white">
                <div className="flex items-center justify-between mb-4">
                  <div className="w-20 h-20 bg-white/20 rounded-full flex items-center justify-center">
                    <User className="w-10 h-10" />
                  </div>
                  <button
                    onClick={() => setIsEditing(!isEditing)}
                    className="p-2 hover:bg-white/20 rounded-lg transition-colors"
                  >
                    <Edit className="w-5 h-5" />
                  </button>
                </div>
                
                {isEditing ? (
                  <div className="space-y-3">
                    <input
                      type="text"
                      name="name"
                      value={formData.name}
                      onChange={handleInputChange}
                      className="w-full px-3 py-2 text-gray-900 rounded-lg"
                      placeholder="Full Name"
                    />
                    <input
                      type="email"
                      name="email"
                      value={formData.email}
                      onChange={handleInputChange}
                      className="w-full px-3 py-2 text-gray-900 rounded-lg"
                      placeholder="Email"
                    />
                    <div className="flex space-x-2">
                      <button
                        onClick={handleSaveProfile}
                        className="flex-1 bg-white text-blue-600 py-2 px-4 rounded-lg font-medium hover:bg-gray-100 transition-colors"
                      >
                        Save
                      </button>
                      <button
                        onClick={() => setIsEditing(false)}
                        className="flex-1 bg-white/20 text-white py-2 px-4 rounded-lg font-medium hover:bg-white/30 transition-colors"
                      >
                        Cancel
                      </button>
                    </div>
                  </div>
                ) : (
                  <div>
                    <h2 className="text-2xl font-bold mb-1">{user?.name}</h2>
                    <p className="text-blue-100">{user?.email}</p>
                    <p className="text-sm text-blue-200 mt-2 capitalize">{user?.role}</p>
                  </div>
                )}
              </div>

              {/* Profile Details */}
              <div className="p-6">
                <div className="space-y-4">
                  <div className="flex items-center text-gray-600">
                    <Mail className="w-5 h-5 mr-3" />
                    <span className="text-sm">{user?.email}</span>
                  </div>
                  <div className="flex items-center text-gray-600">
                    <Calendar className="w-5 h-5 mr-3" />
                    <span className="text-sm">
                      Joined {user?.created_at ? formatDate(user.created_at) : 'Recently'}
                    </span>
                  </div>
                  <div className="flex items-center text-gray-600">
                    <Settings className="w-5 h-5 mr-3" />
                    <span className="text-sm capitalize">{user?.role} Account</span>
                  </div>
                </div>

                <button
                  onClick={handleLogout}
                  className="w-full mt-6 bg-red-600 hover:bg-red-700 text-white py-3 px-4 rounded-lg font-medium transition-colors flex items-center justify-center"
                >
                  <LogOut className="w-5 h-5 mr-2" />
                  Logout
                </button>
              </div>
            </div>

            {/* Stats Overview */}
            <div className="mt-6 bg-white rounded-2xl shadow-lg p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">
                Activity Summary
              </h3>
              
              <div className="grid grid-cols-2 gap-4">
                <div className="text-center p-3 bg-blue-50 rounded-lg">
                  <Package className="w-6 h-6 text-blue-600 mx-auto mb-1" />
                  <div className="text-2xl font-bold text-blue-900">
                    {profileStats.itemsDonated}
                  </div>
                  <div className="text-xs text-blue-600">Items Donated</div>
                </div>
                
                <div className="text-center p-3 bg-green-50 rounded-lg">
                  <Heart className="w-6 h-6 text-green-600 mx-auto mb-1" />
                  <div className="text-2xl font-bold text-green-900">
                    {profileStats.itemsClaimed}
                  </div>
                  <div className="text-xs text-green-600">Items Claimed</div>
                </div>
              </div>

              <div className="mt-4 p-3 bg-purple-50 rounded-lg text-center">
                <div className="text-lg font-bold text-purple-900">
                  ₹{profileStats.moneyDonated.toLocaleString()}
                </div>
                <div className="text-xs text-purple-600">Money Donated</div>
              </div>
            </div>
          </div>

          {/* Activity History */}
          <div className="lg:col-span-2 space-y-6">
            {/* Donation History */}
            <div className="bg-white rounded-2xl shadow-lg p-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-6">
                Donation History
              </h3>
              
              <div className="space-y-4">
                {donationHistory.map((donation) => (
                  <div
                    key={donation.id}
                    className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow"
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        {donation.type === 'item' && (
                          <>
                            <h4 className="font-semibold text-gray-900 mb-1">
                              {donation.name}
                            </h4>
                            <p className="text-sm text-blue-600 mb-1">Item Donation</p>
                          </>
                        )}
                        
                        {donation.type === 'money' && (
                          <>
                            <h4 className="font-semibold text-gray-900 mb-1">
                              ₹{donation.amount} Donation
                            </h4>
                            <p className="text-sm text-green-600 mb-1">Money Box</p>
                            <p className="text-sm text-gray-600 mb-1">
                              {donation.purpose}
                            </p>
                          </>
                        )}
                        
                        {donation.type === 'voucher' && (
                          <>
                            <h4 className="font-semibold text-gray-900 mb-1">
                              {donation.name}
                            </h4>
                            <p className="text-sm text-purple-600 mb-1">Voucher</p>
                          </>
                        )}
                        
                        <p className="text-xs text-gray-500">
                          {formatDate(donation.date)}
                        </p>
                      </div>
                      
                      {(donation as any).status && (
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor((donation as any).status)}`}>
                          {(donation as any).status}
                        </span>
                      )}
                    </div>
                  </div>
                ))}
              </div>
              
              <div className="text-center mt-4">
                <button className="text-blue-600 hover:text-blue-800 font-medium">
                  View All Donations
                </button>
              </div>
            </div>

            {/* Claim History */}
            <div className="bg-white rounded-2xl shadow-lg p-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-6">
                Claim History
              </h3>
              
              <div className="space-y-4">
                {claimHistory.map((claim) => (
                  <div
                    key={claim.id}
                    className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow"
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <h4 className="font-semibold text-gray-900 mb-1">
                          {claim.name}
                        </h4>
                        <p className="text-sm text-gray-600 mb-1">
                          From {claim.donor}
                        </p>
                        <p className="text-xs text-gray-500">
                          {formatDate(claim.date)}
                        </p>
                      </div>
                      
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(claim.status)}`}>
                        {claim.status}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
              
              <div className="text-center mt-4">
                <button 
                  onClick={() => onNavigate('my-claims')}
                  className="text-blue-600 hover:text-blue-800 font-medium"
                >
                  View All Claims
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProfilePage;