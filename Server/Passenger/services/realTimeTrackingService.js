const socketService = require('./socketService');
const notificationService = require('./notificationService');
const apiGateway = require('../config/apiGateway');

class RealTimeTrackingService {
  constructor() {
    this.activeTracking = new Map(); // scheduleId -> tracking data
    this.passengerSubscriptions = new Map(); // passengerId -> Set of scheduleIds
    this.arrivalNotifications = new Map(); // passengerId -> Set of scheduleIds for sent notifications
    this.updateInterval = null;
  }

  // Start real-time tracking service
  start() {
    this.updateInterval = setInterval(async () => {
      await this.updateAllTrackingData();
    }, 10000); // Update every 10 seconds

    console.log('🔄 Real-time tracking service started');
  }

  // Stop real-time tracking service
  stop() {
    if (this.updateInterval) {
      clearInterval(this.updateInterval);
      this.updateInterval = null;
    }
    console.log('⏹️ Real-time tracking service stopped');
  }

  // Subscribe passenger to route tracking
  subscribeToRoute(passengerId, scheduleId) {
    if (!this.passengerSubscriptions.has(passengerId)) {
      this.passengerSubscriptions.set(passengerId, new Set());
    }
    
    this.passengerSubscriptions.get(passengerId).add(scheduleId);
    
    console.log(`📍 Passenger ${passengerId} subscribed to schedule ${scheduleId}`);
    
    // Send current tracking data if available
    const trackingData = this.activeTracking.get(scheduleId);
    if (trackingData) {
      socketService.io.to(`passenger-${passengerId}`).emit('location-update', {
        scheduleId,
        ...trackingData,
        timestamp: new Date().toISOString()
      });
    }
  }

  // Unsubscribe passenger from route tracking
  unsubscribeFromRoute(passengerId, scheduleId) {
    if (this.passengerSubscriptions.has(passengerId)) {
      this.passengerSubscriptions.get(passengerId).delete(scheduleId);
      
      if (this.passengerSubscriptions.get(passengerId).size === 0) {
        this.passengerSubscriptions.delete(passengerId);
      }
    }

    console.log(`❌ Passenger ${passengerId} unsubscribed from schedule ${scheduleId}`);
  }

  // Update all active tracking data
  async updateAllTrackingData() {
    try {
      // Get all schedules that have active subscriptions
      const activeScheduleIds = new Set();
      
      for (const scheduleIds of this.passengerSubscriptions.values()) {
        for (const scheduleId of scheduleIds) {
          activeScheduleIds.add(scheduleId);
        }
      }

      if (activeScheduleIds.size === 0) return;

      // Fetch latest data for all active schedules
      for (const scheduleId of activeScheduleIds) {
        await this.updateScheduleTracking(scheduleId);
      }

    } catch (error) {
      console.error('Update tracking data error:', error);
    }
  }

  // Update tracking for specific schedule
  async updateScheduleTracking(scheduleId) {
    try {
      // Get schedule data from NDX
      const scheduleResponse = await apiGateway.getSchedulesFromNDX({ scheduleId });
      
      if (!scheduleResponse.success || scheduleResponse.data.length === 0) {
        return;
      }

      const schedule = scheduleResponse.data[0];
      
      if (schedule.status !== 'active' || !schedule.currentLocation) {
        return;
      }

      const trackingData = {
        vehicleNumber: schedule.vehicleNumber,
        driverName: schedule.driverName,
        position: {
          lat: schedule.currentLocation.coordinates[1],
          lng: schedule.currentLocation.coordinates[0]
        },
        heading: schedule.heading || 0,
        speed: schedule.speed || 0,
        lastUpdate: schedule.lastLocationUpdate,
        status: schedule.status,
        estimatedArrival: schedule.estimatedArrival,
        nextStop: schedule.nextStop,
        passengersOnBoard: schedule.currentPassengers || 0,
        capacity: schedule.capacity || 50
      };

      // Update tracking data
      this.activeTracking.set(scheduleId, trackingData);

      // Broadcast to subscribed passengers
      await this.broadcastTrackingUpdate(scheduleId, trackingData);

      // Check for arrival notifications
      await this.checkArrivalNotifications(scheduleId, trackingData);

    } catch (error) {
      console.error('Schedule tracking update error:', error);
    }
  }

  // Broadcast tracking update to subscribers
  async broadcastTrackingUpdate(scheduleId, trackingData) {
    try {
      const updateData = {
        scheduleId,
        ...trackingData,
        timestamp: new Date().toISOString()
      };

      // Send to all subscribed passengers
      for (const [passengerId, scheduleIds] of this.passengerSubscriptions.entries()) {
        if (scheduleIds.has(scheduleId)) {
          socketService.io.to(`passenger-${passengerId}`).emit('location-update', updateData);
        }
      }

      // Also broadcast to route subscribers
      socketService.io.to(`schedule-${scheduleId}`).emit('schedule-location-update', updateData);

    } catch (error) {
      console.error('Broadcast tracking update error:', error);
    }
  }

