const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');
const { getDatabase } = require('../database/init');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif|webp/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Only image files are allowed (jpeg, jpg, png, gif, webp)'));
    }
  }
});

// Create donation item
router.post('/', authenticateToken, upload.single('photo'), (req, res) => {
  try {
    const { name, description, category, condition, quantity, expiry_date, location } = req.body;
    
    // Validate required fields
    if (!name || !description || !category || !condition || !location) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const db = getDatabase();
    const itemId = uuidv4();
    
    const photoUrl = req.file ? `/uploads/${req.file.filename}` : null;

    db.run(
      `INSERT INTO items (id, name, description, category, condition, quantity, expiry_date, photo_url, location, donor_id) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [itemId, name, description, category, condition, parseInt(quantity) || 1, expiry_date || null, photoUrl, location, req.user.id],
      function(err) {
        if (err) {
          console.error('Error creating item:', err);
          return res.status(500).json({ error: 'Failed to create item' });
        }
        
        // Fetch the created item with donor information
        db.get(
          `SELECT i.*, u.name as donor_name, u.email as donor_email 
           FROM items i 
           JOIN users u ON i.donor_id = u.id 
           WHERE i.id = ?`,
          [itemId],
          (err, item) => {
            if (err) {
              console.error('Error fetching created item:', err);
              return res.status(500).json({ error: 'Failed to fetch created item' });
            }
            
            console.log('Item created successfully:', name);
            res.status(201).json(item);
          }
        );
      }
    );
  } catch (error) {
    console.error('Error in item creation:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get all available items
router.get('/', (req, res) => {
  const db = getDatabase();
  const { category, condition, search, status = 'available' } = req.query;
  
  let query = `
    SELECT i.*, u.name as donor_name, u.email as donor_email 
    FROM items i 
    JOIN users u ON i.donor_id = u.id 
    WHERE i.status = ?
  `;
  const params = [status];

  if (category && category !== '') {
    query += ' AND i.category = ?';
    params.push(category);
  }

  if (condition && condition !== '') {
    query += ' AND i.condition = ?';
    params.push(condition);
  }

  if (search && search !== '') {
    query += ' AND (i.name LIKE ? OR i.description LIKE ?)';
    params.push(`%${search}%`, `%${search}%`);
  }

  query += ' ORDER BY i.created_at DESC';

  db.all(query, params, (err, items) => {
    if (err) {
      console.error('Error fetching items:', err);
      return res.status(500).json({ error: 'Failed to fetch items' });
    }
    
    console.log(`Fetched ${items.length} items`);
    res.json(items);
  });
});

// Get single item
router.get('/:id', (req, res) => {
  const db = getDatabase();
  
  db.get(
    `SELECT i.*, u.name as donor_name, u.email as donor_email 
     FROM items i 
     JOIN users u ON i.donor_id = u.id 
     WHERE i.id = ?`,
    [req.params.id],
    (err, item) => {
      if (err) {
        console.error('Error fetching item:', err);
        return res.status(500).json({ error: 'Database error' });
      }
      if (!item) {
        return res.status(404).json({ error: 'Item not found' });
      }
      res.json(item);
    }
  );
});

// Claim an item
router.post('/:id/claim', authenticateToken, (req, res) => {
  const db = getDatabase();
  const itemId = req.params.id;
  const claimId = uuidv4();
  const claimCode = Math.random().toString(36).substring(2, 8).toUpperCase();

  // Check if item is available
  db.get('SELECT * FROM items WHERE id = ? AND status = "available"', [itemId], (err, item) => {
    if (err) {
      console.error('Error checking item:', err);
      return res.status(500).json({ error: 'Database error' });
    }
    if (!item) {
      return res.status(404).json({ error: 'Item not available' });
    }
    if (item.donor_id === req.user.id) {
      return res.status(400).json({ error: 'Cannot claim your own item' });
    }

    // Create claim
    db.run(
      'INSERT INTO claims (id, item_id, claimer_id, claim_code) VALUES (?, ?, ?, ?)',
      [claimId, itemId, req.user.id, claimCode],
      function(err) {
        if (err) {
          console.error('Error creating claim:', err);
          return res.status(500).json({ error: 'Failed to create claim' });
        }

        // Update item status
        db.run('UPDATE items SET status = "claimed" WHERE id = ?', [itemId], (err) => {
          if (err) {
            console.error('Error updating item status:', err);
            return res.status(500).json({ error: 'Failed to update item status' });
          }

          console.log('Item claimed successfully:', claimCode);
          res.status(201).json({
            id: claimId,
            item_id: itemId,
            claimer_id: req.user.id,
            claim_code: claimCode,
            status: 'pending',
            created_at: new Date().toISOString(),
            item
          });
        });
      }
    );
  });
});

module.exports = router;