"use client";

import { ClimateReceipt } from '@/types';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Leaf, Droplets, Car, Lightbulb } from 'lucide-react';

interface ClimateReceiptCardProps {
  receipt: ClimateReceipt;
}

export function ClimateReceiptCard({ receipt }: ClimateReceiptCardProps) {
  return (
    <Card className="w-full max-w-2xl mx-auto shadow-lg border-0 bg-gradient-to-br from-green-50 to-blue-50">
      <CardHeader className="text-center space-y-4">
        <CardTitle className="text-2xl font-bold text-gray-800 flex items-center justify-center gap-2">
          <Leaf className="w-6 h-6 text-green-600" />
          Climate Receipt
        </CardTitle>
        <h2 className="text-xl text-gray-700 capitalize">{receipt.dish}</h2>
      </CardHeader>

      <CardContent className="space-y-6">
        {/* Ingredients */}
        <div>
          <h3 className="text-sm font-semibold text-gray-600 mb-2 uppercase tracking-wide">
            Ingredients Analyzed
          </h3>
          <div className="flex flex-wrap gap-2">
            {receipt.ingredients.map((ingredient, index) => (
              <Badge key={index} variant="secondary" className="capitalize">
                {ingredient}
              </Badge>
            ))}
          </div>
        </div>

        {/* Environmental Impact */}
        <div className="grid grid-cols-2 gap-4">
          <div className="bg-white rounded-lg p-4 shadow-sm border">
            <div className="flex items-center gap-2 mb-2">
              <Car className="w-5 h-5 text-red-500" />
              <span className="text-sm font-medium text-gray-600">Carbon Footprint</span>
            </div>
            <div className="text-2xl font-bold text-red-600">
              {receipt.co2_kg} <span className="text-sm font-normal">kg CO₂</span>
            </div>
          </div>

          <div className="bg-white rounded-lg p-4 shadow-sm border">
            <div className="flex items-center gap-2 mb-2">
              <Droplets className="w-5 h-5 text-blue-500" />
              <span className="text-sm font-medium text-gray-600">Water Usage</span>
            </div>
            <div className="text-2xl font-bold text-blue-600">
              {receipt.water_l} <span className="text-sm font-normal">L</span>
            </div>
          </div>
        </div>

        {/* Equivalent */}
        <div className="bg-yellow-50 rounded-lg p-4 border border-yellow-200">
          <div className="flex items-start gap-2">
            <Car className="w-5 h-5 text-yellow-600 mt-0.5 flex-shrink-0" />
            <div>
              <h3 className="font-semibold text-yellow-800 mb-1">Environmental Equivalent</h3>
              <p className="text-yellow-700">{receipt.equivalent}</p>
            </div>
          </div>
        </div>

        {/* Green Suggestion */}
        <div className="bg-green-50 rounded-lg p-4 border border-green-200">
          <div className="flex items-start gap-2">
            <Lightbulb className="w-5 h-5 text-green-600 mt-0.5 flex-shrink-0" />
            <div>
              <h3 className="font-semibold text-green-800 mb-1">Eco-Friendly Tip</h3>
              <p className="text-green-700">{receipt.suggestion}</p>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}