  // Check and send arrival notifications
  async checkArrivalNotifications(scheduleId, trackingData) {
    try {
      if (!trackingData.nextStop || !trackingData.estimatedArrival) {
        return;
      }

      const arrivalMinutes = parseInt(trackingData.estimatedArrival);
      
      // Send notification when bus is 5 minutes away
      if (arrivalMinutes <= 5 && arrivalMinutes > 0) {
        for (const [passengerId, scheduleIds] of this.passengerSubscriptions.entries()) {
          if (scheduleIds.has(scheduleId)) {
            // Check if notification already sent
            const notificationKey = `${passengerId}-${scheduleId}`;
            if (!this.arrivalNotifications.has(notificationKey)) {
              await this.sendArrivalNotification(passengerId, scheduleId, trackingData);
              this.arrivalNotifications.set(notificationKey, Date.now());
            }
          }
        }
      }

      // Clean up old notification flags (older than 30 minutes)
      const thirtyMinutesAgo = Date.now() - (30 * 60 * 1000);
      for (const [key, timestamp] of this.arrivalNotifications.entries()) {
        if (timestamp < thirtyMinutesAgo) {
          this.arrivalNotifications.delete(key);
        }
      }

    } catch (error) {
      console.error('Arrival notification check error:', error);
    }
  }

  // Send arrival notification to passenger
  async sendArrivalNotification(passengerId, scheduleId, trackingData) {
    try {
      const Passenger = require('../models/Passenger');
      const passenger = await Passenger.findOne({ citizenId: passengerId });
      
      if (!passenger) return;

      const notificationData = {
        scheduleId,
        routeName: trackingData.routeName || 'Your Bus',
        vehicleNumber: trackingData.vehicleNumber,
        arrivalTime: trackingData.estimatedArrival,
        stopName: trackingData.nextStop?.name || 'Your Stop'
      };

      await notificationService.sendBusArrivalNotification(passenger, notificationData);

    } catch (error) {
      console.error('Send arrival notification error:', error);
    }
  }

  // Get real-time status for schedule
  async getScheduleStatus(scheduleId) {
    try {
      const trackingData = this.activeTracking.get(scheduleId);
      
      if (trackingData) {
        return {
          success: true,
          data: {
            scheduleId,
            ...trackingData,
            isLive: true
          }
        };
      }

      // If not in memory, fetch from NDX
      const scheduleResponse = await apiGateway.getSchedulesFromNDX({ scheduleId });
      
      if (scheduleResponse.success && scheduleResponse.data.length > 0) {
        const schedule = scheduleResponse.data[0];
        
        return {
          success: true,
          data: {
            scheduleId,
            vehicleNumber: schedule.vehicleNumber,
            status: schedule.status,
            position: schedule.currentLocation ? {
              lat: schedule.currentLocation.coordinates[1],
              lng: schedule.currentLocation.coordinates[0]
            } : null,
            lastUpdate: schedule.lastLocationUpdate,
            isLive: schedule.status === 'active' && !!schedule.currentLocation
          }
        };
      }

      return {
        success: false,
        message: 'Schedule not found'
      };

    } catch (error) {
      console.error('Get schedule status error:', error);
      return {
        success: false,
        message: 'Failed to get schedule status'
      };
    }
  }

  // Calculate ETA for passenger location
  async calculateETA(scheduleId, passengerLocation) {
    try {
      const trackingData = this.activeTracking.get(scheduleId);
      
      if (!trackingData || !trackingData.position) {
        return null;
      }

      // Simple distance calculation (in production, use actual routing)
      const distance = this.calculateDistance(
        trackingData.position.lat,
        trackingData.position.lng,
        passengerLocation.lat,
        passengerLocation.lng
      );

      // Estimate time based on average bus speed (30 km/h in city)
      const avgSpeed = 30; // km/h
      const etaMinutes = Math.round((distance / avgSpeed) * 60);

      return {
        distanceKm: Math.round(distance * 10) / 10,
        etaMinutes,
        lastUpdate: new Date().toISOString()
      };

    } catch (error) {
      console.error('Calculate ETA error:', error);
      return null;
    }
  }

  // Calculate distance between two points (Haversine formula)
  calculateDistance(lat1, lng1, lat2, lng2) {
    const R = 6371; // Earth radius in km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLng = (lng2 - lng1) * Math.PI / 180;
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLng / 2) * Math.sin(dLng / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  // Get tracking statistics
  getTrackingStats() {
    return {
      activeSchedules: this.activeTracking.size,
      subscribedPassengers: this.passengerSubscriptions.size,
      totalSubscriptions: Array.from(this.passengerSubscriptions.values())
        .reduce((sum, scheduleIds) => sum + scheduleIds.size, 0),
      lastUpdate: new Date().toISOString()
    };
  }
}

module.exports = new RealTimeTrackingService();