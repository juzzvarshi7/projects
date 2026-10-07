import React from 'react';
import { format, subDays } from 'date-fns';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
} from 'recharts';
import type { JournalEntry } from '../types';

interface DashboardProps {
  entries: JournalEntry[];
}

const COLORS = {
  'very-positive': '#4ade80',
  'positive': '#60a5fa',
  'neutral': '#d1d5db',
  'low': '#fbbf24',
  'very-low': '#f87171',
};

export default function Dashboard({ entries }: DashboardProps) {
  const last7Days = Array.from({ length: 7 }, (_, i) => format(subDays(new Date(), i), 'yyyy-MM-dd')).reverse();
  
  const moodData = last7Days.map(date => {
    const entry = entries.find(e => e.date === date);
    return {
      date: format(new Date(date), 'MMM d'),
      rating: entry?.overallRating || 0,
      intensity: entry?.emotionalState.intensity || 0,
    };
  });

  const emotionLevelData = entries.reduce((acc, entry) => {
    acc[entry.emotionalState.level] = (acc[entry.emotionalState.level] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);

  const pieData = Object.entries(emotionLevelData).map(([name, value]) => ({
    name,
    value,
  }));

  const activityData = entries.reduce((acc, entry) => {
    entry.activities.categories.forEach(category => {
      acc[category] = (acc[category] || 0) + 1;
    });
    return acc;
  }, {} as Record<string, number>);

  return (
    <div className="space-y-8">
      <div className="bg-white p-6 rounded-lg shadow-lg">
        <h3 className="text-lg font-medium text-gray-900 mb-4">Daily Ratings & Emotional Intensity</h3>
        <div className="h-64">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={moodData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="date" />
              <YAxis domain={[0, 10]} />
              <Tooltip />
              <Line
                type="monotone"
                dataKey="rating"
                stroke="#6366f1"
                name="Day Rating"
                strokeWidth={2}
              />
              <Line
                type="monotone"
                dataKey="intensity"
                stroke="#ec4899"
                name="Emotional Intensity"
                strokeWidth={2}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="bg-white p-6 rounded-lg shadow-lg">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Emotional States Distribution</h3>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={pieData}
                  dataKey="value"
                  nameKey="name"
                  cx="50%"
                  cy="50%"
                  outerRadius={80}
                  label
                >
                  {pieData.map((entry, index) => (
                    <Cell
                      key={`cell-${index}`}
                      fill={COLORS[entry.name as keyof typeof COLORS]}
                    />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-lg">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Activity Distribution</h3>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart
                data={Object.entries(activityData).map(([name, value]) => ({
                  name,
                  value,
                }))}
              >
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" />
                <YAxis />
                <Tooltip />
                <Bar dataKey="value" fill="#6366f1" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      <div className="bg-white p-6 rounded-lg shadow-lg">
        <h3 className="text-lg font-medium text-gray-900 mb-4">Recent Reflections</h3>
        <div className="space-y-4">
          {entries.slice(0, 3).map(entry => (
            <div key={entry.id} className="border-l-4 border-indigo-500 pl-4">
              <div className="text-sm text-gray-500">{format(new Date(entry.date), 'MMMM d, yyyy')}</div>
              <div className="mt-1">{entry.reflection.content}</div>
              <div className="mt-2 flex flex-wrap gap-2">
                {entry.reflection.themes.map(theme => (
                  <span
                    key={theme}
                    className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-indigo-100 text-indigo-800"
                  >
                    {theme}
                  </span>
                ))}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
