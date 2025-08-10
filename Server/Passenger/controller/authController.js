const apiGateway = require('../config/apiGateway');
// Fix: Change from '../models/Passenger' to '../model/Passenger'
const Passenger = require('../model/Passenger');

class AuthController {
  // Register new passenger directly (without SLUDI initially)
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

      console.log(`📝 Registering new passenger: ${email}`);

      // Check if passenger already exists
      const existingPassenger = await Passenger.findOne({
        $or: [{ email }, { phone: phoneNumber }]
      });

      if (existingPassenger) {
        return res.status(400).json({
          success: false,
          message: 'Passenger with this email or phone number already exists'
        });
      }

      // Generate temporary passenger ID (until SLUDI validation)
      const tempPassengerId = `TEMP_${Date.now()}_${Math.floor(Math.random() * 1000)}`;

      // Create passenger record directly
      const passenger = new Passenger({
        citizenId: tempPassengerId, // Temporary until SLUDI validation
        firstName,
        lastName,
        email,
        phone: phoneNumber,
        dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : null,
        address: address || {},
        isVerified: false, // Will be true after SLUDI validation
        status: 'pending_verification', // Status until SLUDI validation
        // Store password temporarily for SLUDI registration later
        tempPassword: password,
        registrationMethod: 'direct'
      });

      await passenger.save();

      // Generate a simple JWT token for temporary access
      const jwt = require('jsonwebtoken');
      const tempToken = jwt.sign(
        {
          passengerId: passenger._id,
          citizenId: tempPassengerId,
          email: passenger.email,
          type: 'temp_access'
        },
        process.env.JWT_SECRET,
        { expiresIn: '7d' }
      );

      res.status(201).json({
        success: true,
        message: 'Passenger registered successfully. Please verify with your Citizen ID to complete registration.',
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
            requiresCitizenVerification: true
          },
          tokens: {
            accessToken: tempToken,
            tokenType: 'temporary',
            expiresIn: '7d'
          }
        }
      });

      console.log(`✅ Passenger registered (pending verification): ${passenger.email}`);
    } catch (error) {
      console.error('Registration error:', error);
      res.status(500).json({
        success: false,
        message: 'Registration failed',
        error: error.message
      });
    }
  }

  // Verify passenger with SLUDI using Citizen ID
  static async verifyCitizenId(req, res) {
    try {
      const passenger = req.passenger;
      const { citizenId, password } = req.body;

      if (!citizenId || !password) {
        return res.status(400).json({
          success: false,
          message: 'Citizen ID and password are required'
        });
      }

      console.log(`🔍 Verifying citizen ID: ${citizenId} for passenger: ${passenger.email}`);

      // Register/Login with SLUDI using citizen credentials
      const sludiResponse = await apiGateway.loginWithSLUDI({
        email: passenger.email,
        password: password
      });

      if (sludiResponse.success && sludiResponse.data.citizen) {
        const citizenData = sludiResponse.data.citizen;

        // Verify the citizen ID matches
        if (citizenData.citizenId !== citizenId) {
          return res.status(400).json({
            success: false,
            message: 'Citizen ID does not match the provided credentials'
          });
        }

        // Update passenger with verified citizen data
        passenger.citizenId = citizenData.citizenId;
        passenger.isVerified = true;
        passenger.status = 'active';
        passenger.tempPassword = undefined; // Remove temporary password
        passenger.lastLogin = new Date();

        await passenger.save();

        res.json({
          success: true,
          message: 'Citizen ID verified successfully',
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

        console.log(`✅ Passenger verified with SLUDI: ${passenger.citizenId}`);
      } else {
        return res.status(401).json({
          success: false,
          message: 'Invalid citizen credentials'
        });
      }
    } catch (error) {
      console.error('Citizen verification error:', error);
      res.status(500).json({
        success: false,
        message: 'Citizen verification failed',
        error: error.message
      });
    }
  }

  // Login passenger (works for both verified and unverified)
  static async login(req, res) {
    try {
      const { email, password } = req.body;

      console.log(`🔐 Logging in passenger: ${email}`);

      // Find passenger by email
      const passenger = await Passenger.findOne({ email });

      if (!passenger) {
        return res.status(401).json({
          success: false,
          message: 'Invalid email or password'
        });
      }

      // If passenger is verified, use SLUDI login
      if (passenger.isVerified && passenger.citizenId && !passenger.citizenId.startsWith('TEMP_')) {
        const sludiResponse = await apiGateway.loginWithSLUDI({
          email,
          password
        });

        if (sludiResponse.success && sludiResponse.data.citizen) {
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
        } else {
          return res.status(401).json({
            success: false,
            message: 'Invalid credentials'
          });
        }
      } else {
        // For unverified passengers, use temporary password
        if (passenger.tempPassword === password) {
          const jwt = require('jsonwebtoken');
          const tempToken = jwt.sign(
            {
              passengerId: passenger._id,
              citizenId: passenger.citizenId,
              email: passenger.email,
              type: 'temp_access'
            },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
          );

          res.json({
            success: true,
            message: 'Login successful. Please verify your Citizen ID to access full features.',
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
                requiresCitizenVerification: true
              },
              tokens: {
                accessToken: tempToken,
                tokenType: 'temporary',
                expiresIn: '7d'
              }
            }
          });
        } else {
          return res.status(401).json({
            success: false,
            message: 'Invalid credentials'
          });
        }
      }

      console.log(`✅ Passenger logged in: ${passenger.email}`);
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
            createdAt: passenger.createdAt,
            requiresCitizenVerification: !passenger.isVerified
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