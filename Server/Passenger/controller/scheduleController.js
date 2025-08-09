const apiGateway = require("../config/apiGateway");
const Passenger = require("../model/Passenger");

class ScheduleController {
  // Get all schedules from NDX
  static async getAllSchedules(req, res) {
    try {
      const { status, routeId, date, limit = 50, page = 1 } = req.query;

      // Build query parameters for NDX
      const params = {};
      if (status) params.status = status;
      if (routeId) params.routeId = routeId;
      if (date) params.date = date;
      params.limit = limit;
      params.page = page;

      console.log("📅 Fetching schedules from NDX...", params);

      // Fetch schedules from NDX through API Gateway
      const schedulesResponse = await apiGateway.getSchedulesFromNDX(params);

      if (schedulesResponse.success) {
        // Enhance schedules with passenger-specific data
        const enhancedSchedules = await Promise.all(
          schedulesResponse.data.map(async (schedule) => {
            // Calculate estimated fare based on route distance
            const estimatedFare = schedule.routeId?.distance
              ? Math.round(
                  schedule.routeId.distance *
                    (schedule.routeId.costPerKm || 2.5)
                )
              : 50; // Default fare

            // Check if passenger has this route in favorites
            const isFavorite =
              req.passenger?.preferences?.favoriteRoutes?.some(
                (fav) => fav.routeId === schedule.routeId?._id?.toString()
              ) || false;

            return {
              ...schedule,
              estimatedFare,
              isFavorite,
              availableSeats:
                schedule.capacity - (schedule.currentPassengers || 0),
              departureIn: schedule.departureTime
                ? Math.max(
                    0,
                    Math.floor(
                      (new Date(schedule.departureTime) - new Date()) / 60000
                    )
                  )
                : null, // Minutes until departure
            };
          })
        );

        res.json({
          success: true,
          data: enhancedSchedules,
          total: schedulesResponse.total || enhancedSchedules.length,
          pagination: {
            page: parseInt(page),
            limit: parseInt(limit),
            total: schedulesResponse.total || enhancedSchedules.length,
          },
        });
      } else {
        res.status(400).json({
          success: false,
          message: "Failed to fetch schedules from NDX",
          error: schedulesResponse.message,
        });
      }
    } catch (error) {
      console.error("Get schedules error:", error);
      res.status(500).json({
        success: false,
        message: "Failed to get schedules",
        error: error.message,
      });
    }
  }

  // Get active schedules only
  static async getActiveSchedules(req, res) {
    try {
      const { routeId, limit = 20 } = req.query;

      const params = {
        status: "active,scheduled",
        limit,
        sortBy: "departureTime",
        sortOrder: "asc",
      };
      if (routeId) params.routeId = routeId;

      console.log("🟢 Fetching active schedules from NDX...");

      const schedulesResponse = await apiGateway.getSchedulesFromNDX(params);

      if (schedulesResponse.success) {
        // Filter schedules that are departing soon or currently active
        const activeSchedules = schedulesResponse.data.filter((schedule) => {
          const departureTime = new Date(schedule.departureTime);
          const now = new Date();
          const timeDiff = departureTime - now;

          // Include schedules departing in next 2 hours or currently active
          return (
            schedule.status === "active" ||
            (schedule.status === "scheduled" &&
              timeDiff > 0 &&
              timeDiff <= 2 * 60 * 60 * 1000)
          );
        });

        // Enhance with real-time data
        const enhancedSchedules = activeSchedules.map((schedule) => ({
          ...schedule,
          isLive: schedule.status === "active",
          departureIn: Math.max(
            0,
            Math.floor((new Date(schedule.departureTime) - new Date()) / 60000)
          ),
          estimatedFare: schedule.routeId?.distance
            ? Math.round(
                schedule.routeId.distance * (schedule.routeId.costPerKm || 2.5)
              )
            : 50,
          availableSeats: schedule.capacity - (schedule.currentPassengers || 0),
        }));

        res.json({
          success: true,
          data: enhancedSchedules,
          total: enhancedSchedules.length,
          message: `Found ${enhancedSchedules.length} active schedules`,
        });
      } else {
        res.status(400).json({
          success: false,
          message: "Failed to fetch active schedules",
          error: schedulesResponse.message,
        });
      }
    } catch (error) {
      console.error("Get active schedules error:", error);
      res.status(500).json({
        success: false,
        message: "Failed to get active schedules",
        error: error.message,
      });
    }
  }

  // Get specific schedule details with route information
  static async getScheduleDetails(req, res) {
    try {
      const { id } = req.params;

      console.log(`📋 Fetching schedule details for: ${id}`);

      // Fetch schedule details from NDX
      const scheduleResponse = await apiGateway.getSchedulesFromNDX({
        scheduleId: id,
      });

      if (scheduleResponse.success && scheduleResponse.data.length > 0) {
        const schedule = scheduleResponse.data[0];

        // Get route details if available
        let routeDetails = null;
        if (schedule.routeId) {
          try {
            const routeResponse = await apiGateway.getRoutesFromNDX({
              routeId: schedule.routeId._id || schedule.routeId,
            });
            if (routeResponse.success) {
              routeDetails = routeResponse.data[0];
            }
          } catch (routeError) {
            console.warn("Could not fetch route details:", routeError.message);
          }
        }

        // Enhanced schedule with additional passenger-relevant information
        const enhancedSchedule = {
          ...schedule,
          routeDetails,
          estimatedFare: routeDetails?.distance
            ? Math.round(
                routeDetails.distance * (routeDetails.costPerKm || 2.5)
              )
            : 50,
          availableSeats: schedule.capacity - (schedule.currentPassengers || 0),
          departureIn: schedule.departureTime
            ? Math.max(
                0,
                Math.floor(
                  (new Date(schedule.departureTime) - new Date()) / 60000
                )
              )
            : null,
          canBook:
            schedule.status === "scheduled" &&
            schedule.capacity - (schedule.currentPassengers || 0) > 0,
          isLive: schedule.status === "active",
          hasLiveTracking:
            schedule.status === "active" && schedule.currentLocation,
        };

        res.json({
          success: true,
          data: enhancedSchedule,
        });
      } else {
        res.status(404).json({
          success: false,
          message: "Schedule not found",
        });
      }
    } catch (error) {
      console.error("Get schedule details error:", error);
      res.status(500).json({
        success: false,
        message: "Failed to get schedule details",
        error: error.message,
      });
    }
  }

