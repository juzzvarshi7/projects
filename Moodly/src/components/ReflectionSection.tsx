import React from 'react';
import { ReflectionTheme } from '../types';

interface ReflectionSectionProps {
  content: string;
  selectedThemes: ReflectionTheme[];
  onContentChange: (content: string) => void;
  onThemesChange: (themes: ReflectionTheme[]) => void;
}

const themes: { value: ReflectionTheme; label: string }[] = [
  { value: 'gratitude', label: 'Gratitude' },
  { value: 'challenges', label: 'Challenges' },
  { value: 'motivation', label: 'Motivation' },
  { value: 'mindfulness', label: 'Mindfulness' },
  { value: 'growth', label: 'Growth' },
  { value: 'relationships', label: 'Relationships' },
];

export default function ReflectionSection({
  content,
  selectedThemes,
  onContentChange,
  onThemesChange,
}: ReflectionSectionProps) {
  const toggleTheme = (theme: ReflectionTheme) => {
    if (selectedThemes.includes(theme)) {
      onThemesChange(selectedThemes.filter(t => t !== theme));
    } else {
      onThemesChange([...selectedThemes, theme]);
    }
  };

  return (
    <div className="space-y-6">
      <div className="space-y-2">
        <label className="block text-sm font-medium text-gray-700">
          What are your main reflections from today?
        </label>
        <textarea
          value={content}
          onChange={(e) => onContentChange(e.target.value)}
          placeholder="Express your thoughts, realizations, or takeaways from the day..."
          className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500"
          rows={6}
        />
      </div>

      <div className="space-y-4">
        <label className="block text-sm font-medium text-gray-700">
          Key Themes
        </label>
        <div className="flex flex-wrap gap-2">
          {themes.map(({ value, label }) => (
            <button
              key={value}
              onClick={() => toggleTheme(value)}
              className={`px-4 py-2 rounded-full text-sm transition-all ${
                selectedThemes.includes(value)
                  ? 'bg-indigo-100 text-indigo-700 ring-2 ring-indigo-500'
                  : 'bg-white hover:bg-gray-50 text-gray-700 border border-gray-300'
              }`}
            >
              {label}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
