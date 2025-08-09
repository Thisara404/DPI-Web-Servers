const jwt = require('jsonwebtoken');
const Passenger = require('../model/Passenger');
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

    // First try to decode the token locally
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      // Handle temporary tokens (for unverified passengers)
      if (decoded.type === 'temp_access') {
        const passenger = await Passenger.findById(decoded.passengerId);
        
        if (!passenger) {
          return res.status(401).json({
            success: false,
            message: 'Passenger not found'
          });
        }

        req.passenger = passenger;
        req.token = token;
        req.tokenType = 'temporary';
        return next();
      }
    } catch (jwtError) {
      // If local JWT verification fails, try SLUDI
    }

    // For verified passengers, verify with SLUDI through API Gateway
    try {
      const sludiResponse = await apiGateway.authenticateWithSLUDI(token);
      
      if (sludiResponse.success && sludiResponse.data.citizen) {
        const citizenData = sludiResponse.data.citizen;
        
        // Find passenger record
        let passenger = await Passenger.findOne({ citizenId: citizenData.citizenId });
        
        if (!passenger) {
          return res.status(401).json({
            success: false,
            message: 'Passenger record not found'
          });
        }
        
        req.passenger = passenger;
        req.token = token;
        req.tokenType = 'sludi';
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
        message: 'Authentication failed'
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

// Check if passenger account is active (modified to allow pending verification)
const requireActiveAccount = (req, res, next) => {
  if (req.passenger.status === 'suspended') {
    return res.status(403).json({
      success: false,
      message: 'Account is suspended. Please contact support.'
    });
  }
  next();
};

// Check if passenger is verified (for features requiring verification)
const requireVerification = (req, res, next) => {
  if (!req.passenger.isVerified) {
    return res.status(403).json({
      success: false,
      message: 'Account verification required. Please verify your Citizen ID.',
      requiresCitizenVerification: true
    });
  }
  next();
};

module.exports = {
  verifyToken,
  requireActiveAccount,
  requireVerification
};