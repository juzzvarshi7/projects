import React, { useState, useEffect } from 'react';
import { Check, QrCode, MapPin, Clock, Copy, ArrowLeft, Calendar } from 'lucide-react';

interface ClaimConfirmationPageProps {
  onNavigate: (page: string, data?: any) => void;
  claimData: any;
}

const ClaimConfirmationPage: React.FC<ClaimConfirmationPageProps> = ({ onNavigate, claimData }) => {
  const [qrCodeSvg, setQrCodeSvg] = useState<string>('');
  const [copySuccess, setCopySuccess] = useState(false);

  useEffect(() => {
    generateQRCode();
  }, [claimData]);

  const generateQRCode = async () => {
    try {
      const QRCode = await import('qrcode');
      const qrData = {
        claimCode: claimData?.claimCode,
        itemId: claimData?.item?.id,
        itemName: claimData?.item?.name,
        timeSlot: claimData?.timeSlot,
        location: claimData?.item?.location,
      };
      
      const qrString = await QRCode.toString(JSON.stringify(qrData), {
        type: 'svg',
        width: 200,
        margin: 2,
        color: {
          dark: '#1e40af',
          light: '#ffffff'
        }
      });
      
      setQrCodeSvg(qrString);
    } catch (error) {
      console.error('Error generating QR code:', error);
    }
  };

  const copyClaimCode = () => {
    navigator.clipboard.writeText(claimData?.claimCode || '');
    setCopySuccess(true);
    setTimeout(() => setCopySuccess(false), 2000);
  };

  if (!claimData) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Claim not found</h2>
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

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Success Animation */}
        <div className="text-center mb-8">
          <div className="w-24 h-24 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6 animate-pulse">
            <Check className="w-12 h-12 text-green-600 animate-bounce" />
          </div>
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            Item Claimed Successfully!
          </h1>
          <p className="text-xl text-gray-600">
            Your claim has been submitted. Here are your pickup details:
          </p>
        </div>

        {/* Main Claim Card */}
        <div className="bg-white rounded-2xl shadow-xl overflow-hidden mb-6">
          {/* Header */}
          <div className="bg-gradient-to-r from-blue-600 to-purple-600 p-6 text-white">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-2xl font-bold mb-2">Claim Details</h2>
                <div className="flex items-center">
                  <span className="text-blue-100">Claim Code:</span>
                  <span className="ml-2 text-xl font-mono font-bold">
                    {claimData.claimCode}
                  </span>
                  <button
                    onClick={copyClaimCode}
                    className="ml-2 p-1 hover:bg-white/20 rounded transition-colors"
                    title="Copy claim code"
                  >
                    <Copy className="w-4 h-4" />
                  </button>
                </div>
                {copySuccess && (
                  <span className="text-green-200 text-sm">Copied!</span>
                )}
              </div>
              <div className="bg-white/10 p-2 rounded-lg">
                <QrCode className="w-8 h-8" />
              </div>
            </div>
          </div>

          <div className="p-6">
            {/* Item Details */}
            <div className="flex items-start space-x-4 mb-6">
              <img
                src={claimData.item.photo_url}
                alt={claimData.item.name}
                className="w-20 h-20 object-cover rounded-lg"
              />
              <div>
                <h3 className="text-xl font-semibold text-gray-900 mb-1">
                  {claimData.item.name}
                </h3>
                <p className="text-blue-600 font-medium mb-2">
                  {claimData.item.category}
                </p>
                <p className="text-gray-600 text-sm">
                  Donated by {claimData.item.donor_name}
                </p>
              </div>
            </div>

            {/* Pickup Information */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
              <div className="flex items-center p-4 bg-gray-50 rounded-lg">
                <MapPin className="w-6 h-6 text-blue-600 mr-3" />
                <div>
                  <p className="font-medium text-gray-900">Pickup Location</p>
                  <p className="text-gray-600">{claimData.item.location}</p>
                </div>
              </div>

              <div className="flex items-center p-4 bg-gray-50 rounded-lg">
                <Clock className="w-6 h-6 text-green-600 mr-3" />
                <div>
                  <p className="font-medium text-gray-900">Pickup Time</p>
                  <p className="text-gray-600">{claimData.timeSlot}</p>
                </div>
              </div>
            </div>

            {/* QR Code */}
            <div className="text-center mb-6">
              <h4 className="text-lg font-semibold text-gray-900 mb-4">
                Show this QR Code for Pickup
              </h4>
              <div className="inline-block p-4 bg-white border-2 border-gray-200 rounded-xl">
                {qrCodeSvg ? (
                  <div dangerouslySetInnerHTML={{ __html: qrCodeSvg }} />
                ) : (
                  <div className="w-48 h-48 bg-gray-100 rounded-lg flex items-center justify-center">
                    <QrCode className="w-12 h-12 text-gray-400" />
                  </div>
                )}
              </div>
            </div>

            {/* Important Instructions */}
            <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-6">
              <h4 className="font-semibold text-yellow-800 mb-2">Important Instructions:</h4>
              <ul className="text-yellow-700 text-sm space-y-1">
                <li>• Arrive at the specified pickup location and time</li>
                <li>• Show this QR code to the donor for verification</li>
                <li>• Bring your student ID for additional verification</li>
                <li>• Contact support if you can't find the donor</li>
                <li>• Please be respectful and thankful to the donor</li>
              </ul>
            </div>

            {/* Next Steps */}
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
              <h4 className="font-semibold text-blue-800 mb-2">What happens next?</h4>
              <ol className="text-blue-700 text-sm space-y-1">
                <li>1. The donor will be notified about your claim</li>
                <li>2. You'll receive a confirmation when they approve</li>
                <li>3. Meet at the specified time and location</li>
                <li>4. Show your QR code to complete the pickup</li>
              </ol>
            </div>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="space-y-3">
          <button
            onClick={() => onNavigate('my-claims')}
            className="w-full bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white py-3 px-6 rounded-lg font-semibold transition-all duration-200"
          >
            View All My Claims
          </button>
          
          <button
            onClick={() => onNavigate('browse')}
            className="w-full border border-gray-300 text-gray-700 hover:bg-gray-50 py-3 px-6 rounded-lg font-medium transition-colors"
          >
            Browse More Items
          </button>
          
          <button
            onClick={() => onNavigate('home')}
            className="w-full text-blue-600 hover:text-blue-800 py-2 px-6 rounded-lg font-medium transition-colors"
          >
            Back to Home
          </button>
        </div>
      </div>
    </div>
  );
};

export default ClaimConfirmationPage;