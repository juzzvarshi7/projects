import React from 'react';
import { ActivityCategory } from '../types';

interface ActivityPickerProps {
  selectedCategories: ActivityCategory[];
  highlights: string;
  onCategoriesChange: (categories: ActivityCategory[]) => void;
  onHighlightsChange: (highlights: string) => void;
}

const categories: { value: ActivityCategory; label: string; description: string }[] = [
  { value: 'work', label: 'Work/School', description: 'Professional or academic activities' },
  { value: 'exercise', label: 'Physical Exercise', description: 'Workouts, sports, walking' },
  { value: 'leisure', label: 'Leisure/Hobby', description: 'Reading, gaming, arts' },
  { value: 'social', label: 'Social', description: 'Time with friends/family' },
  { value: 'self-care', label: 'Self-care', description: 'Meditation, relaxation' },
  { value: 'household', label: 'Household', description: 'Cleaning, cooking, errands' },
  { value: 'other', label: 'Other', description: 'Custom activities' },
];

export default function ActivityPicker({
  selectedCategories,
  highlights,
  onCategoriesChange,
  onHighlightsChange,
}: ActivityPickerProps) {
  const toggleCategory = (category: ActivityCategory) => {
    if (selectedCategories.includes(category)) {
      onCategoriesChange(selectedCategories.filter(c => c !== category));
    } else {
      onCategoriesChange([...selectedCategories, category]);
    }
  };

  return (
    <div className="space-y-6">
      <div className="space-y-4">
        <label className="block text-sm font-medium text-gray-700">
          What were the main activities or events of your day?
        </label>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {categories.map(({ value, label, description }) => (
            <button
              key={value}
              onClick={() => toggleCategory(value)}
              className={`p-4 rounded-lg text-left transition-all ${
                selectedCategories.includes(value)
                  ? 'bg-indigo-100 text-indigo-700 ring-2 ring-indigo-500'
                  : 'bg-white hover:bg-gray-50 text-gray-700'
              }`}
            >
              <div className="font-medium">{label}</div>
              <div className="text-sm text-gray-500">{description}</div>
            </button>
          ))}
        </div>
      </div>

      <div className="space-y-2">
        <label className="block text-sm font-medium text-gray-700">
          Event Highlights
        </label>
        <textarea
          value={highlights}
          onChange={(e) => onHighlightsChange(e.target.value)}
          placeholder="Briefly note any specific events or experiences..."
          className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500"
          rows={3}
        />
      </div>
    </div>
  );
}
