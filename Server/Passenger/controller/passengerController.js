const Passenger = require('../model/Passenger');
const analyticsService = require('../services/analyticsService');
const realTimeTrackingService = require('../services/realTimeTrackingService');
const notificationService = require('../services/notificationService');

class PassengerController {
  // Get passenger dashboard
  static async getDashboard(req, res) {
    try {
      const passenger = req.passenger;
      
      console.log(`📊 Getting dashboard for passenger: ${passenger.citizenId}`);

      const dashboardData = await analyticsService.getPassengerDashboard(passenger.citizenId);

      res.json({
        success: true,
        data: dashboardData
      });

    } catch (error) {
      console.error('Get dashboard error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get dashboard data',
        error: error.message
      });
    }
  }

  // Get travel history
  static async getTravelHistory(req, res) {
    try {
      const passenger = req.passenger;
      const { page, limit, startDate, endDate, routeId } = req.query;

      console.log(`📚 Getting travel history for passenger: ${passenger.citizenId}`);

      const historyData = await analyticsService.getTravelHistory(passenger.citizenId, {
        page: parseInt(page) || 1,
        limit: parseInt(limit) || 20,
        startDate,
        endDate,
        routeId
      });

      res.json({
        success: true,
        data: historyData
      });

    } catch (error) {
      console.error('Get travel history error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get travel history',
        error: error.message
      });
    }
  }

  // Update passenger preferences
  static async updatePreferences(req, res) {
    try {
      const passenger = req.passenger;
      const { preferences } = req.body;

      console.log(`⚙️ Updating preferences for passenger: ${passenger.citizenId}`);

      // Validate preference structure
      const allowedPreferences = {
        notifications: ['email', 'sms', 'push'],
        paymentMethod: ['cash', 'card', 'digital_wallet', 'bank_transfer'],
        language: ['en', 'si', 'ta']
      };

      const updatedPreferences = { ...passenger.preferences };

      if (preferences.notifications) {
        updatedPreferences.notifications = {
          ...updatedPreferences.notifications,
          ...preferences.notifications
        };
      }

      if (preferences.paymentMethod && allowedPreferences.paymentMethod.includes(preferences.paymentMethod)) {
        updatedPreferences.paymentMethod = preferences.paymentMethod;
      }

      if (preferences.language && allowedPreferences.language.includes(preferences.language)) {
        updatedPreferences.language = preferences.language;
      }

      if (preferences.favoriteRoutes) {
        updatedPreferences.favoriteRoutes = preferences.favoriteRoutes;
      }

      passenger.preferences = updatedPreferences;
      await passenger.save();

      res.json({
        success: true,
        message: 'Preferences updated successfully',
        data: {
          preferences: passenger.preferences
        }
      });

    } catch (error) {
      console.error('Update preferences error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update preferences',
        error: error.message
      });
    }
  }

  // Get favorite routes
  static async getFavoriteRoutes(req, res) {
    try {
      const passenger = req.passenger;

      const favoriteRoutes = passenger.preferences?.favoriteRoutes || [];

      // Enhance with current schedule data
      const enhancedFavorites = await Promise.all(
        favoriteRoutes.map(async (favorite) => {
          try {
            const apiGateway = require('../config/apiGateway');
            
            // Get active schedules for this route
            const schedulesResponse = await apiGateway.getSchedulesFromNDX({
              routeId: favorite.routeId,
              status: 'active,scheduled',
              limit: 3
            });

            const activeSchedules = schedulesResponse.success ? schedulesResponse.data : [];

            return {
              ...favorite,
              activeSchedules: activeSchedules.map(schedule => ({
                scheduleId: schedule._id,
                departureTime: schedule.departureTime,
                status: schedule.status,
                availableSeats: schedule.capacity - (schedule.currentPassengers || 0)
              }))
            };

          } catch (error) {
            console.warn(`Error fetching schedules for route ${favorite.routeId}:`, error.message);
            return {
              ...favorite,
              activeSchedules: []
            };
          }
        })
      );

      res.json({
        success: true,
        data: {
          favoriteRoutes: enhancedFavorites,
          total: enhancedFavorites.length
        }
      });

    } catch (error) {
      console.error('Get favorite routes error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get favorite routes',
        error: error.message
      });
    }
  }

  // Add route to favorites
  static async addToFavorites(req, res) {
    try {
      const passenger = req.passenger;
      const { routeId, routeName } = req.body;

      if (!routeId || !routeName) {
        return res.status(400).json({
          success: false,
          message: 'Route ID and name are required'
        });
      }

      const favoriteData = {
        routeId,
        routeName,
        addedAt: new Date()
      };

      await passenger.addToFavorites(favoriteData);

      res.json({
        success: true,
        message: 'Route added to favorites',
        data: {
          favoriteRoutes: passenger.preferences.favoriteRoutes
        }
      });

    } catch (error) {
      console.error('Add to favorites error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to add route to favorites',
        error: error.message
      });
    }
  }

  // Remove route from favorites
  static async removeFromFavorites(req, res) {
    try {
      const passenger = req.passenger;
      const { routeId } = req.params;

      await passenger.removeFromFavorites(routeId);

      res.json({
        success: true,
        message: 'Route removed from favorites',
        data: {
          favoriteRoutes: passenger.preferences.favoriteRoutes
        }
      });

    } catch (error) {
      console.error('Remove from favorites error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to remove route from favorites',
        error: error.message
      });
    }
  }

  // Subscribe to real-time tracking
  static async subscribeToTracking(req, res) {
    try {
      const passenger = req.passenger;
      const { scheduleId } = req.body;

      if (!scheduleId) {
        return res.status(400).json({
          success: false,
          message: 'Schedule ID is required'
        });
      }

      realTimeTrackingService.subscribeToRoute(passenger.citizenId, scheduleId);

      // Get current status
      const status = await realTimeTrackingService.getScheduleStatus(scheduleId);

      res.json({
        success: true,
        message: 'Subscribed to real-time tracking',
        data: {
          scheduleId,
          ...status.data
        }
      });

    } catch (error) {
      console.error('Subscribe to tracking error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to subscribe to tracking',
        error: error.message
      });
    }
  }

  // Unsubscribe from real-time tracking
  static async unsubscribeFromTracking(req, res) {
    try {
      const passenger = req.passenger;
      const { scheduleId } = req.params;

      realTimeTrackingService.unsubscribeFromRoute(passenger.citizenId, scheduleId);

      res.json({
        success: true,
        message: 'Unsubscribed from real-time tracking',
        data: {
          scheduleId
        }
      });

    } catch (error) {
      console.error('Unsubscribe from tracking error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to unsubscribe from tracking',
        error: error.message
      });
    }
  }

  // Get real-time schedule status
  static async getScheduleStatus(req, res) {
    try {
      const { scheduleId } = req.params;

      const status = await realTimeTrackingService.getScheduleStatus(scheduleId);

      if (status.success) {
        res.json({
          success: true,
          data: status.data
        });
      } else {
        res.status(404).json({
          success: false,
          message: status.message
        });
      }

    } catch (error) {
      console.error('Get schedule status error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get schedule status',
        error: error.message
      });
    }
  }

  // Calculate ETA to passenger location
  static async calculateETA(req, res) {
    try {
      const { scheduleId } = req.params;
      const { lat, lng } = req.query;

      if (!lat || !lng) {
        return res.status(400).json({
          success: false,
          message: 'Passenger location (lat, lng) is required'
        });
      }

      const eta = await realTimeTrackingService.calculateETA(scheduleId, {
        lat: parseFloat(lat),
        lng: parseFloat(lng)
      });

      if (eta) {
        res.json({
          success: true,
          data: {
            scheduleId,
            passengerLocation: { lat: parseFloat(lat), lng: parseFloat(lng) },
            ...eta
          }
        });
      } else {
        res.status(404).json({
          success: false,
          message: 'Unable to calculate ETA - schedule not found or not active'
        });
      }

    } catch (error) {
      console.error('Calculate ETA error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to calculate ETA',
        error: error.message
      });
    }
  }
}

module.exports = PassengerController;