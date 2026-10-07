"use client";

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Upload, Camera, Type, Loader2, Leaf } from 'lucide-react';
import { ScanResponse } from '@/types';
import { toast } from 'sonner';

export default function HomePage() {
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [dishName, setDishName] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const router = useRouter();

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      setImageFile(file);
      setDishName(''); // Clear dish name when file is selected
    }
  };

  const handleDishNameChange = (value: string) => {
    setDishName(value);
    if (value && imageFile) {
      setImageFile(null); // Clear file when dish name is entered
    }
  };

  const handleAnalyze = async () => {
    if (!imageFile && !dishName.trim()) {
      toast.error('Please upload an image or enter a dish name');
      return;
    }

    setIsLoading(true);

    try {
      const formData = new FormData();
      if (imageFile) {
        formData.append('imageFile', imageFile);
      }
      if (dishName.trim()) {
        formData.append('dishName', dishName.trim());
      }

      // For now, we'll skip user authentication
      // In a real app, you'd get this from auth context
      // formData.append('userId', currentUser?.id || '');

      const response = await fetch('/api/scan', {
        method: 'POST',
        body: formData,
      });

      const data: ScanResponse = await response.json();

      if (!response.ok) {
        throw new Error(data.error || 'Failed to analyze');
      }

      if (data.needs_admin) {
        toast.error(`Unknown ingredients found: ${data.missing_ingredients?.join(', ')}`);
        return;
      }

      if (data.receipt) {
        // Store receipt in sessionStorage and navigate to result page
        sessionStorage.setItem('climate-receipt', JSON.stringify(data.receipt));
        router.push('/result');
      }
    } catch (error) {
      console.error('Error analyzing:', error);
      toast.error('Failed to analyze. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-blue-50 to-indigo-50">
      <div className="max-w-4xl mx-auto px-4 py-12">
        <div className="text-center mb-12">
          <h1 className="text-4xl md:text-6xl font-bold mb-6">
            <span className="bg-gradient-to-r from-green-600 via-blue-600 to-indigo-600 bg-clip-text text-transparent">
              Plate to Planet
            </span>
            <span className="ml-2">🌍</span>
          </h1>
          <p className="text-xl text-gray-600 mb-8 max-w-2xl mx-auto">
            Discover the environmental impact of your meals with AI-powered climate receipts. 
            Upload a photo or describe your dish to get started.
          </p>
        </div>

        <Card className="w-full max-w-2xl mx-auto shadow-xl border-0 bg-white/90 backdrop-blur">
          <CardHeader>
            <CardTitle className="text-2xl text-center flex items-center justify-center gap-2">
              <Leaf className="w-6 h-6 text-green-600" />
              Analyze Your Meal
            </CardTitle>
          </CardHeader>

          <CardContent className="space-y-6">
            {/* File Upload Section */}
            <div className="space-y-4">
              <div className="text-center">
                <label
                  htmlFor="file-upload"
                  className="cursor-pointer block w-full border-2 border-dashed border-gray-300 rounded-lg p-8 hover:border-green-400 transition-colors bg-gray-50/50 hover:bg-green-50/50"
                >
                  <div className="flex flex-col items-center space-y-4">
                    {imageFile ? (
                      <>
                        <Camera className="w-12 h-12 text-green-600" />
                        <div>
                          <p className="text-lg font-medium text-green-600">
                            {imageFile.name}
                          </p>
                          <p className="text-sm text-gray-500">
                            Click to change image
                          </p>
                        </div>
                      </>
                    ) : (
                      <>
                        <Upload className="w-12 h-12 text-gray-400" />
                        <div>
                          <p className="text-lg font-medium text-gray-600">
                            Upload food photo
                          </p>
                          <p className="text-sm text-gray-500">
                            PNG, JPG up to 10MB
                          </p>
                        </div>
                      </>
                    )}
                  </div>
                </label>
                <input
                  id="file-upload"
                  type="file"
                  accept="image/*"
                  onChange={handleFileChange}
                  className="hidden"
                />
              </div>
            </div>

            {/* OR Divider */}
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-gray-300" />
              </div>
              <div className="relative flex justify-center text-sm">
                <span className="px-2 bg-white text-gray-500">OR</span>
              </div>
            </div>

            {/* Text Input Section */}
            <div className="space-y-4">
              <div className="flex items-center space-x-2 text-gray-600">
                <Type className="w-5 h-5" />
                <span className="font-medium">Describe your dish</span>
              </div>
              <Input
                type="text"
                placeholder="e.g., grilled chicken with vegetables, pasta bolognese..."
                value={dishName}
                onChange={(e) => handleDishNameChange(e.target.value)}
                className="text-lg py-3 px-4"
                disabled={!!imageFile}
              />
            </div>

            {/* Analyze Button */}
            <Button
              onClick={handleAnalyze}
              disabled={isLoading || (!imageFile && !dishName.trim())}
              size="lg"
              className="w-full py-6 text-lg font-semibold bg-gradient-to-r from-green-600 to-blue-600 hover:from-green-700 hover:to-blue-700 shadow-lg"
            >
              {isLoading ? (
                <>
                  <Loader2 className="w-5 h-5 mr-2 animate-spin" />
                  Analyzing with AI...
                </>
              ) : (
                <>
                  <Leaf className="w-5 h-5 mr-2" />
                  Analyze Climate Impact
                </>
              )}
            </Button>

            {/* Info Text */}
            <div className="text-center text-sm text-gray-500 pt-4">
              <p>
                Our AI will analyze your meal's ingredients and calculate the environmental impact
                including CO₂ emissions and water usage.
              </p>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}