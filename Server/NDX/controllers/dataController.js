const Route = require('../models/Route');
const Journey = require('../models/Journey');
const { geocodeAddress, getRouteDetails } = require('../utils/mapsUtils');
const { calculateDistance } = require('../utils/gpsUtils');

class DataController {
  // Search locations using geocoding
  static async searchLocations(req, res) {
    try {
      const { query } = req.query;
      
      if (!query) {
        return res.status(400).json({
          success: false,
          message: 'Search query is required'
        });
      }

      const locationData = await geocodeAddress(query);
      
      res.json({
        success: true,
        data: locationData
      });

    } catch (error) {
      console.error('Location search error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to search locations',
        error: error.message
      });
    }
  }

  // Find routes between two locations
  static async findRoutes(req, res) {
    try {
      const { from, to } = req.query;
      
      if (!from || !to) {
        return res.status(400).json({
          success: false,
          message: 'From and to coordinates are required'
        });
      }

      // Parse coordinates
      const fromCoords = from.split(',').map(Number);
      const toCoords = to.split(',').map(Number);

      // Find routes that pass near these coordinates
      const routes = await Route.find({
        $and: [
          {
            'stops.location': {
              $near: {
                $geometry: {
                  type: 'Point',
                  coordinates: fromCoords
                },
                $maxDistance: 5000 // 5km radius
              }
            }
          },
          {
            'stops.location': {
              $near: {
                $geometry: {
                  type: 'Point',
                  coordinates: toCoords
                },
                $maxDistance: 5000 // 5km radius
              }
            }
          }
        ]
      }).populate('schedules');

      // Calculate route details for each found route
      const routeDetails = await Promise.all(
        routes.map(async (route) => {
          const details = await getRouteDetails(fromCoords, toCoords);
          return {
            route,
            distance: details.distance,
            duration: details.duration,
            distanceText: details.distanceText,
            durationText: details.durationText
          };
        })
      );

      res.json({
        success: true,
        data: routeDetails
      });

    } catch (error) {
      console.error('Route search error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to find routes',
        error: error.message
      });
    }
  }

  // Get nearby stops
  static async getNearbyStops(req, res) {
    try {
      const { lat, lng, radius = 1000 } = req.query;
      
      if (!lat || !lng) {
        return res.status(400).json({
          success: false,
          message: 'Latitude and longitude are required'
        });
      }

      const coordinates = [parseFloat(lng), parseFloat(lat)];
      
      const routes = await Route.find({
        'stops.location': {
          $near: {
            $geometry: {
              type: 'Point',
              coordinates: coordinates
            },
            $maxDistance: parseInt(radius)
          }
        }
      });

      // Extract nearby stops
      const nearbyStops = [];
      routes.forEach(route => {
        route.stops.forEach(stop => {
          const distance = calculateDistance(coordinates, stop.location.coordinates);
          if (distance <= radius) {
            nearbyStops.push({
              routeId: route._id,
              routeName: route.name,
              stop: stop,
              distance: Math.round(distance)
            });
          }
        });
      });

      res.json({
        success: true,
        data: nearbyStops
      });

    } catch (error) {
      console.error('Nearby stops error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get nearby stops',
        error: error.message
      });
    }
  }

  // Get route details
  static async getRouteDetails(req, res) {
    try {
      const { routeId } = req.params;
      
      const route = await Route.findById(routeId).populate('schedules');
      
      if (!route) {
        return res.status(404).json({
          success: false,
          message: 'Route not found'
        });
      }

      res.json({
        success: true,
        data: route
      });

    } catch (error) {
      console.error('Get route details error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get route details',
        error: error.message
      });
    }
  }

  // Get journey history for a passenger
  static async getJourneyHistory(req, res) {
    try {
      const citizenId = req.citizen.citizenId;
      
      const journeys = await Journey.find({ 
        passengerId: citizenId 
      }).sort({ createdAt: -1 }).limit(50);

      res.json({
        success: true,
        data: journeys
      });

    } catch (error) {
      console.error('Journey history error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get journey history',
        error: error.message
      });
    }
  }
}

module.exports = DataController;