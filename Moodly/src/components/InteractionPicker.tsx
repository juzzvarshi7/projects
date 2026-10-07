import React from 'react';
import { InteractionType, InteractionQuality } from '../types';

interface InteractionPickerProps {
  selectedTypes: InteractionType[];
  quality: InteractionQuality;
  highlights: string;
  onTypesChange: (types: InteractionType[]) => void;
  onQualityChange: (quality: InteractionQuality) => void;
  onHighlightsChange: (highlights: string) => void;
}

const interactionTypes: { value: InteractionType; label: string }[] = [
  { value: 'friends', label: 'Friends' },
  { value: 'family', label: 'Family' },
  { value: 'colleagues', label: 'Colleagues/Peers' },
  { value: 'acquaintances', label: 'Acquaintances/Strangers' },
  { value: 'none', label: 'None (Day spent alone)' },
];

const qualities: { value: InteractionQuality; label: string; description: string }[] = [
  { value: 'positive', label: 'Positive', description: 'Supportive, enjoyable' },
  { value: 'neutral', label: 'Neutral', description: 'Brief, routine' },
  { value: 'negative', label: 'Negative', description: 'Stressful, draining' },
];

export default function InteractionPicker({
  selectedTypes,
  quality,
  highlights,
  onTypesChange,
  onQualityChange,
  onHighlightsChange,
}: InteractionPickerProps) {
  const toggleType = (type: InteractionType) => {
    if (type === 'none') {
      onTypesChange(['none']);
    } else {
      const newTypes = selectedTypes.includes(type)
        ? selectedTypes.filter(t => t !== type)
        : [...selectedTypes.filter(t => t !== 'none'), type];
      onTypesChange(newTypes);
    }
  };

  return (
    <div className="space-y-6">
      <div className="space-y-4">
        <label className="block text-sm font-medium text-gray-700">
          Who did you interact with today?
        </label>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {interactionTypes.map(({ value, label }) => (
            <button
              key={value}
              onClick={() => toggleType(value)}
              className={`p-4 rounded-lg text-center transition-all ${
                selectedTypes.includes(value)
                  ? 'bg-indigo-100 text-indigo-700 ring-2 ring-indigo-500'
                  : 'bg-white hover:bg-gray-50 text-gray-700'
              }`}
            >
              {label}
            </button>
          ))}
        </div>
      </div>

      <div className="space-y-4">
        <label className="block text-sm font-medium text-gray-700">
          Quality of Interactions
        </label>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          {qualities.map(({ value, label, description }) => (
            <button
              key={value}
              onClick={() => onQualityChange(value)}
              className={`p-4 rounded-lg text-center transition-all ${
                quality === value
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
          Interaction Highlights
        </label>
        <textarea
          value={highlights}
          onChange={(e) => onHighlightsChange(e.target.value)}
          placeholder="Note any memorable social moments..."
          className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500"
          rows={3}
        />
      </div>
    </div>
  );
}
