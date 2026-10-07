const jwt = require('jsonwebtoken');
const { getDatabase } = require('../database/init');

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production-2024';

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) {
      console.error('JWT verification error:', err);
      return res.status(403).json({ error: 'Invalid or expired token' });
    }

    try {
      const db = getDatabase();
      db.get('SELECT id, name, email, role, created_at FROM users WHERE id = ?', [decoded.userId], (err, user) => {
        if (err) {
          console.error('Database error in auth middleware:', err);
          return res.status(500).json({ error: 'Database error' });
        }
        
        if (!user) {
          return res.status(403).json({ error: 'User not found' });
        }
        
        req.user = user;
        next();
      });
    } catch (error) {
      console.error('Error in auth middleware:', error);
      return res.status(500).json({ error: 'Server error' });
    }
  });
}

function requireAdmin(req, res, next) {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Admin access required' });
  }
  next();
}

module.exports = { authenticateToken, requireAdmin, JWT_SECRET };