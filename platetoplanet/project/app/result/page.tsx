"use client";

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { ClimateReceiptCard } from '@/components/climate-receipt-card';
import { ArrowLeft, Home } from 'lucide-react';
import { ClimateReceipt } from '@/types';

export default function ResultPage() {
  const [receipt, setReceipt] = useState<ClimateReceipt | null>(null);
  const router = useRouter();

  useEffect(() => {
    const savedReceipt = sessionStorage.getItem('climate-receipt');
    if (savedReceipt) {
      setReceipt(JSON.parse(savedReceipt));
    } else {
      router.push('/');
    }
  }, [router]);

  const handleBack = () => {
    router.push('/');
  };

  if (!receipt) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-blue-50 to-indigo-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading your climate receipt...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-blue-50 to-indigo-50">
      <div className="max-w-4xl mx-auto px-4 py-8">
        <div className="mb-8">
          <Button
            onClick={handleBack}
            variant="ghost"
            size="lg"
            className="mb-6"
          >
            <ArrowLeft className="w-5 h-5 mr-2" />
            Back to Analysis
          </Button>

          <div className="text-center mb-8">
            <h1 className="text-3xl font-bold text-gray-800 mb-2">
              Your Climate Receipt is Ready! 📊
            </h1>
            <p className="text-lg text-gray-600">
              Here's the environmental impact of your meal
            </p>
          </div>
        </div>

        <div className="space-y-8">
          <ClimateReceiptCard receipt={receipt} />

          <div className="text-center space-y-4">
            <Button
              onClick={handleBack}
              size="lg"
              className="bg-gradient-to-r from-green-600 to-blue-600 hover:from-green-700 hover:to-blue-700"
            >
              <Home className="w-5 h-5 mr-2" />
              Analyze Another Meal
            </Button>

            <div className="text-sm text-gray-500">
              <p>Share your climate receipt and inspire others to make eco-friendly food choices!</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}