  // Search schedules by criteria
  static async searchSchedules(req, res) {
    try {
      const {
        from,
        to,
        date,
        time,
        maxFare,
        routeName,
        limit = 20,
        page = 1,
      } = req.query;

      console.log("🔍 Searching schedules with criteria:", req.query);

      // Build search parameters
      const searchParams = { limit, page };

      if (date) searchParams.date = date;
      if (time) searchParams.time = time;
      if (routeName) searchParams.routeName = routeName;

      // If from/to coordinates are provided, find relevant routes first
      if (from && to) {
        try {
          const routesResponse = await apiGateway.getRoutesFromNDX({
            from,
            to,
            action: "find-routes",
          });

          if (
            routesResponse.success &&
            routesResponse.data.routes?.length > 0
          ) {
            const routeIds = routesResponse.data.routes.map((r) => r.route._id);
            searchParams.routeIds = routeIds.join(",");
          }
        } catch (routeError) {
          console.warn("Route search failed:", routeError.message);
        }
      }

      // Fetch schedules with search criteria
      const schedulesResponse = await apiGateway.getSchedulesFromNDX(
        searchParams
      );

      if (schedulesResponse.success) {
        let schedules = schedulesResponse.data;

        // Apply fare filter if provided
        if (maxFare) {
          schedules = schedules.filter((schedule) => {
            const fare = schedule.routeId?.distance
              ? Math.round(
                  schedule.routeId.distance *
                    (schedule.routeId.costPerKm || 2.5)
                )
              : 50;
            return fare <= parseFloat(maxFare);
          });
        }

        // Enhance schedules
        const enhancedSchedules = schedules.map((schedule) => ({
          ...schedule,
          estimatedFare: schedule.routeId?.distance
            ? Math.round(
                schedule.routeId.distance * (schedule.routeId.costPerKm || 2.5)
              )
            : 50,
          availableSeats: schedule.capacity - (schedule.currentPassengers || 0),
          departureIn: schedule.departureTime
            ? Math.max(
                0,
                Math.floor(
                  (new Date(schedule.departureTime) - new Date()) / 60000
                )
              )
            : null,
          matchRelevance: 100, // Could implement relevance scoring later
        }));

        // Sort by departure time
        enhancedSchedules.sort(
          (a, b) => new Date(a.departureTime) - new Date(b.departureTime)
        );

        res.json({
          success: true,
          data: enhancedSchedules,
          total: enhancedSchedules.length,
          searchCriteria: {
            from,
            to,
            date,
            time,
            maxFare,
            routeName,
          },
          message: `Found ${enhancedSchedules.length} matching schedules`,
        });
      } else {
        res.status(400).json({
          success: false,
          message: "Schedule search failed",
          error: schedulesResponse.message,
        });
      }
    } catch (error) {
      console.error("Search schedules error:", error);
      res.status(500).json({
        success: false,
        message: "Failed to search schedules",
        error: error.message,
      });
    }
  }

  // Get route path for a specific schedule
  static async getScheduleRoute(req, res) {
    try {
      const { id } = req.params;

      console.log(`🗺️ Fetching route path for schedule: ${id}`);

      // Get schedule details first
      const scheduleResponse = await apiGateway.getSchedulesFromNDX({
        scheduleId: id,
      });

      if (!scheduleResponse.success || scheduleResponse.data.length === 0) {
        return res.status(404).json({
          success: false,
          message: "Schedule not found",
        });
      }

      const schedule = scheduleResponse.data[0];
      const routeId = schedule.routeId?._id || schedule.routeId;

      if (!routeId) {
        return res.status(400).json({
          success: false,
          message: "No route associated with this schedule",
        });
      }

      // Get detailed route information
      const routeResponse = await apiGateway.getRoutesFromNDX({
        routeId,
        includeStops: true,
        includePath: true,
      });

      if (routeResponse.success) {
        const routeData = routeResponse.data[0];

        res.json({
          success: true,
          data: {
            schedule: {
              id: schedule._id,
              status: schedule.status,
              departureTime: schedule.departureTime,
              arrivalTime: schedule.arrivalTime,
              currentLocation: schedule.currentLocation,
              vehicleNumber: schedule.vehicleNumber,
            },
            route: {
              id: routeData._id,
              name: routeData.name,
              description: routeData.description,
              distance: routeData.distance,
              estimatedDuration: routeData.estimatedDuration,
              stops: routeData.stops,
              path: routeData.path,
              costPerKm: routeData.costPerKm,
            },
            realTimeData: {
              isLive: schedule.status === "active",
              hasTracking: !!(
                schedule.currentLocation && schedule.status === "active"
              ),
              lastLocationUpdate: schedule.lastLocationUpdate,
            },
          },
        });
      } else {
        res.status(404).json({
          success: false,
          message: "Route details not found",
        });
      }
    } catch (error) {
      console.error("Get schedule route error:", error);
      res.status(500).json({
        success: false,
        message: "Failed to get schedule route",
        error: error.message,
      });
    }
  }
}

module.exports = ScheduleController;
