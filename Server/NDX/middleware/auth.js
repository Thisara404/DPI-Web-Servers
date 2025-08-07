const jwt = require('jsonwebtoken');
const axios = require('axios');

// Verify JWT Token (validates with SLUDI server)
const verifyToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
      return res.status(401).json({
        success: false,
        message: 'Access token required'
      });
    }

    const token = authHeader.startsWith('Bearer ') 
      ? authHeader.substring(7) 
      : authHeader;

    // For now, just verify locally (since no auth required per your requirement)
    // In production, you would verify with SLUDI server
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.citizen = { citizenId: decoded.citizenId || 'anonymous' };
      next();
    } catch (error) {
      // For development without auth, allow anonymous access
      req.citizen = { citizenId: 'anonymous' };
      next();
    }

  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Invalid or expired token'
    });
  }
};

// Role-based authorization
const authorize = (roles = []) => {
  return (req, res, next) => {
    // For development, skip role check
    next();
  };
};

module.exports = {
  verifyToken,
  authorize
};