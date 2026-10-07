"use client";

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Home, Trophy, User, Leaf } from 'lucide-react';

export function Navigation() {
  const pathname = usePathname();

  const isActive = (path: string) => pathname === path;

  return (
    <nav className="sticky top-0 z-50 bg-white/80 backdrop-blur-md border-b border-gray-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          <Link href="/" className="flex items-center space-x-2">
            <Leaf className="w-8 h-8 text-green-600" />
            <span className="text-2xl font-bold bg-gradient-to-r from-green-600 to-blue-600 bg-clip-text text-transparent">
              Plate to Planet 🌍
            </span>
          </Link>

          <div className="flex space-x-1">
            <Button
              variant={isActive('/') ? 'default' : 'ghost'}
              size="sm"
              asChild
            >
              <Link href="/" className="flex items-center gap-2">
                <Home className="w-4 h-4" />
                Home
              </Link>
            </Button>
            
            <Button
              variant={isActive('/leaderboard') ? 'default' : 'ghost'}
              size="sm"
              asChild
            >
              <Link href="/leaderboard" className="flex items-center gap-2">
                <Trophy className="w-4 h-4" />
                Leaderboard
              </Link>
            </Button>
            
            <Button
              variant={isActive('/profile') ? 'default' : 'ghost'}
              size="sm"
              asChild
            >
              <Link href="/profile" className="flex items-center gap-2">
                <User className="w-4 h-4" />
                Profile
              </Link>
            </Button>
          </div>
        </div>
      </div>
    </nav>
  );
}