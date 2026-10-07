export type EmotionLevel = 'very-low' | 'low' | 'neutral' | 'positive' | 'very-positive';
export type EmotionTag = 'relaxed' | 'stressed' | 'hopeful' | 'overwhelmed' | 'anxious' | 'grateful' | 'joyful' | 'sad' | 'angry' | 'calm';
export type ActivityCategory = 'work' | 'exercise' | 'leisure' | 'social' | 'self-care' | 'household' | 'other';
export type InteractionType = 'friends' | 'family' | 'colleagues' | 'acquaintances' | 'none';
export type InteractionQuality = 'positive' | 'neutral' | 'negative';
export type ReflectionTheme = 'gratitude' | 'challenges' | 'motivation' | 'mindfulness' | 'growth' | 'relationships';

export interface JournalEntry {
  id: string;
  date: string;
  emotionalState: {
    level: EmotionLevel;
    intensity: number;
    tags: EmotionTag[];
  };
  activities: {
    categories: ActivityCategory[];
    highlights: string;
  };
  socialInteractions: {
    types: InteractionType[];
    quality: InteractionQuality;
    highlights: string;
  };
  reflection: {
    content: string;
    themes: ReflectionTheme[];
  };
  overallRating: number;
}
