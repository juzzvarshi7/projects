import React, { useEffect, useState } from 'react';
import { Heart } from 'lucide-react';

interface LoadingScreenProps {
  onComplete: () => void;
}

const LoadingScreen: React.FC<LoadingScreenProps> = ({ onComplete }) => {
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      setProgress((prev) => {
        if (prev >= 100) {
          clearInterval(timer);
          setTimeout(onComplete, 500);
          return 100;
        }
        return prev + 2;
      });
    }, 50);

    return () => clearInterval(timer);
  }, [onComplete]);

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-600 via-purple-600 to-teal-600 flex items-center justify-center">
      <div className="text-center">
        <div className="relative mb-8">
          <div className="w-24 h-24 bg-white rounded-full flex items-center justify-center mx-auto shadow-2xl">
            <Heart className="w-12 h-12 text-blue-600 animate-pulse" />
          </div>
          <div className="absolute -inset-4 bg-white/20 rounded-full animate-ping"></div>
        </div>
        
        <h1 className="text-4xl font-bold text-white mb-4">DonateHub</h1>
        <p className="text-xl text-white/90 mb-8">Connecting hearts, sharing hope</p>
        
        <div className="w-64 h-2 bg-white/20 rounded-full mx-auto">
          <div
            className="h-full bg-white rounded-full transition-all duration-300 ease-out"
            style={{ width: `${progress}%` }}
          ></div>
        </div>
        
        <p className="text-white/80 mt-4">Loading your donation platform...</p>
      </div>
    </div>
  );
};

export default LoadingScreen;