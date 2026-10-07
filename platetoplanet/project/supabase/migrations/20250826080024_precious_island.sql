/*
  # Plate to Planet Database Schema

  1. New Tables
    - `foods`
      - `id` (uuid, primary key)
      - `name` (text, unique, not null) - food/ingredient name
      - `co2` (float, not null) - kg CO₂ per 100g
      - `water` (float, not null) - liters per 100g

    - `users`
      - `id` (uuid, primary key)
      - `name` (text, not null) - user display name
      - `points` (int, default 0) - eco points earned

    - `meals`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key → users.id)
      - `dish` (text, not null) - dish name
      - `ingredients` (text[], not null) - list of ingredients
      - `co2` (float, not null) - total CO₂ footprint in kg
      - `water` (float, not null) - total water footprint in liters
      - `saved` (float, default 0) - potential CO₂ saved
      - `created_at` (timestamptz, default now())

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to manage their own data
    - Public read access for foods table and leaderboard data

  3. Sample Data
    - Insert common food items with their environmental impact data
*/

-- Create foods table
CREATE TABLE IF NOT EXISTS foods (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  co2 float NOT NULL,
  water float NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  points int DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Create meals table
CREATE TABLE IF NOT EXISTS meals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  dish text NOT NULL,
  ingredients text[] NOT NULL,
  co2 float NOT NULL,
  water float NOT NULL,
  saved float DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE foods ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE meals ENABLE ROW LEVEL SECURITY;

-- Policies for foods table (public read access)
CREATE POLICY "Foods are viewable by everyone"
  ON foods
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Foods can be inserted by authenticated users"
  ON foods
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Policies for users table
CREATE POLICY "Users can view all users for leaderboard"
  ON users
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Users can insert their own profile"
  ON users
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update their own profile"
  ON users
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

-- Policies for meals table
CREATE POLICY "Users can view their own meals"
  ON meals
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own meals"
  ON meals
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Insert sample food data
INSERT INTO foods (name, co2, water) VALUES
  ('beef', 6.0, 1800),
  ('chicken', 1.9, 430),
  ('pork', 3.8, 580),
  ('fish', 1.1, 380),
  ('cheese', 5.7, 700),
  ('milk', 0.9, 120),
  ('eggs', 1.4, 200),
  ('rice', 1.1, 130),
  ('wheat', 0.7, 130),
  ('bread', 0.9, 160),
  ('pasta', 0.7, 140),
  ('potatoes', 0.2, 25),
  ('tomatoes', 0.7, 180),
  ('onions', 0.2, 25),
  ('carrots', 0.2, 13),
  ('lettuce', 0.5, 240),
  ('apples', 0.2, 70),
  ('bananas', 0.3, 160),
  ('avocado', 0.8, 1000),
  ('beans', 0.4, 50),
  ('lentils', 0.4, 250),
  ('tofu', 1.2, 300),
  ('olive oil', 2.9, 140),
  ('butter', 9.0, 550),
  ('sugar', 0.7, 180),
  ('coffee', 4.6, 1100),
  ('tea', 2.2, 120)
ON CONFLICT (name) DO NOTHING;