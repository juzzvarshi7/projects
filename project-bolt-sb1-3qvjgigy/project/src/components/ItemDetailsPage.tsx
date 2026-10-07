import React, { useState } from 'react';
import { ArrowLeft, MapPin, User, Clock, Package, AlertTriangle, Calendar } from 'lucide-react';

interface ItemDetailsPageProps {
  onNavigate: (page: string, data?: any) => void;
  item: any;
}

const ItemDetailsPage: React.FC<ItemDetailsPageProps> = ({ onNavigate, item }) => {
  const [selectedTimeSlot, setSelectedTimeSlot] = useState('');
  const [showClaimModal, setShowClaimModal] = useState(false);

  if (!item) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Item not found</h2>
          <button
            onClick={() => onNavigate('browse')}
            className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg transition-colors"
          >
            Back to Browse
          </button>
        </div>
      </div>
    );
  }

  const timeSlots = [
    { value: '9-11', label: '9:00 AM - 11:00 AM' },
    { value: '11-13', label: '11:00 AM - 1:00 PM' },
    { value: '13-15', label: '1:00 PM - 3:00 PM' },
    { value: '15-17', label: '3:00 PM - 5:00 PM' },
    { value: '17-19', label: '5:00 PM - 7:00 PM' },
  ];

  const conditions = {
    'new': { label: 'Brand New', color: 'bg-green-100 text-green-800', description: 'Never used, in original packaging' },
    'like-new': { label: 'Like New', color: 'bg-blue-100 text-blue-800', description: 'Barely used, excellent condition' },
    'good': { label: 'Good', color: 'bg-yellow-100 text-yellow-800', description: 'Used but well maintained' },
    'fair': { label: 'Fair', color: 'bg-orange-100 text-orange-800', description: 'Shows wear but still functional' },
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffTime = Math.abs(now.getTime() - date.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffDays === 1) return '1 day ago';
    if (diffDays < 7) return `${diffDays} days ago`;
    return date.toLocaleDateString();
  };

  const handleClaim = () => {
    if (!selectedTimeSlot) {
      alert('Please select a pickup time slot');
      return;
    }
    
    handleClaimSubmit();
  };

  const handleClaimSubmit = async () => {
    try {
      const token = localStorage.getItem('token');
      if (!token) {
        alert('Please login to claim items');
        onNavigate('auth');
        return;
      }

      const response = await fetch(`http://localhost:3001/api/items/${item.id}/claim`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error || 'Failed to claim item');
      }

      const claimResult = await response.json();
      
      // Navigate to claim confirmation with claim data
      onNavigate('claim-confirmation', {
        item,
        claimCode: claimResult.claim_code,
        timeSlot: timeSlots.find(slot => slot.value === selectedTimeSlot)?.label,
      });
    } catch (error) {
      console.error('Error claiming item:', error);
      alert(error instanceof Error ? error.message : 'Failed to claim item. Please try again.');
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Header */}
        <div className="mb-8">
          <button
            onClick={() => onNavigate('browse')}
            className="flex items-center text-gray-600 hover:text-gray-900 transition-colors mb-4"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back to Browse
          </button>
        </div>

        <div className="bg-white rounded-2xl shadow-lg overflow-hidden">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-0">
            {/* Image Section */}
            <div className="relative h-96 lg:h-auto">
              <img
                src={item.photo_url}
                alt={item.name}
                className="w-full h-full object-cover"
              />
              <div className="absolute top-4 right-4">
                <span className={`px-3 py-1 rounded-full text-sm font-medium ${conditions[item.condition as keyof typeof conditions].color}`}>
                  {conditions[item.condition as keyof typeof conditions].label}
                </span>
              </div>
              {item.quantity > 1 && (
                <div className="absolute top-4 left-4">
                  <span className="bg-blue-600 text-white px-3 py-1 rounded-full text-sm font-medium">
                    {item.quantity} available
                  </span>
                </div>
              )}
            </div>

            {/* Details Section */}
            <div className="p-8">
              <div className="mb-6">
                <h1 className="text-3xl font-bold text-gray-900 mb-2">
                  {item.name}
                </h1>
                <p className="text-blue-600 font-medium text-lg">
                  {item.category}
                </p>
              </div>

              <div className="mb-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-2">Description</h3>
                <p className="text-gray-600 leading-relaxed">
                  {item.description}
                </p>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-6">
                <div className="flex items-center p-3 bg-gray-50 rounded-lg">
                  <Package className="w-5 h-5 text-gray-500 mr-3" />
                  <div>
                    <p className="text-sm font-medium text-gray-900">Condition</p>
                    <p className="text-sm text-gray-600">
                      {conditions[item.condition as keyof typeof conditions].description}
                    </p>
                  </div>
                </div>

                <div className="flex items-center p-3 bg-gray-50 rounded-lg">
                  <MapPin className="w-5 h-5 text-gray-500 mr-3" />
                  <div>
                    <p className="text-sm font-medium text-gray-900">Pickup Location</p>
                    <p className="text-sm text-gray-600">{item.location}</p>
                  </div>
                </div>

                <div className="flex items-center p-3 bg-gray-50 rounded-lg">
                  <User className="w-5 h-5 text-gray-500 mr-3" />
                  <div>
                    <p className="text-sm font-medium text-gray-900">Donated by</p>
                    <p className="text-sm text-gray-600">{item.donor_name}</p>
                  </div>
                </div>

                <div className="flex items-center p-3 bg-gray-50 rounded-lg">
                  <Clock className="w-5 h-5 text-gray-500 mr-3" />
                  <div>
                    <p className="text-sm font-medium text-gray-900">Posted</p>
                    <p className="text-sm text-gray-600">{formatDate(item.created_at)}</p>
                  </div>
                </div>
              </div>

              {item.expiry_date && (
                <div className="mb-6 p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
                  <div className="flex items-center">
                    <AlertTriangle className="w-5 h-5 text-yellow-600 mr-2" />
                    <div>
                      <p className="text-sm font-medium text-yellow-800">Expiry Date</p>
                      <p className="text-sm text-yellow-700">
                        This item expires on {new Date(item.expiry_date).toLocaleDateString()}
                      </p>
                    </div>
                  </div>
                </div>
              )}

              <div className="mb-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-3">
                  Select Pickup Time
                </h3>
                <div className="space-y-2">
                  {timeSlots.map((slot) => (
                    <label
                      key={slot.value}
                      className={`flex items-center p-3 border rounded-lg cursor-pointer transition-colors ${
                        selectedTimeSlot === slot.value
                          ? 'border-blue-500 bg-blue-50'
                          : 'border-gray-200 hover:border-gray-300'
                      }`}
                    >
                      <input
                        type="radio"
                        name="timeSlot"
                        value={slot.value}
                        checked={selectedTimeSlot === slot.value}
                        onChange={(e) => setSelectedTimeSlot(e.target.value)}
                        className="text-blue-600 focus:ring-blue-500"
                      />
                      <span className="ml-3 text-gray-900">{slot.label}</span>
                    </label>
                  ))}
                </div>
              </div>

              <div className="space-y-3">
                <button
                  onClick={handleClaim}
                  className="w-full bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white py-3 px-6 rounded-lg font-semibold transition-all duration-200 transform hover:scale-105"
                >
                  Claim This Item
                </button>
                
                <button
                  onClick={() => onNavigate('browse')}
                  className="w-full border border-gray-300 text-gray-700 hover:bg-gray-50 py-3 px-6 rounded-lg font-medium transition-colors"
                >
                  Continue Browsing
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Map placeholder */}
        <div className="mt-8 bg-white rounded-2xl shadow-lg p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Pickup Location</h3>
          <div className="bg-gray-100 rounded-lg h-64 flex items-center justify-center">
            <div className="text-center">
              <MapPin className="w-12 h-12 text-gray-400 mx-auto mb-2" />
              <p className="text-gray-600">Interactive map would be shown here</p>
              <p className="text-sm text-gray-500 mt-1">{item.location}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ItemDetailsPage;