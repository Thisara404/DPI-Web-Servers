const apiGateway = require('../config/apiGateway');
const Passenger = require('../models/Passenger');

class AuthController {
  // Register new passenger through SLUDI
  static async register(req, res) {
    try {
      const {
        firstName,
        lastName,
        email,
        phoneNumber,
        password,
        dateOfBirth,
        address
      } = req.body;

      console.log('📝 Registering passenger through SLUDI...');

      // Register with SLUDI first
      const sludiResponse = await apiGateway.registerWithSLUDI({
        firstName,
        lastName,
        email,
        phoneNumber,
        password,
        dateOfBirth,
        address
      });

      if (sludiResponse.success && sludiResponse.data.citizen) {
        const citizenData = sludiResponse.data.citizen;
        
        // Create passenger record
        const passenger = new Passenger({
          citizenId: citizenData.citizenId,
          firstName: citizenData.firstName,
          lastName: citizenData.lastName,
          email: citizenData.email,
          phone: citizenData.phoneNumber || phoneNumber,
          dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : null,
          address: address || {},
          isVerified: citizenData.isVerified || false
        });

        await passenger.save();

        res.status(201).json({
          success: true,
          message: 'Passenger registered successfully',
          data: {
            passenger: {
              id: passenger._id,
              citizenId: passenger.citizenId,
              firstName: passenger.firstName,
              lastName: passenger.lastName,
              email: passenger.email,
              phone: passenger.phone,
              isVerified: passenger.isVerified,
              status: passenger.status
            },
            tokens: sludiResponse.data.tokens
          }
        });

        console.log(`✅ Passenger registered: ${passenger.citizenId}`);
      } else {
        return res.status(400).json({
          success: false,
          message: sludiResponse.message || 'Registration failed with SLUDI'
        });
      }
    } catch (error) {
      console.error('Registration error:', error);
      res.status(500).json({
        success: false,
        message: 'Registration failed',
        error: error.message
      });
    }
  }

  // Login passenger through SLUDI
  static async login(req, res) {
    try {
      const { email, password } = req.body;

      console.log(`🔐 Logging in passenger: ${email}`);

      // Login with SLUDI
      const sludiResponse = await apiGateway.loginWithSLUDI({
        email,
        password
      });

      if (sludiResponse.success && sludiResponse.data.citizen) {
        const citizenData = sludiResponse.data.citizen;
        
        // Find or create passenger record
        let passenger = await Passenger.findOne({ citizenId: citizenData.citizenId });
        
        if (!passenger) {
          // Create passenger record if not exists
          passenger = new Passenger({
            citizenId: citizenData.citizenId,
            firstName: citizenData.firstName,
            lastName: citizenData.lastName,
            email: citizenData.email,
            phone: citizenData.phoneNumber || '',
            isVerified: citizenData.isVerified || false
          });
          await passenger.save();
        }

        // Update last login
        await passenger.updateLastLogin();

        res.json({
          success: true,
          message: 'Login successful',
          data: {
            passenger: {
              id: passenger._id,
              citizenId: passenger.citizenId,
              firstName: passenger.firstName,
              lastName: passenger.lastName,
              email: passenger.email,
              phone: passenger.phone,
              isVerified: passenger.isVerified,
              status: passenger.status,
              preferences: passenger.preferences,
              totalJourneys: passenger.totalJourneys
            },
            tokens: sludiResponse.data.tokens
          }
        });

        console.log(`✅ Passenger logged in: ${passenger.citizenId}`);
      } else {
        return res.status(401).json({
          success: false,
          message: sludiResponse.message || 'Invalid credentials'
        });
      }
    } catch (error) {
      console.error('Login error:', error);
      res.status(500).json({
        success: false,
        message: 'Login failed',
        error: error.message
      });
    }
  }

  // Get passenger profile
  static async getProfile(req, res) {
    try {
      const passenger = req.passenger;

      res.json({
        success: true,
        data: {
          passenger: {
            id: passenger._id,
            citizenId: passenger.citizenId,
            firstName: passenger.firstName,
            lastName: passenger.lastName,
            fullName: passenger.fullName,
            email: passenger.email,
            phone: passenger.phone,
            dateOfBirth: passenger.dateOfBirth,
            address: passenger.address,
            preferences: passenger.preferences,
            status: passenger.status,
            isVerified: passenger.isVerified,
            totalJourneys: passenger.totalJourneys,
            totalSpent: passenger.totalSpent,
            lastLogin: passenger.lastLogin,
            createdAt: passenger.createdAt
          }
        }
      });
    } catch (error) {
      console.error('Get profile error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get profile',
        error: error.message
      });
    }
  }

  // Update passenger profile
  static async updateProfile(req, res) {
    try {
      const passenger = req.passenger;
      const updates = req.body;

      // Only allow certain fields to be updated
      const allowedUpdates = ['firstName', 'lastName', 'phone', 'address', 'preferences'];
      const actualUpdates = {};

      Object.keys(updates).forEach(key => {
        if (allowedUpdates.includes(key)) {
          actualUpdates[key] = updates[key];
        }
      });

      if (Object.keys(actualUpdates).length === 0) {
        return res.status(400).json({
          success: false,
          message: 'No valid updates provided'
        });
      }

      Object.assign(passenger, actualUpdates);
      await passenger.save();

      res.json({
        success: true,
        message: 'Profile updated successfully',
        data: {
          passenger: {
            id: passenger._id,
            citizenId: passenger.citizenId,
            firstName: passenger.firstName,
            lastName: passenger.lastName,
            fullName: passenger.fullName,
            email: passenger.email,
            phone: passenger.phone,
            address: passenger.address,
            preferences: passenger.preferences
          }
        }
      });
    } catch (error) {
      console.error('Update profile error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update profile',
        error: error.message
      });
    }
  }
}

module.exports = AuthController;