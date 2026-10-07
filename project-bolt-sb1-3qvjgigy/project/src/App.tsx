import React, { useState, useEffect } from 'react';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import LoadingScreen from './components/LoadingScreen';
import Navigation from './components/Navigation';
import HomePage from './components/HomePage';
import AuthPage from './components/AuthPage';
import DonatePage from './components/DonatePage';
import BrowseItemsPage from './components/BrowseItemsPage';
import ItemDetailsPage from './components/ItemDetailsPage';
import ClaimConfirmationPage from './components/ClaimConfirmationPage';
import MyClaimsPage from './components/MyClaimsPage';
import MoneyBoxPage from './components/MoneyBoxPage';
import ProfilePage from './components/ProfilePage';

function AppContent() {
  const [currentPage, setCurrentPage] = useState('loading');
  const [showLoading, setShowLoading] = useState(true);
  const [pageData, setPageData] = useState<any>(null);
  const { user, loading } = useAuth();

  useEffect(() => {
    if (!loading && showLoading) {
      // Show loading screen for at least 2 seconds
      const timer = setTimeout(() => {
        setShowLoading(false);
        if (user) {
          setCurrentPage('home');
        } else {
          setCurrentPage('auth');
        }
      }, 2000);
      
      return () => clearTimeout(timer);
    }
  }, [loading, showLoading, user]);

  const handleNavigation = (page: string, data?: any) => {
    setPageData(data);
    setCurrentPage(page);
    // Scroll to top when navigating
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleLoadingComplete = () => {
    setShowLoading(false);
    if (user) {
      setCurrentPage('home');
    } else {
      setCurrentPage('auth');
    }
  };

  // Show loading screen
  if (showLoading) {
    return <LoadingScreen onComplete={handleLoadingComplete} />;
  }

  // Show auth page if not authenticated (except for certain public pages)
  if (!user && !['auth', 'home', 'browse', 'item-details'].includes(currentPage)) {
    return <AuthPage onNavigate={handleNavigation} />;
  }

  const renderPage = () => {
    switch (currentPage) {
      case 'auth':
        return <AuthPage onNavigate={handleNavigation} />;
      case 'home':
        return <HomePage onNavigate={handleNavigation} />;
      case 'donate':
        return <DonatePage onNavigate={handleNavigation} />;
      case 'browse':
        return <BrowseItemsPage onNavigate={handleNavigation} />;
      case 'item-details':
        return <ItemDetailsPage onNavigate={handleNavigation} item={pageData} />;
      case 'claim-confirmation':
        return <ClaimConfirmationPage onNavigate={handleNavigation} claimData={pageData} />;
      case 'my-claims':
        return <MyClaimsPage onNavigate={handleNavigation} />;
      case 'money-box':
        return <MoneyBoxPage onNavigate={handleNavigation} />;
      case 'profile':
        return <ProfilePage onNavigate={handleNavigation} />;
      default:
        return <HomePage onNavigate={handleNavigation} />;
    }
  };

  const showNavigation = user && !['auth', 'loading'].includes(currentPage);

  return (
    <div className="min-h-screen bg-gray-50">
      {showNavigation && (
        <Navigation currentPage={currentPage} onNavigate={handleNavigation} />
      )}
      {renderPage()}
    </div>
  );
}

function App() {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  );
}

export default App;