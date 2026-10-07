import React from 'react';
import { Star } from 'lucide-react';

interface DayRatingProps {
  rating: number;
  onChange: (rating: number) => void;
}

export default function DayRating({ rating, onChange }: DayRatingProps) {
  return (
    <div className="space-y-4">
      <label className="block text-sm font-medium text-gray-700">
        How would you rate your day overall?
      </label>
      <div className="flex justify-center space-x-2">
        {[1, 2, 3, 4, 5].map((value) => (
          <button
            key={value}
            onClick={() => onChange(value)}
            className="focus:outline-none"
          >
            <Star
              className={`w-8 h-8 ${
                value <= rating
                  ? 'fill-yellow-400 text-yellow-400'
                  : 'fill-gray-200 text-gray-200'
              }`}
            />
          </button>
        ))}
      </div>
      <div className="text-center text-sm text-gray-500">
        {rating === 1 && 'Challenging day'}
        {rating === 2 && 'Below average'}
        {rating === 3 && 'Average day'}
        {rating === 4 && 'Good day'}
        {rating === 5 && 'Excellent day'}
      </div>
    </div>
  );
}
