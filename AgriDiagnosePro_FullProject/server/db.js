// server/db.js
const mongoose = require('mongoose');
const dotenv = require('dotenv');
dotenv.config();

const MONGO = process.env.MONGODB_URI || '';

async function connect() {
  if (!MONGO) {
    console.log('MONGODB_URI not provided — running in demo mode (no persistent DB).');
    return;
  }
  try {
    await mongoose.connect(MONGO, { useNewUrlParser: true, useUnifiedTopology: true });
    console.log('Connected to MongoDB');
  } catch (err) {
    console.error('MongoDB connection error', err);
  }
}

module.exports = { connect };
