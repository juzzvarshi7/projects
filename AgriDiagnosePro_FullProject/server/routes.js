// server/routes.js
const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const axios = require('axios');

const { User, Diagnosis } = require('./models');

const upload = multer({ dest: path.join(__dirname, 'uploads/') });

const JWT_SECRET = process.env.JWT_SECRET || 'devsecret';

function authMiddleware(req, res, next) {
  const h = req.headers.authorization;
  if (!h) return res.status(401).json({ error: 'No token' });
  const token = h.split(' ')[1];
  try {
    const payload = jwt.verify(token, JWT_SECRET);
    req.user = payload;
    next();
  } catch (e) {
    res.status(401).json({ error: 'Invalid token' });
  }
}

// Auth
router.post('/api/auth/register', async (req, res) => {
  const { name, email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'email & password required' });
  const existing = await User.findOne({ email }).exec().catch(()=>null);
  if (existing) return res.status(400).json({ error: 'User exists' });
  const hash = await bcrypt.hash(password, 10);
  const u = new User({ name, email, passwordHash: hash });
  await u.save();
  const token = jwt.sign({ id: u._id, email: u.email, role: u.role }, JWT_SECRET);
  res.json({ token });
});

router.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  const u = await User.findOne({ email }).exec().catch(()=>null);
  if (!u) return res.status(400).json({ error: 'Invalid credentials' });
  const ok = await bcrypt.compare(password, u.passwordHash);
  if (!ok) return res.status(400).json({ error: 'Invalid credentials' });
  const token = jwt.sign({ id: u._id, email: u.email, role: u.role }, JWT_SECRET);
  res.json({ token });
});

// Diagnosis upload
router.post('/api/diagnosis', upload.single('image'), async (req, res) => {
  try {
    const { latitude, longitude, timestamp } = req.body;
    // For demo: read file and send to ML service
    const file = req.file;
    if (!file) return res.status(400).json({ error: 'Image required' });

    const filePath = path.resolve(file.path);
    const b64 = fs.readFileSync(filePath, { encoding: 'base64' });

    // Call local ML service
    const ML_URL = process.env.ML_URL || 'http://localhost:8000/ml/predict';
    const resp = await axios.post(ML_URL, { image: b64 }, { timeout: 10000 }).catch(err => ({ data: { class: 'unknown', confidence: 0 } }));
    const result = resp.data || { class: 'unknown', confidence: 0 };

    // Save image to uploads (or ideally upload to Firebase if configured)
    const publicURL = `/uploads/${path.basename(filePath)}`;

    const record = new Diagnosis({
      userId: null,
      imageURL: publicURL,
      latitude: latitude ? parseFloat(latitude) : null,
      longitude: longitude ? parseFloat(longitude) : null,
      timestamp: timestamp ? new Date(timestamp) : new Date(),
      disease: result.class,
      confidence: result.confidence
    });

    await record.save().catch(()=>{});

    res.json({ success: true, result, record });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

router.get('/api/diagnosis/history', async (req, res) => {
  const items = await Diagnosis.find().sort({ timestamp: -1 }).limit(50).exec().catch(()=>[]);
  res.json({ items });
});

router.get('/api/admin/summary', async (req, res) => {
  // Simple aggregation demo
  const agg = await Diagnosis.aggregate([
    { $group: { _id: '$disease', count: { $sum: 1 } } },
    { $sort: { count: -1 } }
  ]).catch(()=>[]);
  res.json({ diseases: agg });
});

module.exports = router;
