"use client";

import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { User, Leaf, Calendar, Droplets, Car, TrendingUp } from 'lucide-react';
import { ProfileResponse, User as UserType } from '@/types';
import { format } from 'date-fns';

export default function ProfilePage() {
  const [profile, setProfile] = useState<ProfileResponse | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [userName, setUserName] = useState('');
  const [isCreatingUser, setIsCreatingUser] = useState(false);
  const [currentUserId, setCurrentUserId] = useState<string | null>(null);

  useEffect(() => {
    // In a real app, you'd get this from auth context
    // For demo purposes, we'll use localStorage
    const userId = localStorage.getItem('demo-user-id');
    if (userId) {
      setCurrentUserId(userId);
      fetchProfile(userId);
    } else {
      setIsLoading(false);
    }
  }, []);

  const fetchProfile = async (userId: string) => {
    try {
      const response = await fetch(`/api/profile?userId=${userId}`);
      const data: ProfileResponse = await response.json();
      setProfile(data);
    } catch (error) {
      console.error('Error fetching profile:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const createUser = async () => {
    if (!userName.trim()) return;

    setIsCreatingUser(true);
    try {
      // Create a demo user (in a real app, this would be handled by auth)
      const demoUserId = `demo-${Date.now()}`;
      localStorage.setItem('demo-user-id', demoUserId);
      
      // For demo purposes, we'll create a mock profile
      const mockProfile: ProfileResponse = {
        user: {
          id: demoUserId,
          name: userName,
          points: 0,
          history: []
        }
      };
      
      setProfile(mockProfile);
      setCurrentUserId(demoUserId);
    } catch (error) {
      console.error('Error creating user:', error);
    } finally {
      setIsCreatingUser(false);
    }
  };

  const totalCo2 = profile?.user.history.reduce((sum, meal) => sum + meal.co2, 0) || 0;
  const totalWater = profile?.user.history.reduce((sum, meal) => sum + meal.water, 0) || 0;

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-blue-50 to-indigo-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading profile...</p>
        </div>
      </div>
    );
  }

  if (!profile) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-blue-50 to-indigo-50">
        <div className="max-w-4xl mx-auto px-4 py-12">
          <Card className="w-full max-w-md mx-auto shadow-xl border-0 bg-white/90 backdrop-blur">
            <CardHeader>
              <CardTitle className="text-2xl text-center flex items-center justify-center gap-2">
                <User className="w-6 h-6 text-green-600" />
                Join Plate to Planet
              </CardTitle>
            </CardHeader>

            <CardContent className="space-y-6">
              <div>
                <p className="text-gray-600 mb-4">
                  Create your profile to start tracking your environmental impact!
                </p>
                <Input
                  type="text"
                  placeholder="Enter your name"
                  value={userName}
                  onChange={(e) => setUserName(e.target.value)}
                  onKeyPress={(e) => e.key === 'Enter' && createUser()}
                />
              </div>

              <Button
                onClick={createUser}
                disabled={!userName.trim() || isCreatingUser}
                size="lg"
                className="w-full bg-gradient-to-r from-green-600 to-blue-600 hover:from-green-700 hover:to-blue-700"
              >
                {isCreatingUser ? 'Creating Profile...' : 'Create Profile'}
              </Button>
            </CardContent>
          </Card>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-blue-50 to-indigo-50">
      <div className="max-w-6xl mx-auto px-4 py-8">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold mb-4">
            <span className="bg-gradient-to-r from-green-600 to-blue-600 bg-clip-text text-transparent">
              My Eco Profile
            </span>
            <span className="ml-2">🌱</span>
          </h1>
          <p className="text-xl text-gray-600">Track your environmental impact journey</p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
          {/* User Info Card */}
          <Card className="shadow-lg border-0 bg-white/90 backdrop-blur">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <User className="w-5 h-5 text-green-600" />
                Profile
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-center">
                <div className="w-20 h-20 bg-gradient-to-r from-green-600 to-blue-600 rounded-full flex items-center justify-center text-white text-2xl font-bold mx-auto mb-4">
                  {profile.user.name.charAt(0).toUpperCase()}
                </div>
                <h2 className="text-xl font-semibold text-gray-800 mb-2">
                  {profile.user.name}
                </h2>
                <div className="flex items-center justify-center gap-2">
                  <Leaf className="w-4 h-4 text-green-600" />
                  <span className="text-2xl font-bold text-green-600">
                    {profile.user.points}
                  </span>
                  <span className="text-sm text-gray-500">eco points</span>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Environmental Stats */}
          <Card className="shadow-lg border-0 bg-white/90 backdrop-blur">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <TrendingUp className="w-5 h-5 text-blue-600" />
                Impact Stats
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Car className="w-4 h-4 text-red-500" />
                  <span className="text-sm text-gray-600">Total CO₂</span>
                </div>
                <span className="font-semibold text-red-600">
                  {totalCo2.toFixed(1)} kg
                </span>
              </div>
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Droplets className="w-4 h-4 text-blue-500" />
                  <span className="text-sm text-gray-600">Total Water</span>
                </div>
                <span className="font-semibold text-blue-600">
                  {totalWater.toFixed(0)} L
                </span>
              </div>
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Calendar className="w-4 h-4 text-green-500" />
                  <span className="text-sm text-gray-600">Meals Tracked</span>
                </div>
                <span className="font-semibold text-green-600">
                  {profile.user.history.length}
                </span>
              </div>
            </CardContent>
          </Card>

          {/* Achievement Badge */}
          <Card className="shadow-lg border-0 bg-gradient-to-br from-green-50 to-blue-50">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Leaf className="w-5 h-5 text-green-600" />
                Achievement
              </CardTitle>
            </CardHeader>
            <CardContent className="text-center">
              <div className="text-4xl mb-2">
                {profile.user.points >= 100 ? '🏆' : profile.user.points >= 50 ? '🥉' : '🌱'}
              </div>
              <h3 className="font-semibold text-gray-800 mb-1">
                {profile.user.points >= 100 
                  ? 'Eco Champion' 
                  : profile.user.points >= 50 
                  ? 'Green Guardian' 
                  : 'Eco Starter'}
              </h3>
              <p className="text-sm text-gray-600">
                {profile.user.points >= 100 
                  ? 'Master of sustainable eating!' 
                  : profile.user.points >= 50 
                  ? 'Great progress on your eco journey!' 
                  : 'Keep tracking meals to level up!'}
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Meal History */}
        <Card className="shadow-lg border-0 bg-white/90 backdrop-blur">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Calendar className="w-5 h-5 text-gray-600" />
              Meal History
            </CardTitle>
          </CardHeader>
          <CardContent>
            {profile.user.history.length === 0 ? (
              <div className="text-center py-12">
                <Leaf className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                <h3 className="text-xl font-semibold text-gray-600 mb-2">
                  No meals tracked yet
                </h3>
                <p className="text-gray-500">
                  Start analyzing your meals to see your environmental impact history here.
                </p>
              </div>
            ) : (
              <div className="space-y-4">
                {profile.user.history.map((meal) => (
                  <div
                    key={meal.id}
                    className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
                  >
                    <div className="flex-1">
                      <h4 className="font-semibold text-gray-800 capitalize mb-1">
                        {meal.dish}
                      </h4>
                      <div className="flex flex-wrap gap-2 mb-2">
                        {meal.ingredients.slice(0, 3).map((ingredient, index) => (
                          <Badge key={index} variant="secondary" className="text-xs">
                            {ingredient}
                          </Badge>
                        ))}
                        {meal.ingredients.length > 3 && (
                          <Badge variant="outline" className="text-xs">
                            +{meal.ingredients.length - 3} more
                          </Badge>
                        )}
                      </div>
                      <p className="text-sm text-gray-500">
                        {format(new Date(meal.created_at), 'MMM d, yyyy • h:mm a')}
                      </p>
                    </div>
                    <div className="text-right space-y-1">
                      <div className="flex items-center gap-2">
                        <Car className="w-3 h-3 text-red-500" />
                        <span className="text-sm text-red-600 font-medium">
                          {meal.co2.toFixed(1)} kg CO₂
                        </span>
                      </div>
                      <div className="flex items-center gap-2">
                        <Droplets className="w-3 h-3 text-blue-500" />
                        <span className="text-sm text-blue-600 font-medium">
                          {meal.water.toFixed(0)} L
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}