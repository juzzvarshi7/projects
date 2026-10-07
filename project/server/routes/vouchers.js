const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { getDatabase } = require('../database/init');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Create voucher donation
router.post('/', authenticateToken, (req, res) => {
  try {
    const { type, value, description } = req.body;
    const db = getDatabase();
    const voucherId = uuidv4();

    db.run(
      'INSERT INTO vouchers (id, type, value, donor_id, description) VALUES (?, ?, ?, ?, ?)',
      [voucherId, type, parseFloat(value), req.user.id, description],
      function(err) {
        if (err) {
          return res.status(500).json({ error: 'Failed to create voucher' });
        }
        
        // Fetch created voucher with donor info
        db.get(
          `SELECT v.*, u.name as donor_name, u.email as donor_email
           FROM vouchers v
           JOIN users u ON v.donor_id = u.id
           WHERE v.id = ?`,
          [voucherId],
          (err, voucher) => {
            if (err) {
              return res.status(500).json({ error: 'Failed to fetch created voucher' });
            }
            res.status(201).json(voucher);
          }
        );
      }
    );
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Get all available vouchers
router.get('/', (req, res) => {
  const db = getDatabase();
  const { status = 'available' } = req.query;
  
  db.all(
    `SELECT v.*, u.name as donor_name, u.email as donor_email,
            c.name as claimer_name, c.email as claimer_email
     FROM vouchers v
     JOIN users u ON v.donor_id = u.id
     LEFT JOIN users c ON v.claimer_id = c.id
     WHERE v.status = ?
     ORDER BY v.created_at DESC`,
    [status],
    (err, vouchers) => {
      if (err) {
        return res.status(500).json({ error: 'Failed to fetch vouchers' });
      }
      res.json(vouchers);
    }
  );
});

// Claim voucher
router.post('/:id/claim', authenticateToken, (req, res) => {
  const db = getDatabase();
  const voucherId = req.params.id;

  // Check if voucher is available
  db.get('SELECT * FROM vouchers WHERE id = ? AND status = "available"', [voucherId], (err, voucher) => {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }
    if (!voucher) {
      return res.status(404).json({ error: 'Voucher not available' });
    }
    if (voucher.donor_id === req.user.id) {
      return res.status(400).json({ error: 'Cannot claim your own voucher' });
    }

    // Update voucher status
    db.run(
      'UPDATE vouchers SET status = "claimed", claimer_id = ? WHERE id = ?',
      [req.user.id, voucherId],
      function(err) {
        if (err) {
          return res.status(500).json({ error: 'Failed to claim voucher' });
        }

        // Fetch updated voucher
        db.get(
          `SELECT v.*, u.name as donor_name, u.email as donor_email
           FROM vouchers v
           JOIN users u ON v.donor_id = u.id
           WHERE v.id = ?`,
          [voucherId],
          (err, updatedVoucher) => {
            if (err) {
              return res.status(500).json({ error: 'Failed to fetch updated voucher' });
            }
            res.json(updatedVoucher);
          }
        );
      }
    );
  });
});

module.exports = router;