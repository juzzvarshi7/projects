import { NextRequest, NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';
import { analyzeImageIngredients, analyzeDishIngredients, generateFriendlySummary } from '@/lib/openai';
import { Food } from '@/types';

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData();
    const imageFile = formData.get('imageFile') as File | null;
    const dishName = formData.get('dishName') as string | null;
    const userId = formData.get('userId') as string | null;

    if (!imageFile && !dishName) {
      return NextResponse.json(
        { error: 'Either imageFile or dishName is required' },
        { status: 400 }
      );
    }

    let ingredients: string[] = [];

    // Analyze ingredients
    if (imageFile) {
      const buffer = Buffer.from(await imageFile.arrayBuffer());
      ingredients = await analyzeImageIngredients(buffer);
    } else if (dishName) {
      ingredients = await analyzeDishIngredients(dishName);
    }

    // Get food data from database
    const { data: foods, error: foodsError } = await supabase
      .from('foods')
      .select('*')
      .in('name', ingredients);

    if (foodsError) {
      console.error('Error fetching foods:', foodsError);
      return NextResponse.json(
        { error: 'Failed to fetch food data' },
        { status: 500 }
      );
    }

    const foundFoods = foods as Food[];
    const foundFoodNames = foundFoods.map(f => f.name);
    const missingIngredients = ingredients.filter(ing => !foundFoodNames.includes(ing));

    // If ingredients are missing from database, return admin flag
    if (missingIngredients.length > 0) {
      return NextResponse.json({
        needs_admin: true,
        missing_ingredients: missingIngredients
      });
    }

    // Calculate totals (assuming 100g per ingredient)
    let totalCo2 = 0;
    let totalWater = 0;

    foundFoods.forEach(food => {
      totalCo2 += food.co2;
      totalWater += food.water;
    });

    const dish = dishName || `Dish with ${ingredients.join(', ')}`;
    
    // Generate friendly summary
    const { equivalent, suggestion } = await generateFriendlySummary(
      totalCo2,
      totalWater,
      dish
    );

    // Save meal record if user is provided
    if (userId) {
      const points = Math.max(1, Math.floor((10 - totalCo2) * 2)); // More eco-friendly = more points
      
      // Save meal
      await supabase.from('meals').insert({
        user_id: userId,
        dish,
        ingredients,
        co2: totalCo2,
        water: totalWater,
        saved: 0
      });

      // Update user points
      await supabase.rpc('increment_user_points', {
        user_id: userId,
        points_to_add: Math.max(0, points)
      });
    }

    return NextResponse.json({
      receipt: {
        dish,
        ingredients,
        co2_kg: Math.round(totalCo2 * 100) / 100,
        water_l: Math.round(totalWater * 100) / 100,
        equivalent,
        suggestion
      }
    });

  } catch (error) {
    console.error('Error in scan API:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}