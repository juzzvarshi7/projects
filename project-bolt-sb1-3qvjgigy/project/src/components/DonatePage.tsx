import React, { useState } from 'react';
import { Upload, Camera, Plus, Check, ArrowLeft } from 'lucide-react';

interface DonatePageProps {
  onNavigate: (page: string) => void;
}

const DonatePage: React.FC<DonatePageProps> = ({ onNavigate }) => {
  const [activeTab, setActiveTab] = useState<'item' | 'money' | 'voucher'>('item');
  const [formData, setFormData] = useState({
    // Item form
    category: '',
    customCategory: '',
    name: '',
    description: '',
    quantity: 1,
    condition: '',
    expiryDate: '',
    location: '',
    photos: [] as File[],
    // Money form
    amount: '',
    reason: '',
    // Voucher form
    voucherType: '',
    voucherValue: '',
    voucherDescription: '',
  });
  
  const [dragActive, setDragActive] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);

  const categories = [
    'Books & Study Material',
    'Electronics',
    'Clothing & Accessories',
    'Food & Beverages',
    'Sports & Fitness',
    'Art & Craft Supplies',
    'Furniture & Home',
    'Health & Beauty',
    'Other'
  ];

  const conditions = [
    { value: 'new', label: 'Brand New', description: 'Never used, in original packaging' },
    { value: 'like-new', label: 'Like New', description: 'Barely used, excellent condition' },
    { value: 'good', label: 'Good', description: 'Used but well maintained' },
    { value: 'fair', label: 'Fair', description: 'Shows wear but still functional' },
  ];

  const locations = [
    'Main Library',
    'Student Center',
    'Engineering Building',
    'Arts Building',
    'Sports Complex',
    'Cafeteria Area',
    'Parking Lot A',
    'Parking Lot B',
  ];

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleFileUpload = (files: FileList | null) => {
    if (files) {
      const newFiles = Array.from(files);
      setFormData(prev => ({
        ...prev,
        photos: [...prev.photos, ...newFiles].slice(0, 5) // Max 5 photos
      }));
    }
  };

  const handleDrag = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (e.type === "dragenter" || e.type === "dragover") {
      setDragActive(true);
    } else if (e.type === "dragleave") {
      setDragActive(false);
    }
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setDragActive(false);
    handleFileUpload(e.dataTransfer.files);
  };

  const removePhoto = (index: number) => {
    setFormData(prev => ({
      ...prev,
      photos: prev.photos.filter((_, i) => i !== index)
    }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (activeTab === 'item') {
      handleItemSubmit();
    } else if (activeTab === 'money') {
      handleMoneySubmit();
    } else if (activeTab === 'voucher') {
      handleVoucherSubmit();
    }
  };

  const handleItemSubmit = async () => {
    try {
      const token = localStorage.getItem('token');
      if (!token) {
        alert('Please login to donate items');
        return;
      }

      const formDataToSend = new FormData();
      formDataToSend.append('name', formData.name);
      formDataToSend.append('description', formData.description);
      formDataToSend.append('category', formData.category === 'Other' ? formData.customCategory : formData.category);
      formDataToSend.append('condition', formData.condition);
      formDataToSend.append('quantity', formData.quantity.toString());
      formDataToSend.append('location', formData.location);
      if (formData.expiryDate) {
        formDataToSend.append('expiry_date', formData.expiryDate);
      }
      if (formData.photos.length > 0) {
        formDataToSend.append('photo', formData.photos[0]);
      }

      const response = await fetch('http://localhost:3001/api/items', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
        },
        body: formDataToSend,
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error || 'Failed to create donation');
      }

      const result = await response.json();
      console.log('Item donated successfully:', result);
      
      setShowSuccess(true);
      setTimeout(() => {
        onNavigate('home');
      }, 2000);
    } catch (error) {
      console.error('Error donating item:', error);
      alert('Failed to donate item. Please try again.');
    }
  };

  const handleMoneySubmit = () => {
    // Simulate UPI payment
    alert('Redirecting to UPI payment...\n\nIn a real app, this would integrate with payment gateways like Razorpay or UPI apps.');
    setShowSuccess(true);
    setTimeout(() => {
      onNavigate('home');
    }, 2000);
  };

  const handleVoucherSubmit = () => {
    // For now, just show success
    setShowSuccess(true);
    setTimeout(() => {
      onNavigate('home');
    }, 2000);
  };

  const renderItemForm = () => (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Category *
          </label>
          <select
            name="category"
            value={formData.category}
            onChange={handleInputChange}
            required
            className="w-full px-3 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
          >
            <option value="">Select a category</option>
            {categories.map((cat) => (
              <option key={cat} value={cat}>{cat}</option>
            ))}
          </select>
        </div>

        {formData.category === 'Other' && (
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Custom Category *
            </label>
            <input
              type="text"
              name="customCategory"
              value={formData.customCategory}
              onChange={handleInputChange}
              required
              className="w-full px-3 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
              placeholder="Enter custom category"
            />
          </div>
        )}

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Item Name *
          </label>
          <input
            type="text"
            name="name"
            value={formData.name}
            onChange={handleInputChange}
            required
            className="w-full px-3 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
            placeholder="What are you donating?"
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Description *
        </label>
        <textarea
          name="description"
          value={formData.description}
          onChange={handleInputChange}
          required
          rows={4}
          className="w-full px-3 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
          placeholder="Describe the item, its condition, and any special notes..."
        />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Quantity *
          </label>
          <input
            type="number"
            name="quantity"
            value={formData.quantity}
            onChange={handleInputChange}
            min="1"
            required
            className="w-full px-3 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Condition *
          </label>
          <select
            name="condition"
            value={formData.condition}
            onChange={handleInputChange}
            required
            className="w-full px-3 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
          >
            <option value="">Select condition</option>
            {conditions.map((cond) => (
              <option key={cond.value} value={cond.value}>{cond.label}</option>
            ))}
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Expiry Date
          </label>
          <input
            type="date"
            name="expiryDate"
            value={formData.expiryDate}
            onChange={handleInputChange}
            className="w-full px-3 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Pickup Location *
        </label>
        <select
          name="location"
          value={formData.location}
          onChange={handleInputChange}
          required
          className="w-full px-3 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
        >
          <option value="">Select pickup location</option>
          {locations.map((loc) => (
            <option key={loc} value={loc}>{loc}</option>
          ))}
        </select>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Photos (Max 5)
        </label>
        <div
          className={`border-2 border-dashed rounded-lg p-6 text-center transition-colors ${
            dragActive 
              ? 'border-blue-500 bg-blue-50' 
              : 'border-gray-300 hover:border-blue-400'
          }`}
          onDragEnter={handleDrag}
          onDragLeave={handleDrag}
          onDragOver={handleDrag}
          onDrop={handleDrop}
        >
          <Camera className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-600 mb-4">
            Drag and drop photos here, or click to select
          </p>
          <input
            type="file"
            multiple
            accept="image/*"
            onChange={(e) => handleFileUpload(e.target.files)}
            className="hidden"
            id="photo-upload"
          />
          <label
            htmlFor="photo-upload"
            className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg cursor-pointer transition-colors inline-flex items-center"
          >
            <Upload className="w-4 h-4 mr-2" />
            Choose Files
          </label>
        </div>

        {formData.photos.length > 0 && (
          <div className="mt-4 grid grid-cols-2 md:grid-cols-5 gap-4">
            {formData.photos.map((photo, index) => (
              <div key={index} className="relative">
                <img
                  src={URL.createObjectURL(photo)}
                  alt={`Preview ${index + 1}`}
                  className="w-full h-24 object-cover rounded-lg"
                />
                <button
                  type="button"
                  onClick={() => removePhoto(index)}
                  className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full w-6 h-6 flex items-center justify-center text-xs hover:bg-red-600 transition-colors"
                >
                  ×
                </button>
              </div>
            ))}
          </div>
        )}
      </div>

      <button
        type="submit"
        className="w-full bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white py-3 px-6 rounded-lg font-medium transition-all duration-200 transform hover:scale-105"
      >
        Donate Item
      </button>
    </form>
  );

  const renderMoneyForm = () => (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Amount (₹) *
        </label>
        <input
          type="number"
          name="amount"
          value={formData.amount}
          onChange={handleInputChange}
          min="1"
          required
          className="w-full px-3 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
          placeholder="Enter amount to donate"
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Purpose/Reason *
        </label>
        <textarea
          name="reason"
          value={formData.reason}
          onChange={handleInputChange}
          required
          rows={4}
          className="w-full px-3 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
          placeholder="Why are you donating? What should this money be used for?"
        />
      </div>

      <button
        type="submit"
        className="w-full bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-700 hover:to-emerald-700 text-white py-3 px-6 rounded-lg font-medium transition-all duration-200 transform hover:scale-105"
      >
        Donate Money via UPI
      </button>
    </form>
  );

  const renderVoucherForm = () => (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Voucher Type *
        </label>
        <input
          type="text"
          name="voucherType"
          value={formData.voucherType}
          onChange={handleInputChange}
          required
          className="w-full px-3 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
          placeholder="e.g. Amazon Gift Card, Food Voucher, etc."
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Value (₹) *
        </label>
        <input
          type="number"
          name="voucherValue"
          value={formData.voucherValue}
          onChange={handleInputChange}
          min="1"
          required
          className="w-full px-3 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
          placeholder="Enter voucher value"
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Description & Terms *
        </label>
        <textarea
          name="voucherDescription"
          value={formData.voucherDescription}
          onChange={handleInputChange}
          required
          rows={4}
          className="w-full px-3 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
          placeholder="Describe the voucher, any terms, expiry date, how to use it..."
        />
      </div>

      <button
        type="submit"
        className="w-full bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-700 hover:to-indigo-700 text-white py-3 px-6 rounded-lg font-medium transition-all duration-200 transform hover:scale-105"
      >
        Donate Voucher
      </button>
    </form>
  );

  if (showSuccess) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <Check className="w-10 h-10 text-green-600 animate-bounce" />
          </div>
          <h2 className="text-3xl font-bold text-gray-900 mb-4">
            Thank you for your donation!
          </h2>
          <p className="text-gray-600">
            Your contribution will help fellow students in need.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-8">
          <button
            onClick={() => onNavigate('home')}
            className="flex items-center text-gray-600 hover:text-gray-900 transition-colors mb-4"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back to Home
          </button>
          
          <h1 className="text-4xl font-bold text-gray-900 mb-2">
            Make a Donation
          </h1>
          <p className="text-gray-600 text-lg">
            Share what you have to help others in your community
          </p>
        </div>

        <div className="bg-white rounded-2xl shadow-lg overflow-hidden">
          {/* Tabs */}
          <div className="border-b border-gray-200">
            <nav className="flex">
              {[
                { key: 'item', label: 'Items', color: 'text-blue-600' },
                { key: 'money', label: 'Money', color: 'text-green-600' },
                { key: 'voucher', label: 'Vouchers', color: 'text-purple-600' },
              ].map((tab) => (
                <button
                  key={tab.key}
                  onClick={() => setActiveTab(tab.key as any)}
                  className={`flex-1 py-4 px-6 text-sm font-medium border-b-2 transition-colors ${
                    activeTab === tab.key
                      ? `${tab.color} border-current`
                      : 'text-gray-500 border-transparent hover:text-gray-700'
                  }`}
                >
                  {tab.label}
                </button>
              ))}
            </nav>
          </div>

          {/* Form Content */}
          <div className="p-8">
            {activeTab === 'item' && renderItemForm()}
            {activeTab === 'money' && renderMoneyForm()}
            {activeTab === 'voucher' && renderVoucherForm()}
          </div>
        </div>
      </div>
    </div>
  );
};

export default DonatePage;