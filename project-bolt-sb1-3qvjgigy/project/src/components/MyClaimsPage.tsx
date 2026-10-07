import React, { useState, useEffect } from 'react';
import { ArrowLeft, QrCode, MapPin, Clock, Package, User, Filter } from 'lucide-react';

interface MyClaimsPageProps {
  onNavigate: (page: string, data?: any) => void;
}

const MyClaimsPage: React.FC<MyClaimsPageProps> = ({ onNavigate }) => {
  const [claims, setClaims] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<'pending' | 'confirmed' | 'completed'>('pending');

  useEffect(() => {
    fetchClaims();
  }, []);

  const fetchClaims = async () => {
    try {
      // Mock data for demonstration
      const mockClaims = [
        {
          id: '1',
          item_id: '1',
          claim_code: 'ABC123',
          status: 'pending',
          created_at: '2024-01-15T10:30:00Z',
          item: {
            id: '1',
            name: 'Engineering Mathematics Textbook',
            description: 'Complete textbook for Engineering Mathematics',
            category: 'Books & Study Material',
            photo_url: 'https://images.pexels.com/photos/159866/books-book-pages-read-literature-159866.jpeg',
            location: 'Main Library',
            donor_name: 'Sarah Johnson',
          }
        },
        {
          id: '2',
          item_id: '2',
          claim_code: 'XYZ789',
          status: 'confirmed',
          created_at: '2024-01-14T15:45:00Z',
          item: {
            id: '2',
            name: 'Laptop Stand - Adjustable',
            description: 'Ergonomic laptop stand, barely used',
            category: 'Electronics',
            photo_url: 'https://images.pexels.com/photos/7974/pexels-photo.jpg',
            location: 'Computer Lab',
            donor_name: 'Mike Chen',
          }
        },
        {
          id: '3',
          item_id: '3',
          claim_code: 'DEF456',
          status: 'completed',
          created_at: '2024-01-13T09:20:00Z',
          item: {
            id: '3',
            name: 'Winter Jacket - Medium',
            description: 'Warm winter jacket in medium size',
            category: 'Clothing & Accessories',
            photo_url: 'https://images.pexels.com/photos/1124465/pexels-photo-1124465.jpeg',
            location: 'Student Center',
            donor_name: 'Emma Davis',
          }
        },
      ];
      
      setClaims(mockClaims);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching claims:', error);
      setLoading(false);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending':
        return 'bg-yellow-100 text-yellow-800';
      case 'confirmed':
        return 'bg-blue-100 text-blue-800';
      case 'completed':
        return 'bg-green-100 text-green-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'pending':
        return <Clock className="w-4 h-4" />;
      case 'confirmed':
        return <Package className="w-4 h-4" />;
      case 'completed':
        return <QrCode className="w-4 h-4" />;
      default:
        return <Clock className="w-4 h-4" />;
    }
  };

  const filteredClaims = claims.filter(claim => claim.status === activeTab);

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-blue-600 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-gray-600">Loading your claims...</p>
        </div>
      </div>
    );
  }

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
            My Claims
          </h1>
          <p className="text-gray-600 text-lg">
            Track your claimed items and pickup status
          </p>
        </div>

        {/* Status Tabs */}
        <div className="bg-white rounded-2xl shadow-lg mb-8">
          <div className="border-b border-gray-200">
            <nav className="flex">
              {[
                { key: 'pending', label: 'Pending', count: claims.filter(c => c.status === 'pending').length },
                { key: 'confirmed', label: 'Confirmed', count: claims.filter(c => c.status === 'confirmed').length },
                { key: 'completed', label: 'Completed', count: claims.filter(c => c.status === 'completed').length },
              ].map((tab) => (
                <button
                  key={tab.key}
                  onClick={() => setActiveTab(tab.key as any)}
                  className={`flex-1 py-4 px-6 text-sm font-medium border-b-2 transition-colors ${
                    activeTab === tab.key
                      ? 'text-blue-600 border-blue-600'
                      : 'text-gray-500 border-transparent hover:text-gray-700'
                  }`}
                >
                  {tab.label}
                  {tab.count > 0 && (
                    <span className={`ml-2 px-2 py-1 text-xs rounded-full ${
                      activeTab === tab.key
                        ? 'bg-blue-100 text-blue-600'
                        : 'bg-gray-100 text-gray-600'
                    }`}>
                      {tab.count}
                    </span>
                  )}
                </button>
              ))}
            </nav>
          </div>

          <div className="p-6">
            {filteredClaims.length === 0 ? (
              <div className="text-center py-12">
                <Package className="w-16 h-16 text-gray-400 mx-auto mb-4" />
                <h3 className="text-xl font-semibold text-gray-900 mb-2">
                  No {activeTab} claims
                </h3>
                <p className="text-gray-600 mb-4">
                  {activeTab === 'pending' && "You don't have any pending claims at the moment."}
                  {activeTab === 'confirmed' && "You don't have any confirmed claims ready for pickup."}
                  {activeTab === 'completed' && "You haven't completed any claims yet."}
                </p>
                <button
                  onClick={() => onNavigate('browse')}
                  className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg transition-colors"
                >
                  Browse Items
                </button>
              </div>
            ) : (
              <div className="space-y-4">
                {filteredClaims.map((claim) => (
                  <div
                    key={claim.id}
                    className="bg-gray-50 rounded-xl p-6 hover:shadow-md transition-shadow"
                  >
                    <div className="flex items-start space-x-4">
                      {/* Item Image */}
                      <img
                        src={claim.item.photo_url}
                        alt={claim.item.name}
                        className="w-20 h-20 object-cover rounded-lg flex-shrink-0"
                      />

                      {/* Item Details */}
                      <div className="flex-1 min-w-0">
                        <div className="flex items-start justify-between mb-2">
                          <h3 className="text-lg font-semibold text-gray-900 truncate">
                            {claim.item.name}
                          </h3>
                          <span className={`flex items-center px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(claim.status)}`}>
                            {getStatusIcon(claim.status)}
                            <span className="ml-1 capitalize">{claim.status}</span>
                          </span>
                        </div>

                        <p className="text-blue-600 font-medium mb-2">
                          {claim.item.category}
                        </p>

                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm text-gray-600">
                          <div className="flex items-center">
                            <User className="w-4 h-4 mr-2" />
                            {claim.item.donor_name}
                          </div>
                          <div className="flex items-center">
                            <MapPin className="w-4 h-4 mr-2" />
                            {claim.item.location}
                          </div>
                          <div className="flex items-center">
                            <Clock className="w-4 h-4 mr-2" />
                            Claimed {formatDate(claim.created_at)}
                          </div>
                          <div className="flex items-center">
                            <QrCode className="w-4 h-4 mr-2" />
                            Code: {claim.claim_code}
                          </div>
                        </div>

                        {/* Status-specific actions */}
                        <div className="mt-4 flex flex-wrap gap-2">
                          {claim.status === 'pending' && (
                            <span className="text-sm text-yellow-700 bg-yellow-100 px-3 py-1 rounded-full">
                              Waiting for donor confirmation
                            </span>
                          )}
                          
                          {claim.status === 'confirmed' && (
                            <>
                              <button
                                onClick={() => onNavigate('claim-confirmation', {
                                  claimCode: claim.claim_code,
                                  item: claim.item,
                                  timeSlot: '11:00 AM - 1:00 PM' // This would come from the actual claim data
                                })}
                                className="text-sm bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors"
                              >
                                View Pickup Details
                              </button>
                              <span className="text-sm text-blue-700 bg-blue-100 px-3 py-1 rounded-full">
                                Ready for pickup
                              </span>
                            </>
                          )}
                          
                          {claim.status === 'completed' && (
                            <span className="text-sm text-green-700 bg-green-100 px-3 py-1 rounded-full">
                              Successfully picked up
                            </span>
                          )}
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default MyClaimsPage;