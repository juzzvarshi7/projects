const express = require('express');
const { getDatabase } = require('../database/init');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get user's claims
router.get('/', authenticateToken, (req, res) => {
  const db = getDatabase();
  
  db.all(
    `SELECT c.*, i.name as item_name, i.description, i.photo_url, i.location,
            u.name as donor_name, u.email as donor_email
     FROM claims c
     JOIN items i ON c.item_id = i.id
     JOIN users u ON i.donor_id = u.id
     WHERE c.claimer_id = ?
     ORDER BY c.created_at DESC`,
    [req.user.id],
    (err, claims) => {
      if (err) {
        return res.status(500).json({ error: 'Failed to fetch claims' });
      }
      res.json(claims);
    }
  );
});

// Get claims for user's donated items
router.get('/donations', authenticateToken, (req, res) => {
  const db = getDatabase();
  
  db.all(
    `SELECT c.*, i.name as item_name, i.description, i.photo_url, i.location,
            u.name as claimer_name, u.email as claimer_email
     FROM claims c
     JOIN items i ON c.item_id = i.id
     JOIN users u ON c.claimer_id = u.id
     WHERE i.donor_id = ?
     ORDER BY c.created_at DESC`,
    [req.user.id],
    (err, claims) => {
      if (err) {
        return res.status(500).json({ error: 'Failed to fetch donation claims' });
      }
      res.json(claims);
    }
  );
});

// Confirm pickup
router.post('/:id/confirm', authenticateToken, (req, res) => {
  const db = getDatabase();
  const claimId = req.params.id;

  // Get claim details
  db.get(
    `SELECT c.*, i.donor_id FROM claims c 
     JOIN items i ON c.item_id = i.id 
     WHERE c.id = ?`,
    [claimId],
    (err, claim) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      if (!claim) {
        return res.status(404).json({ error: 'Claim not found' });
      }
      
      // Only the donor can confirm pickup
      if (claim.donor_id !== req.user.id) {
        return res.status(403).json({ error: 'Only the donor can confirm pickup' });
      }

      // Update claim status
      db.run(
        'UPDATE claims SET status = "confirmed" WHERE id = ?',
        [claimId],
        function(err) {
          if (err) {
            return res.status(500).json({ error: 'Failed to confirm claim' });
          }

          // Update item status
          db.run(
            'UPDATE items SET status = "completed" WHERE id = ?',
            [claim.item_id],
            (err) => {
              if (err) {
                return res.status(500).json({ error: 'Failed to update item status' });
              }
              
              res.json({ message: 'Pickup confirmed successfully' });
            }
          );
        }
      );
    }
  );
});

module.exports = router;