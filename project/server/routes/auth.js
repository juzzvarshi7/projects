const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const { getDatabase } = require('../database/init');
const { authenticateToken, JWT_SECRET } = require('../middleware/auth');

const router = express.Router();

// Signup
router.post('/signup', async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Validate input
    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Name, email, and password are required' });
    }

    // Validate college email (more flexible validation)
    if (!email.includes('@') || (!email.includes('college.edu') && !email.includes('.edu'))) {
      return res.status(400).json({ error: 'Please use a valid college email address (.edu domain)' });
    }

    const db = getDatabase();
    
    // Check if user already exists
    db.get('SELECT id FROM users WHERE email = ?', [email], async (err, existingUser) => {
      if (err) {
        console.error('Database error:', err);
        return res.status(500).json({ error: 'Database error' });
      }
      
      if (existingUser) {
        return res.status(400).json({ error: 'Email already registered' });
      }

      try {
        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);
        const userId = uuidv4();

        // Create user
        db.run(
          'INSERT INTO users (id, name, email, password_hash) VALUES (?, ?, ?, ?)',
          [userId, name, email, hashedPassword],
          function(err) {
            if (err) {
              console.error('Error creating user:', err);
              return res.status(500).json({ error: 'Failed to create user' });
            }

            // Generate JWT token
            const token = jwt.sign({ userId }, JWT_SECRET, { expiresIn: '7d' });

            // Return user data
            const user = {
              id: userId,
              name,
              email,
              role: 'student',
              created_at: new Date().toISOString()
            };

            console.log('User created successfully:', email);
            res.status(201).json({ token, user });
          }
        );
      } catch (hashError) {
        console.error('Error hashing password:', hashError);
        res.status(500).json({ error: 'Server error' });
      }
    });
  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const db = getDatabase();

    db.get('SELECT * FROM users WHERE email = ?', [email], async (err, user) => {
      if (err) {
        console.error('Database error:', err);
        return res.status(500).json({ error: 'Database error' });
      }
      
      if (!user) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      try {
        // Check password
        const isValidPassword = await bcrypt.compare(password, user.password_hash);
        if (!isValidPassword) {
          return res.status(401).json({ error: 'Invalid credentials' });
        }

        // Generate JWT token
        const token = jwt.sign({ userId: user.id }, JWT_SECRET, { expiresIn: '7d' });

        // Return user data (without password)
        const { password_hash, ...userWithoutPassword } = user;
        
        console.log('User logged in successfully:', email);
        res.json({ token, user: userWithoutPassword });
      } catch (compareError) {
        console.error('Error comparing password:', compareError);
        res.status(500).json({ error: 'Server error' });
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get profile
router.get('/profile', authenticateToken, (req, res) => {
  res.json(req.user);
});

module.exports = router;