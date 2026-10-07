/*
  # Add increment user points function

  1. New Function
    - `increment_user_points` - Safely increment user points by a given amount
    - Handles concurrent updates and ensures data consistency

  2. Security
    - Function can be called by authenticated users
*/

CREATE OR REPLACE FUNCTION increment_user_points(user_id uuid, points_to_add int)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE users 
  SET points = points + points_to_add 
  WHERE id = user_id;
  
  -- If user doesn't exist, this won't create one
  -- In a real app, you'd handle user creation separately
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION increment_user_points TO authenticated;