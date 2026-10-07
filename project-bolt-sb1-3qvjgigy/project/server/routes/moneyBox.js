const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { getDatabase } = require('../database/init');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Add money donation
router.post('/donate', authenticateToken, (req, res) => {
  try {
    const { amount, reason } = req.body;
    const db = getDatabase();
    const entryId = uuidv4();

    db.run(
      'INSERT INTO money_box (id, amount, type, user_id, reason) VALUES (?, ?, ?, ?, ?)',
      [entryId, parseFloat(amount), 'donation', req.user.id, reason],
      function(err) {
        if (err) {
          return res.status(500).json({ error: 'Failed to add donation' });
        }
        
        res.status(201).json({
          id: entryId,
          amount: parseFloat(amount),
          type: 'donation',
          user_id: req.user.id,
          reason,
          created_at: new Date().toISOString()
        });
      }
    );
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Request withdrawal
router.post('/withdraw', authenticateToken, (req, res) => {
  try {
    const { amount, reason } = req.body;
    const db = getDatabase();
    const entryId = uuidv4();

    // Check if there's enough balance
    db.get(
      `SELECT 
        COALESCE(SUM(CASE WHEN type = 'donation' THEN amount ELSE 0 END), 0) - 
        COALESCE(SUM(CASE WHEN type = 'withdrawal' THEN amount ELSE 0 END), 0) as balance
       FROM money_box`,
      (err, result) => {
        if (err) {
          return res.status(500).json({ error: 'Database error' });
        }

        if (result.balance < parseFloat(amount)) {
          return res.status(400).json({ error: 'Insufficient funds in money box' });
        }

        db.run(
          'INSERT INTO money_box (id, amount, type, user_id, reason) VALUES (?, ?, ?, ?, ?)',
          [entryId, parseFloat(amount), 'withdrawal', req.user.id, reason],
          function(err) {
            if (err) {
              return res.status(500).json({ error: 'Failed to process withdrawal' });
            }
            
            res.status(201).json({
              id: entryId,
              amount: parseFloat(amount),
              type: 'withdrawal',
              user_id: req.user.id,
              reason,
              created_at: new Date().toISOString()
            });
          }
        );
      }
    );
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Get balance and transaction logs
router.get('/logs', (req, res) => {
  const db = getDatabase();
  
  // Get balance
  db.get(
    `SELECT 
      COALESCE(SUM(CASE WHEN type = 'donation' THEN amount ELSE 0 END), 0) - 
      COALESCE(SUM(CASE WHEN type = 'withdrawal' THEN amount ELSE 0 END), 0) as balance,
      COUNT(CASE WHEN type = 'donation' THEN 1 END) as total_donations,
      COUNT(CASE WHEN type = 'withdrawal' THEN 1 END) as total_withdrawals
     FROM money_box`,
    (err, summary) => {
      if (err) {
        return res.status(500).json({ error: 'Failed to get balance' });
      }

      // Get recent transactions
      db.all(
        `SELECT m.*, u.name as user_name, u.email as user_email
         FROM money_box m
         JOIN users u ON m.user_id = u.id
         ORDER BY m.created_at DESC
         LIMIT 50`,
        (err, transactions) => {
          if (err) {
            return res.status(500).json({ error: 'Failed to get transactions' });
          }
          
          res.json({
            balance: summary.balance,
            total_donations: summary.total_donations,
            total_withdrawals: summary.total_withdrawals,
            transactions
          });
        }
      );
    }
  );
});

module.exports = router;