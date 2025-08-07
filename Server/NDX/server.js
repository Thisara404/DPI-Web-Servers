const express = require('express');
const cors = require('cors');
require('dotenv').config();

const connectDB = require('./config/database');
const routeRoutes = require('./routes/route.routes');
const journeyRoutes = require('./routes/journey.routes');
const scheduleRoutes = require('./routes/schedule.routes');

const app = express();
const PORT = process.env.PORT || 3002;

// Connect to database
connectDB();

// Middleware
app.use(cors({
  origin: ['http://localhost:3000', 'http://localhost:8080', 'http://localhost:3001'],
  credentials: true
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'NDX Server is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Public API Routes (No authentication required for basic functionality)
app.use('/api/routes', routeRoutes);
app.use('/api/journeys', journeyRoutes);
app.use('/api/schedules', scheduleRoutes);

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

app.listen(PORT, () => {
  console.log(`🚀 NDX Server running on port ${PORT}`);
  console.log(`📍 Health check: http://localhost:${PORT}/health`);
  console.log(`🛣️  Routes API: http://localhost:${PORT}/api/routes`);
  console.log(`🚌 Journey API: http://localhost:${PORT}/api/journeys`);
  console.log(`📅 Schedule API: http://localhost:${PORT}/api/schedules`);
});

module.exports = app;