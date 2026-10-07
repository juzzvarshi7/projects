const express = require('express');
const cors = require('cors');
const path = require('path');
const authRoutes = require('./routes/auth');
const itemRoutes = require('./routes/items');
const claimRoutes = require('./routes/claims');
const moneyBoxRoutes = require('./routes/moneyBox');
const voucherRoutes = require('./routes/vouchers');
const { initializeDatabase } = require('./database/init');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors({
  origin: ['http://localhost:5173', 'http://localhost:3000'],
  credentials: true
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Serve uploaded files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Initialize database and start server
async function startServer() {
  try {
    await initializeDatabase();
    console.log('Database initialized successfully');
    
    // Routes
    app.use('/api/auth', authRoutes);
    app.use('/api/items', itemRoutes);
    app.use('/api/claims', claimRoutes);
    app.use('/api/money-box', moneyBoxRoutes);
    app.use('/api/vouchers', voucherRoutes);

    // Health check
    app.get('/api/health', (req, res) => {
      res.json({ 
        status: 'OK', 
        timestamp: new Date().toISOString(),
        message: 'Student Donation Platform API is running'
      });
    });

    // Error handling middleware
    app.use((err, req, res, next) => {
      console.error('Error:', err);
      res.status(500).json({ 
        error: 'Internal server error',
        message: err.message 
      });
    });

    // 404 handler
    app.use('*', (req, res) => {
      res.status(404).json({ 
        error: 'Route not found',
        path: req.originalUrl 
      });
    });

    app.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
      console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
      console.log(`👤 Admin login: admin@college.edu / admin123`);
    });
    
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

startServer();

module.exports = app;