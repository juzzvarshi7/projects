import React from 'react';
import { BrowserRouter, Routes, Route, Link } from 'react-router-dom';
import Login from './pages/Login';
import Signup from './pages/Signup';
import Dashboard from './pages/Dashboard';
import History from './pages/History';

export default function App(){
  return (
    <BrowserRouter>
      <nav style={{padding:10}}>
        <Link to="/">Home</Link> | <Link to="/dashboard">Dashboard</Link> | <Link to="/history">History</Link>
      </nav>
      <Routes>
        <Route path="/" element={<div style={{padding:20}}>Agri-Diagnose Pro — open /dashboard to test</div>} />
        <Route path="/login" element={<Login/>} />
        <Route path="/signup" element={<Signup/>} />
        <Route path="/dashboard" element={<Dashboard/>} />
        <Route path="/history" element={<History/>} />
      </Routes>
    </BrowserRouter>
  );
}
