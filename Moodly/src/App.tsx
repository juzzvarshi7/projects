import React, { useState, useEffect } from 'react';
import { BookOpen, BarChart2 } from 'lucide-react';
import JournalEntryForm from './components/JournalEntry';
import Dashboard from './components/Dashboard';
import type { JournalEntry } from './types';

function App() {
  const [entries, setEntries] = useState<JournalEntry[]>(() => {
    const saved = localStorage.getItem('journal-entries');
    return saved ? JSON.parse(saved) : [];
  });
  const [view, setView] = useState<'journal' | 'dashboard'>('journal');

  useEffect(() => {
    localStorage.setItem('journal-entries', JSON.stringify(entries));
  }, [entries]);

  const handleSaveEntry = (entry: Omit<JournalEntry, 'id'>) => {
    const newEntry: JournalEntry = {
      ...entry,
      id: Date.now().toString(),
    };
    setEntries(prev => [...prev, newEntry]);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <h1 className="text-2xl font-bold text-gray-900">Mindful Journal</h1>
            <nav className="flex space-x-4">
              <button
                onClick={() => setView('journal')}
                className={`flex items-center px-3 py-2 rounded-md text-sm font-medium ${
                  view === 'journal'
                    ? 'bg-indigo-100 text-indigo-700'
                    : 'text-gray-500 hover:text-gray-700'
                }`}
              >
                <BookOpen className="w-4 h-4 mr-2" />
                Journal
              </button>
              <button
                onClick={() => setView('dashboard')}
                className={`flex items-center px-3 py-2 rounded-md text-sm font-medium ${
                  view === 'dashboard'
                    ? 'bg-indigo-100 text-indigo-700'
                    : 'text-gray-500 hover:text-gray-700'
                }`}
              >
                <BarChart2 className="w-4 h-4 mr-2" />
                Dashboard
              </button>
            </nav>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="max-w-3xl mx-auto">
          {view === 'journal' ? (
            <div className="bg-white shadow-lg rounded-lg p-6">
              <JournalEntryForm onSave={handleSaveEntry} />
            </div>
          ) : (
            <Dashboard entries={entries} />
          )}
        </div>
      </main>
    </div>
  );
}

export default App;
