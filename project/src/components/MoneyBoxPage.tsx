import React, { useState, useEffect } from 'react';
import { ArrowLeft, DollarSign, TrendingUp, TrendingDown, History, Plus, Minus } from 'lucide-react';

interface MoneyBoxPageProps {
  onNavigate: (page: string, data?: any) => void;
}

const MoneyBoxPage: React.FC<MoneyBoxPageProps> = ({ onNavigate }) => {
  const [activeTab, setActiveTab] = useState<'donate' | 'withdraw' | 'transparency'>('donate');
  const [moneyBoxData, setMoneyBoxData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [formData, setFormData] = useState({
    amount: '',
    reason: '',
  });

  useEffect(() => {
    fetchMoneyBoxData();
  }, []);

  const fetchMoneyBoxData = async () => {
    try {
      // Mock data for demonstration
      const mockData = {
        balance: 45230.50,
        total_donations: 67,
        total_withdrawals: 23,
        transactions: [
          {
            id: '1',
            amount: 500,
            type: 'donation',
            user_name: 'Sarah Johnson',
            reason: 'For students facing financial difficulties',
            created_at: '2024-01-15T10:30:00Z',
          },
          {
            id: '2',
            amount: 200,
            type: 'withdrawal',
            user_name: 'Mike Chen',
            reason: 'Emergency textbook fund for first-year students',
            created_at: '2024-01-14T15:45:00Z',
          },
          {
            id: '3',
            amount: 1000,
            type: 'donation',
            user_name: 'Emma Davis',
            reason: 'Monthly contribution to help fellow students',
            created_at: '2024-01-13T09:20:00Z',
          },
          {
            id: '4',
            amount: 750,
            type: 'withdrawal',
            user_name: 'John Smith',
            reason: 'Laptop repair for online classes',
            created_at: '2024-01-12T14:10:00Z',
          },
          {
            id: '5',
            amount: 300,
            type: 'donation',
            user_name: 'Anonymous',
            reason: 'Want to help students in need',
            created_at: '2024-01-11T11:25:00Z',
          },
        ]
      };
      
      setMoneyBoxData(mockData);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching money box data:', error);
      setLoading(false);
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleDonation = async (e: React.FormEvent) => {
    e.preventDefault();
    // Simulate UPI payment integration
    alert('Redirecting to UPI payment...\n\nIn a real app, this would integrate with payment gateways like Razorpay, Paytm, or UPI apps.');
    
    // Reset form
    setFormData({ amount: '', reason: '' });
  };

  const handleWithdrawal = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (parseFloat(formData.amount) > moneyBoxData.balance) {
      alert('Insufficient funds in the money box.');
      return;
    }
    
    // Simulate withdrawal request
    alert('Withdrawal request submitted!\n\nYour request will be reviewed and processed within 2-3 business days.');
    
    // Reset form
    setFormData({ amount: '', reason: '' });
  };

  const formatCurrency = (amount: number) => {
    return `₹${amount.toLocaleString('en-IN', { minimumFractionDigits: 2 })}`;
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-IN', {
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
          <div className="w-16 h-16 border-4 border-green-600 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-gray-600">Loading Money Box...</p>
        </div>
      </div>
    );
  }

  const renderDonateTab = () => (
    <form onSubmit={handleDonation} className="space-y-6">
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Donation Amount (₹) *
        </label>
        <input
          type="number"
          name="amount"
          value={formData.amount}
          onChange={handleInputChange}
          min="1"
          step="0.01"
          required
          className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent transition-colors text-lg"
          placeholder="Enter amount to donate"
        />
        <div className="mt-2 flex flex-wrap gap-2">
          {[100, 200, 500, 1000, 2000].map((amount) => (
            <button
              key={amount}
              type="button"
              onClick={() => setFormData(prev => ({ ...prev, amount: amount.toString() }))}
              className="px-3 py-1 text-sm bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full transition-colors"
            >
              ₹{amount}
            </button>
          ))}
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Purpose/Message *
        </label>
        <textarea
          name="reason"
          value={formData.reason}
          onChange={handleInputChange}
          required
          rows={4}
          className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent transition-colors"
          placeholder="Why are you donating? Share your message of support..."
        />
      </div>

      <div className="bg-green-50 border border-green-200 rounded-lg p-4">
        <h4 className="font-semibold text-green-800 mb-2">How it works:</h4>
        <ul className="text-green-700 text-sm space-y-1">
          <li>• Donations go directly to helping students in need</li>
          <li>• Funds are used for textbooks, food, emergency expenses</li>
          <li>• All transactions are transparent and tracked</li>
          <li>• You'll receive a confirmation receipt</li>
        </ul>
      </div>

      <button
        type="submit"
        className="w-full bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-700 hover:to-emerald-700 text-white py-3 px-6 rounded-lg font-semibold transition-all duration-200 transform hover:scale-105 flex items-center justify-center"
      >
        <DollarSign className="w-5 h-5 mr-2" />
        Donate via UPI
      </button>
    </form>
  );

  const renderWithdrawTab = () => (
    <form onSubmit={handleWithdrawal} className="space-y-6">
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
        <h4 className="font-semibold text-blue-800 mb-2">Available Balance:</h4>
        <p className="text-2xl font-bold text-blue-900">
          {formatCurrency(moneyBoxData.balance)}
        </p>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Withdrawal Amount (₹) *
        </label>
        <input
          type="number"
          name="amount"
          value={formData.amount}
          onChange={handleInputChange}
          min="1"
          max={moneyBoxData.balance}
          step="0.01"
          required
          className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors text-lg"
          placeholder="Enter withdrawal amount"
        />
        <p className="text-sm text-gray-600 mt-1">
          Maximum: {formatCurrency(moneyBoxData.balance)}
        </p>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Reason for Withdrawal *
        </label>
        <textarea
          name="reason"
          value={formData.reason}
          onChange={handleInputChange}
          required
          rows={4}
          className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
          placeholder="Please provide a detailed reason for your withdrawal request. This helps ensure funds go to those who need them most..."
        />
      </div>

      <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
        <h4 className="font-semibold text-yellow-800 mb-2">Withdrawal Guidelines:</h4>
        <ul className="text-yellow-700 text-sm space-y-1">
          <li>• Withdrawals are reviewed by the student committee</li>
          <li>• Processing takes 2-3 business days</li>
          <li>• Valid student ID required for verification</li>
          <li>• Emergency requests are prioritized</li>
          <li>• Provide detailed reason and supporting documents if possible</li>
        </ul>
      </div>

      <button
        type="submit"
        className="w-full bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white py-3 px-6 rounded-lg font-semibold transition-all duration-200 flex items-center justify-center"
      >
        <Minus className="w-5 h-5 mr-2" />
        Submit Withdrawal Request
      </button>
    </form>
  );

  const renderTransparencyTab = () => (
    <div className="space-y-6">
      {/* Summary Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-gradient-to-r from-green-500 to-emerald-500 text-white p-6 rounded-xl">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-green-100">Total Balance</p>
              <p className="text-3xl font-bold">{formatCurrency(moneyBoxData.balance)}</p>
            </div>
            <DollarSign className="w-12 h-12 text-green-200" />
          </div>
        </div>

        <div className="bg-gradient-to-r from-blue-500 to-cyan-500 text-white p-6 rounded-xl">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-blue-100">Total Donations</p>
              <p className="text-3xl font-bold">{moneyBoxData.total_donations}</p>
            </div>
            <TrendingUp className="w-12 h-12 text-blue-200" />
          </div>
        </div>

        <div className="bg-gradient-to-r from-purple-500 to-indigo-500 text-white p-6 rounded-xl">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-purple-100">Total Withdrawals</p>
              <p className="text-3xl font-bold">{moneyBoxData.total_withdrawals}</p>
            </div>
            <TrendingDown className="w-12 h-12 text-purple-200" />
          </div>
        </div>
      </div>

      {/* Recent Transactions */}
      <div className="bg-white rounded-xl border border-gray-200">
        <div className="p-6 border-b border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900 flex items-center">
            <History className="w-5 h-5 mr-2" />
            Recent Transactions
          </h3>
        </div>
        
        <div className="divide-y divide-gray-200">
          {moneyBoxData.transactions.map((transaction: any) => (
            <div key={transaction.id} className="p-6 hover:bg-gray-50 transition-colors">
              <div className="flex items-start justify-between">
                <div className="flex items-start space-x-4">
                  <div className={`p-2 rounded-full ${
                    transaction.type === 'donation' 
                      ? 'bg-green-100 text-green-600' 
                      : 'bg-blue-100 text-blue-600'
                  }`}>
                    {transaction.type === 'donation' ? (
                      <Plus className="w-4 h-4" />
                    ) : (
                      <Minus className="w-4 h-4" />
                    )}
                  </div>
                  <div>
                    <div className="flex items-center space-x-2 mb-1">
                      <span className={`text-lg font-semibold ${
                        transaction.type === 'donation' ? 'text-green-600' : 'text-blue-600'
                      }`}>
                        {transaction.type === 'donation' ? '+' : '-'}{formatCurrency(transaction.amount)}
                      </span>
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                        transaction.type === 'donation'
                          ? 'bg-green-100 text-green-800'
                          : 'bg-blue-100 text-blue-800'
                      }`}>
                        {transaction.type}
                      </span>
                    </div>
                    <p className="text-sm text-gray-600 mb-1">
                      by {transaction.user_name}
                    </p>
                    <p className="text-sm text-gray-800 mb-2">
                      {transaction.reason}
                    </p>
                    <p className="text-xs text-gray-500">
                      {formatDate(transaction.created_at)}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
        
        <div className="p-6 border-t border-gray-200 text-center">
          <button className="text-blue-600 hover:text-blue-800 font-medium">
            View All Transactions
          </button>
        </div>
      </div>
    </div>
  );

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
            Money Box
          </h1>
          <p className="text-gray-600 text-lg">
            Financial assistance for students in need
          </p>
        </div>

        {/* Tabs */}
        <div className="bg-white rounded-2xl shadow-lg overflow-hidden">
          <div className="border-b border-gray-200">
            <nav className="flex">
              {[
                { key: 'donate', label: 'Donate', icon: Plus, color: 'text-green-600' },
                { key: 'withdraw', label: 'Withdraw', icon: Minus, color: 'text-blue-600' },
                { key: 'transparency', label: 'Transparency', icon: History, color: 'text-purple-600' },
              ].map((tab) => {
                const Icon = tab.icon;
                return (
                  <button
                    key={tab.key}
                    onClick={() => setActiveTab(tab.key as any)}
                    className={`flex-1 py-4 px-6 text-sm font-medium border-b-2 transition-colors flex items-center justify-center ${
                      activeTab === tab.key
                        ? `${tab.color} border-current`
                        : 'text-gray-500 border-transparent hover:text-gray-700'
                    }`}
                  >
                    <Icon className="w-4 h-4 mr-2" />
                    {tab.label}
                  </button>
                );
              })}
            </nav>
          </div>

          <div className="p-8">
            {activeTab === 'donate' && renderDonateTab()}
            {activeTab === 'withdraw' && renderWithdrawTab()}
            {activeTab === 'transparency' && renderTransparencyTab()}
          </div>
        </div>
      </div>
    </div>
  );
};

export default MoneyBoxPage;