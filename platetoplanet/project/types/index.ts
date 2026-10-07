export interface Food {
  id: string;
  name: string;
  co2: number;
  water: number;
}

export interface User {
  id: string;
  name: string;
  points: number;
  created_at?: string;
}

export interface Meal {
  id: string;
  user_id: string;
  dish: string;
  ingredients: string[];
  co2: number;
  water: number;
  saved: number;
  created_at: string;
}

export interface ClimateReceipt {
  dish: string;
  ingredients: string[];
  co2_kg: number;
  water_l: number;
  equivalent: string;
  suggestion: string;
}

export interface ScanResponse {
  receipt?: ClimateReceipt;
  needs_admin?: boolean;
  missing_ingredients?: string[];
  error?: string;
}

export interface LeaderboardResponse {
  users: Array<{
    name: string;
    points: number;
  }>;
}

export interface ProfileResponse {
  user: User & {
    history: Meal[];
  };
}