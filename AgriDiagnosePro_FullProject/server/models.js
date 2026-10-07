// server/models.js
const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name: String,
  email: { type: String, unique: true },
  passwordHash: String,
  role: { type: String, default: 'user' }
});

const DiagnosisSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  imageURL: String,
  latitude: Number,
  longitude: Number,
  timestamp: Date,
  disease: String,
  confidence: Number
});

const User = mongoose.models.User || mongoose.model('User', UserSchema);
const Diagnosis = mongoose.models.Diagnosis || mongoose.model('Diagnosis', DiagnosisSchema);

module.exports = { User, Diagnosis };
