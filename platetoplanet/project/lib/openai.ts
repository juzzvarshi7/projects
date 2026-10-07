import OpenAI from 'openai';

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY!,
});

export async function analyzeImageIngredients(imageBuffer: Buffer): Promise<string[]> {
  try {
    const base64Image = imageBuffer.toString('base64');
    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        {
          role: "user",
          content: [
            {
              type: "text",
              text: "From this food image, return a JSON array of base ingredients (lowercase strings)."
            },
            {
              type: "image_url",
              image_url: {
                url: `data:image/jpeg;base64,${base64Image}`
              }
            }
          ]
        }
      ],
      max_tokens: 300,
      temperature: 0.1
    });

    const content = response.choices[0]?.message?.content;
    if (!content) throw new Error('No response from OpenAI');

    return JSON.parse(content);
  } catch (error) {
    console.error('Error analyzing image:', error);
    throw new Error('Failed to analyze image');
  }
}

export async function analyzeDishIngredients(dishName: string): Promise<string[]> {
  try {
    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        {
          role: "user",
          content: `Normalize this dish name into a JSON array of base ingredients (lowercase strings): "${dishName}"`
        }
      ],
      max_tokens: 200,
      temperature: 0.1
    });

    const content = response.choices[0]?.message?.content;
    if (!content) throw new Error('No response from OpenAI');

    return JSON.parse(content);
  } catch (error) {
    console.error('Error analyzing dish:', error);
    throw new Error('Failed to analyze dish');
  }
}

export async function generateFriendlySummary(
  co2_kg: number,
  water_l: number,
  dish: string
): Promise<{ equivalent: string; suggestion: string }> {
  try {
    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        {
          role: "user",
          content: `Given totals ${co2_kg} kg CO2 and ${water_l} L water for ${dish}, write a short, friendly summary with 1-2 equivalents (like km driving, minutes showering) and a greener alternative. Return as JSON with "equivalent" and "suggestion" keys. Keep under 45 words each.`
        }
      ],
      max_tokens: 300,
      temperature: 0.3
    });

    const content = response.choices[0]?.message?.content;
    if (!content) throw new Error('No response from OpenAI');

    return JSON.parse(content);
  } catch (error) {
    console.error('Error generating summary:', error);
    return {
      equivalent: `That's like driving ${(co2_kg * 4.6).toFixed(1)}km or showering for ${(water_l / 10).toFixed(0)} minutes!`,
      suggestion: 'Try plant-based alternatives or smaller portions to reduce your environmental impact.'
    };
  }
}