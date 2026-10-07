import React, { useState, useEffect } from 'react';
import { Search, Filter, MapPin, Clock, User, ArrowLeft, Grid, List } from 'lucide-react';

interface BrowseItemsPageProps {
  onNavigate: (page: string, data?: any) => void;
}

const BrowseItemsPage: React.FC<BrowseItemsPageProps> = ({ onNavigate }) => {
  const [items, setItems] = useState<any[]>([]);
  const [filteredItems, setFilteredItems] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('');
  const [selectedCondition, setSelectedCondition] = useState('');
  const [viewMode, setViewMode] = useState<'grid' | 'list'>('grid');
  const [showFilters, setShowFilters] = useState(false);

  const categories = [
    'Books & Study Material',
    'Electronics',
    'Clothing & Accessories',
    'Food & Beverages',
    'Sports & Fitness',
    'Art & Craft Supplies',
    'Furniture & Home',
    'Health & Beauty',
  ];

  const conditions = [
    { value: 'new', label: 'Brand New', color: 'bg-green-100 text-green-800' },
    { value: 'like-new', label: 'Like New', color: 'bg-blue-100 text-blue-800' },
    { value: 'good', label: 'Good', color: 'bg-yellow-100 text-yellow-800' },
    { value: 'fair', label: 'Fair', color: 'bg-orange-100 text-orange-800' },
  ];

  useEffect(() => {
    fetchItems();
  }, []);

  useEffect(() => {
    filterItems();
  }, [items, searchTerm, selectedCategory, selectedCondition]);

  const fetchItems = async () => {
    try {
      const params = new URLSearchParams();
      if (selectedCategory) params.append('category', selectedCategory);
      if (selectedCondition) params.append('condition', selectedCondition);
      if (searchTerm) params.append('search', searchTerm);
      
      const response = await fetch(`http://localhost:3001/api/items?${params.toString()}`);
      
      if (!response.ok) {
        throw new Error('Failed to fetch items');
      }
      
      const fetchedItems = await response.json();
      
      // Add full URL for images
      const itemsWithFullUrls = fetchedItems.map((item: any) => ({
        ...item,
        photo_url: item.photo_url ? `http://localhost:3001${item.photo_url}` : 'https://images.pexels.com/photos/159866/books-book-pages-read-literature-159866.jpeg'
      }));
      
      setItems(itemsWithFullUrls);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching items:', error);
      // Fallback to empty array on error
      setItems([]);
      setLoading(false);
    }
  };

  const filterItems = () => {
    let filtered = items;

    if (searchTerm) {
      filtered = filtered.filter(item =>
        item.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        item.description.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    if (selectedCategory) {
      filtered = filtered.filter(item => item.category === selectedCategory);
    }

    if (selectedCondition) {
      filtered = filtered.filter(item => item.condition === selectedCondition);
    }

    setFilteredItems(filtered);
  };

  const getConditionStyle = (condition: string) => {
    const conditionObj = conditions.find(c => c.value === condition);
    return conditionObj ? conditionObj.color : 'bg-gray-100 text-gray-800';
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

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-blue-600 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-gray-600">Loading items...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Header */}
        <div className="mb-8">
          <button
            onClick={() => onNavigate('home')}
            className="flex items-center text-gray-600 hover:text-gray-900 transition-colors mb-4"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back to Home
          </button>
          
          <div className="flex flex-col md:flex-row md:items-center justify-between">
            <div>
              <h1 className="text-4xl font-bold text-gray-900 mb-2">
                Browse Items
              </h1>
              <p className="text-gray-600 text-lg">
                Find items donated by fellow students
              </p>
            </div>
            
            <div className="flex items-center space-x-2 mt-4 md:mt-0">
              <button
                onClick={() => setViewMode('grid')}
                className={`p-2 rounded-lg transition-colors ${
                  viewMode === 'grid'
                    ? 'bg-blue-600 text-white'
                    : 'bg-white text-gray-600 hover:bg-gray-100'
                }`}
              >
                <Grid className="w-5 h-5" />
              </button>
              <button
                onClick={() => setViewMode('list')}
                className={`p-2 rounded-lg transition-colors ${
                  viewMode === 'list'
                    ? 'bg-blue-600 text-white'
                    : 'bg-white text-gray-600 hover:bg-gray-100'
                }`}
              >
                <List className="w-5 h-5" />
              </button>
            </div>
          </div>
        </div>

        <div className="flex flex-col lg:flex-row gap-8">
          {/* Filters Sidebar */}
          <div className="lg:w-64 flex-shrink-0">
            <div className="bg-white rounded-2xl shadow-lg p-6 sticky top-8">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-lg font-semibold text-gray-900">Filters</h3>
                <button
                  onClick={() => setShowFilters(!showFilters)}
                  className="lg:hidden p-2 hover:bg-gray-100 rounded-lg"
                >
                  <Filter className="w-5 h-5" />
                </button>
              </div>
              
              <div className={`space-y-6 ${showFilters ? 'block' : 'hidden lg:block'}`}>
                {/* Search */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Search
                  </label>
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
                    <input
                      type="text"
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      placeholder="Search items..."
                      className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                  </div>
                </div>

                {/* Category Filter */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Category
                  </label>
                  <select
                    value={selectedCategory}
                    onChange={(e) => setSelectedCategory(e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  >
                    <option value="">All Categories</option>
                    {categories.map((category) => (
                      <option key={category} value={category}>
                        {category}
                      </option>
                    ))}
                  </select>
                </div>

                {/* Condition Filter */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Condition
                  </label>
                  <select
                    value={selectedCondition}
                    onChange={(e) => setSelectedCondition(e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  >
                    <option value="">All Conditions</option>
                    {conditions.map((condition) => (
                      <option key={condition.value} value={condition.value}>
                        {condition.label}
                      </option>
                    ))}
                  </select>
                </div>

                {/* Clear Filters */}
                <button
                  onClick={() => {
                    setSearchTerm('');
                    setSelectedCategory('');
                    setSelectedCondition('');
                  }}
                  className="w-full py-2 px-4 text-sm text-blue-600 hover:text-blue-800 hover:bg-blue-50 rounded-lg transition-colors"
                >
                  Clear All Filters
                </button>
              </div>
            </div>
          </div>

          {/* Items Grid/List */}
          <div className="flex-1">
            <div className="mb-4 text-sm text-gray-600">
              Showing {filteredItems.length} of {items.length} items
            </div>

            {filteredItems.length === 0 ? (
              <div className="bg-white rounded-2xl shadow-lg p-12 text-center">
                <Search className="w-16 h-16 text-gray-400 mx-auto mb-4" />
                <h3 className="text-xl font-semibold text-gray-900 mb-2">No items found</h3>
                <p className="text-gray-600">
                  Try adjusting your search criteria or browse all available items.
                </p>
                <button
                  onClick={() => {
                    setSearchTerm('');
                    setSelectedCategory('');
                    setSelectedCondition('');
                  }}
                  className="mt-4 bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg transition-colors"
                >
                  Clear Filters
                </button>
              </div>
            ) : (
              <div className={
                viewMode === 'grid'
                  ? 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6'
                  : 'space-y-4'
              }>
                {filteredItems.map((item) => (
                  <div
                    key={item.id}
                    className={`bg-white rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 cursor-pointer group overflow-hidden ${
                      viewMode === 'list' ? 'flex' : ''
                    }`}
                    onClick={() => onNavigate('item-details', item)}
                  >
                    <div className={viewMode === 'list' ? 'w-48 flex-shrink-0' : ''}>
                      <div className={`relative overflow-hidden ${viewMode === 'list' ? 'h-full' : 'h-48'}`}>
                        <img
                          src={item.photo_url}
                          alt={item.name}
                          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                        />
                        <div className="absolute top-2 right-2">
                          <span className={`px-2 py-1 rounded-full text-xs font-medium ${getConditionStyle(item.condition)}`}>
                            {conditions.find(c => c.value === item.condition)?.label}
                          </span>
                        </div>
                      </div>
                    </div>

                    <div className={`p-6 ${viewMode === 'list' ? 'flex-1' : ''}`}>
                      <div className="flex items-start justify-between mb-2">
                        <h3 className="text-lg font-semibold text-gray-900 group-hover:text-blue-600 transition-colors">
                          {item.name}
                        </h3>
                        {item.quantity > 1 && (
                          <span className="bg-blue-100 text-blue-800 text-xs px-2 py-1 rounded-full">
                            {item.quantity} available
                          </span>
                        )}
                      </div>

                      <p className="text-gray-600 text-sm mb-4 line-clamp-2">
                        {item.description}
                      </p>

                      <div className="space-y-2 text-xs text-gray-500">
                        <div className="flex items-center">
                          <MapPin className="w-4 h-4 mr-1" />
                          {item.location}
                        </div>
                        <div className="flex items-center">
                          <User className="w-4 h-4 mr-1" />
                          {item.donor_name}
                        </div>
                        <div className="flex items-center">
                          <Clock className="w-4 h-4 mr-1" />
                          {formatDate(item.created_at)}
                        </div>
                      </div>

                      <button className="w-full mt-4 bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white py-2 px-4 rounded-lg font-medium transition-all duration-200 transform group-hover:scale-105">
                        View Details
                      </button>
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

export default BrowseItemsPage;