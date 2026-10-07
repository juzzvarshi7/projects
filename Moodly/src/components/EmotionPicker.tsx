import React from 'react';
import { EmotionLevel, EmotionTag } from '../types';

interface EmotionPickerProps {
  selectedLevel: EmotionLevel;
  selectedTags: EmotionTag[];
  intensity: number;
  onLevelChange: (level: EmotionLevel) => void;
  onTagsChange: (tags: EmotionTag[]) => void;
  onIntensityChange: (intensity: number) => void;
}

const emotionLevels: { value: EmotionLevel; label: string; description: string }[] = [
  { value: 'very-low', label: 'Very Low', description: 'Sad, Anxious, Angry' },
  { value: 'low', label: 'Low', description: 'Tired, Bored, Lonely' },
  { value: 'neutral', label: 'Neutral', description: 'Okay, Content' },
  { value: 'positive', label: 'Positive', description: 'Happy, Calm, Satisfied' },
  { value: 'very-positive', label: 'Very Positive', description: 'Excited, Joyful, Grateful' },
];

const emotionTags: EmotionTag[] = [
  'relaxed', 'stressed', 'hopeful', 'overwhelmed', 'anxious',
  'grateful', 'joyful', 'sad', 'angry', 'calm'
];

export default function EmotionPicker({
  selectedLevel,
  selectedTags,
  intensity,
  onLevelChange,
  onTagsChange,
  onIntensityChange,
}: EmotionPickerProps) {
  const handleTagToggle = (tag: EmotionTag) => {
    if (selectedTags.includes(tag)) {
      onTagsChange(selectedTags.filter(t => t !== tag));
    } else if (selectedTags.length < 3) {
      onTagsChange([...selectedTags, tag]);
    }
  };

  return (
    <div className="space-y-6">
      <div className="space-y-4">
        <label className="block text-sm font-medium text-gray-700">
          How did you feel overall today?
        </label>
        <div className="grid grid-cols-1 sm:grid-cols-5 gap-4">
          {emotionLevels.map(({ value, label, description }) => (
            <button
              key={value}
              onClick={() => onLevelChange(value)}
              className={`p-4 rounded-lg text-center transition-all ${
                selectedLevel === value
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

      <div className="space-y-4">
        <label className="block text-sm font-medium text-gray-700">
          Intensity Level
        </label>
        <input
          type="range"
          min="1"
          max="10"
          value={intensity}
          onChange={(e) => onIntensityChange(Number(e.target.value))}
          className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer"
        />
        <div className="flex justify-between text-xs text-gray-600">
          <span>Low Intensity</span>
          <span>{intensity}</span>
          <span>High Intensity</span>
        </div>
      </div>

      <div className="space-y-4">
        <label className="block text-sm font-medium text-gray-700">
          Select up to 3 emotion tags
        </label>
        <div className="flex flex-wrap gap-2">
          {emotionTags.map(tag => (
            <button
              key={tag}
              onClick={() => handleTagToggle(tag)}
              className={`px-3 py-1 rounded-full text-sm ${
                selectedTags.includes(tag)
                  ? 'bg-indigo-100 text-indigo-700'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              {tag}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
