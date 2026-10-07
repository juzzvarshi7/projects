"use client";

import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Trophy, Medal, Award, Leaf } from 'lucide-react';
import { LeaderboardResponse } from '@/types';

export default function LeaderboardPage() {
  const [leaderboard, setLeaderboard] = useState<LeaderboardResponse | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchLeaderboard();
  }, []);

  const fetchLeaderboard = async () => {
    try {
      const response = await fetch('/api/leaderboard');
      const data: LeaderboardResponse = await response.json();
      setLeaderboard(data);
    } catch (error) {
      console.error('Error fetching leaderboard:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const getRankIcon = (rank: number) => {
    switch (rank) {
      case 1:
        return <Trophy className="w-6 h-6 text-yellow-500" />;
      case 2:
        return <Medal className="w-6 h-6 text-gray-400" />;
      case 3:
        return <Award className="w-6 h-6 text-amber-600" />;
      default:
        return <span className="w-6 h-6 flex items-center justify-center text-lg font-bold text-gray-500">#{rank}</span>;
    }
  };

  const getRankBadgeVariant = (rank: number) => {
    switch (rank) {
      case 1:
        return "default";
      case 2:
        return "secondary";
      case 3:
        return "outline";
      default:
        return "outline";
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-blue-50 to-indigo-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading leaderboard...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-blue-50 to-indigo-50">
      <div className="max-w-4xl mx-auto px-4 py-8">
        <div className="text-center mb-12">
          <h1 className="text-4xl font-bold mb-4">
            <span className="bg-gradient-to-r from-green-600 to-blue-600 bg-clip-text text-transparent">
              Eco Leaderboard
            </span>
            <span className="ml-2">🏆</span>
          </h1>
          <p className="text-xl text-gray-600">
            Champions of sustainable eating making a difference for our planet
          </p>
        </div>

        <Card className="w-full max-w-3xl mx-auto shadow-xl border-0 bg-white/90 backdrop-blur">
          <CardHeader>
            <CardTitle className="text-2xl text-center flex items-center justify-center gap-2">
              <Trophy className="w-6 h-6 text-yellow-500" />
              Top Eco Warriors
            </CardTitle>
          </CardHeader>

          <CardContent>
            {!leaderboard?.users || leaderboard.users.length === 0 ? (
              <div className="text-center py-12">
                <Leaf className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                <h3 className="text-xl font-semibold text-gray-600 mb-2">
                  No eco warriors yet!
                </h3>
                <p className="text-gray-500">
                  Be the first to analyze your meals and start earning eco points.
                </p>
              </div>
            ) : (
              <div className="space-y-4">
                {leaderboard.users.map((user, index) => {
                  const rank = index + 1;
                  return (
                    <div
                      key={`${user.name}-${rank}`}
                      className={`flex items-center justify-between p-4 rounded-lg transition-all hover:shadow-md ${
                        rank <= 3 
                          ? 'bg-gradient-to-r from-yellow-50 to-green-50 border-2 border-yellow-200' 
                          : 'bg-gray-50 hover:bg-gray-100'
                      }`}
                    >
                      <div className="flex items-center space-x-4">
                        <div className="flex items-center justify-center">
                          {getRankIcon(rank)}
                        </div>
                        <div>
                          <h3 className="text-lg font-semibold text-gray-800">
                            {user.name}
                          </h3>
                          <p className="text-sm text-gray-500">
                            Rank #{rank}
                          </p>
                        </div>
                      </div>

                      <div className="flex items-center space-x-3">
                        <div className="text-right">
                          <div className="text-2xl font-bold text-green-600">
                            {user.points}
                          </div>
                          <div className="text-sm text-gray-500">
                            eco points
                          </div>
                        </div>
                        <Badge variant={getRankBadgeVariant(rank)} className="ml-2">
                          {rank <= 3 ? '🌟' : '🌱'}
                        </Badge>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </CardContent>
        </Card>

        <div className="mt-8 text-center">
          <div className="bg-white/80 backdrop-blur rounded-lg p-6 max-w-2xl mx-auto">
            <h3 className="text-lg font-semibold text-gray-800 mb-2">
              How to Earn Eco Points 🌱
            </h3>
            <p className="text-gray-600">
              Analyze your meals to earn points! Choose eco-friendly ingredients and smaller 
              portions to maximize your environmental impact score and climb the leaderboard.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}