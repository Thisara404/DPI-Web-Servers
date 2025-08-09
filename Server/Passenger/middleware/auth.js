const jwt = require('jsonwebtoken');
const Passenger = require('../models/Passenger');
const apiGateway = require('../config/apiGateway');

// Verify JWT token and authenticate passenger
const verifyToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
      return res.status(401).json({
        success: false,
        message: 'No token provided'
      });
    }

    const token = authHeader.startsWith('Bearer ') 
      ? authHeader.substring(7) 
      : authHeader;

    // Verify token with SLUDI through API Gateway
    try {
      const sludiResponse = await apiGateway.authenticateWithSLUDI(token);
      
      if (sludiResponse.success && sludiResponse.data.citizen) {
        const citizenData = sludiResponse.data.citizen;
        
        // Find or create passenger record
        let passenger = await Passenger.findOne({ citizenId: citizenData.citizenId });
        
        if (!passenger) {
          // Create passenger record from SLUDI data
          passenger = new Passenger({
            citizenId: citizenData.citizenId,
            firstName: citizenData.firstName,
            lastName: citizenData.lastName,
            email: citizenData.email,
            phone: citizenData.phoneNumber || '',
            dateOfBirth: citizenData.dateOfBirth ? new Date(citizenData.dateOfBirth) : null,
            address: citizenData.address || {},
            isVerified: citizenData.isVerified || false
          });
          await passenger.save();
          console.log(`✅ Created new passenger record for citizen: ${citizenData.citizenId}`);
        }
        
        req.passenger = passenger;
        req.token = token;
        next();
      } else {
        return res.status(401).json({
          success: false,
          message: 'Invalid token or citizen data'
        });
      }
    } catch (sludiError) {
      console.error('SLUDI authentication error:', sludiError.message);
      return res.status(401).json({
        success: false,
        message: 'Authentication failed with SLUDI'
      });
    }
  } catch (error) {
    console.error('Token verification error:', error);
    return res.status(500).json({
      success: false,
      message: 'Authentication service error'
    });
  }
};

// Check if passenger account is active
const requireActiveAccount = (req, res, next) => {
  if (req.passenger.status !== 'active') {
    return res.status(403).json({
      success: false,
      message: 'Account is not active. Please contact support.'
    });
  }
  next();
};

// Check if passenger is verified
const requireVerification = (req, res, next) => {
  if (!req.passenger.isVerified) {
    return res.status(403).json({
      success: false,
      message: 'Account verification required'
    });
  }
  next();
};

module.exports = {
  verifyToken,
  requireActiveAccount,
  requireVerification
};