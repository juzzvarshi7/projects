import React, { useState } from 'react';
import { format } from 'date-fns';
import EmotionPicker from './EmotionPicker';
import ActivityPicker from './ActivityPicker';
import InteractionPicker from './InteractionPicker';
import ReflectionSection from './ReflectionSection';
import DayRating from './DayRating';
import type {
  JournalEntry,
  EmotionLevel,
  EmotionTag,
  ActivityCategory,
  InteractionType,
  InteractionQuality,
  ReflectionTheme,
} from '../types';

interface JournalEntryFormProps {
  onSave: (entry: Omit<JournalEntry, 'id'>) => void;
}

export default function JournalEntryForm({ onSave }: JournalEntryFormProps) {
  const [emotionLevel, setEmotionLevel] = useState<EmotionLevel>('neutral');
  const [emotionIntensity, setEmotionIntensity] = useState(5);
  const [emotionTags, setEmotionTags] = useState<EmotionTag[]>([]);
  
  const [activityCategories, setActivityCategories] = useState<ActivityCategory[]>([]);
  const [activityHighlights, setActivityHighlights] = useState('');
  
  const [interactionTypes, setInteractionTypes] = useState<InteractionType[]>([]);
  const [interactionQuality, setInteractionQuality] = useState<InteractionQuality>('neutral');
  const [interactionHighlights, setInteractionHighlights] = useState('');
  
  const [reflectionContent, setReflectionContent] = useState('');
  const [reflectionThemes, setReflectionThemes] = useState<ReflectionTheme[]>([]);
  
  const [overallRating, setOverallRating] = useState(3);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave({
      date: format(new Date(), 'yyyy-MM-dd'),
      emotionalState: {
        level: emotionLevel,
        intensity: emotionIntensity,
        tags: emotionTags,
      },
      activities: {
        categories: activityCategories,
        highlights: activityHighlights,
      },
      socialInteractions: {
        types: interactionTypes,
        quality: interactionQuality,
        highlights: interactionHighlights,
      },
      reflection: {
        content: reflectionContent,
        themes: reflectionThemes,
      },
      overallRating,
    });

    // Reset form
    setEmotionLevel('neutral');
    setEmotionIntensity(5);
    setEmotionTags([]);
    setActivityCategories([]);
    setActivityHighlights('');
    setInteractionTypes([]);
    setInteractionQuality('neutral');
    setInteractionHighlights('');
    setReflectionContent('');
    setReflectionThemes([]);
    setOverallRating(3);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-8">
      <div className="space-y-8 divide-y divide-gray-200">
        <section className="pt-8">
          <h3 className="text-lg font-medium text-gray-900 mb-6">Emotional State</h3>
          <EmotionPicker
            selectedLevel={emotionLevel}
            selectedTags={emotionTags}
            intensity={emotionIntensity}
            onLevelChange={setEmotionLevel}
            onTagsChange={setEmotionTags}
            onIntensityChange={setEmotionIntensity}
          />
        </section>

        <section className="pt-8">
          <h3 className="text-lg font-medium text-gray-900 mb-6">Activities and Events</h3>
          <ActivityPicker
            selectedCategories={activityCategories}
            highlights={activityHighlights}
            onCategoriesChange={setActivityCategories}
            onHighlightsChange={setActivityHighlights}
          />
        </section>

        <section className="pt-8">
          <h3 className="text-lg font-medium text-gray-900 mb-6">Social Interactions</h3>
          <InteractionPicker
            selectedTypes={interactionTypes}
            quality={interactionQuality}
            highlights={interactionHighlights}
            onTypesChange={setInteractionTypes}
            onQualityChange={setInteractionQuality}
            onHighlightsChange={setInteractionHighlights}
          />
        </section>

        <section className="pt-8">
          <h3 className="text-lg font-medium text-gray-900 mb-6">Personal Reflection</h3>
          <ReflectionSection
            content={reflectionContent}
            selectedThemes={reflectionThemes}
            onContentChange={setReflectionContent}
            onThemesChange={setReflectionThemes}
          />
        </section>

        <section className="pt-8">
          <DayRating rating={overallRating} onChange={setOverallRating} />
        </section>
      </div>

      <div className="pt-8">
        <button
          type="submit"
          className="w-full flex justify-center py-3 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          Save Journal Entry
        </button>
      </div>
    </form>
  );
}
