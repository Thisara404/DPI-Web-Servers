class ApiConstants {
  // Base URLs
  static const String baseUrl = 'http://localhost:4002/api';
  static const String socketUrl = 'http://localhost:4002';
  
  // Timeouts
  static const Duration timeoutDuration = Duration(seconds: 30);
  static const Duration socketTimeout = Duration(seconds: 5);
  
  // Authentication Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String profileEndpoint = '/auth/profile';
  
  // Schedule Endpoints
  static const String schedulesEndpoint = '/schedules';
  static const String activeSchedulesEndpoint = '/schedules/active';
  static const String searchSchedulesEndpoint = '/schedules/search';
  
  // Booking Endpoints
  static const String bookingsEndpoint = '/bookings';
  static const String paymentEndpoint = '/payment';
  
  // Ticket Endpoints
  static const String ticketsEndpoint = '/tickets';
  static const String activeTicketsEndpoint = '/tickets/active';
  static const String qrCodeEndpoint = '/qr';
  static const String validateTicketEndpoint = '/tickets/validate';
  
  // Map Endpoints
  static const String mapRoutesEndpoint = '/map/routes';
  static const String liveBusesEndpoint = '/map/buses/live';
  static const String nearbyStopsEndpoint = '/map/stops/nearby';
  static const String directionsEndpoint = '/map/directions';
  
  // Passenger Endpoints
  static const String dashboardEndpoint = '/passenger/dashboard';
  static const String historyEndpoint = '/passenger/history';
  static const String favoritesEndpoint = '/passenger/favorites';
  static const String trackingSubscribeEndpoint = '/passenger/tracking/subscribe';
  static const String trackingStatusEndpoint = '/passenger/tracking';
  static const String etaEndpoint = '/eta';
  
  // Socket Events
  static const String busLocationUpdateEvent = 'busLocationUpdate';
  static const String etaUpdateEvent = 'etaUpdate';
  static const String scheduleUpdateEvent = 'scheduleUpdate';
  static const String routeDisruptionEvent = 'routeDisruption';
  static const String systemAnnouncementEvent = 'systemAnnouncement';
}

class AppConstants {
  // App Information
  static const String appName = 'Transit Lanka Passenger';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_completed';
  static const String preferencesKey = 'user_preferences';
  
  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int citizenIdLength = 12;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  
  // Map Constants
  static const double defaultZoom = 15.0;
  static const double minZoom = 10.0;
  static const double maxZoom = 20.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Refresh Intervals
  static const Duration scheduleRefreshInterval = Duration(minutes: 5);
  static const Duration busLocationRefreshInterval = Duration(seconds: 10);
  static const Duration etaRefreshInterval = Duration(seconds: 30);
}

class ErrorMessages {
  // Authentication Errors
  static const String invalidCredentials = 'Invalid email or password';
  static const String accountNotFound = 'Account not found';
  static const String emailAlreadyExists = 'Email already registered';
  static const String tokenExpired = 'Session expired. Please login again';
  static const String unauthorized = 'Unauthorized access';
  
  // Validation Errors
  static const String invalidEmail = 'Please enter a valid email address';
  static const String passwordTooShort = 'Password must be at least 8 characters';
  static const String nameRequired = 'Name is required';
  static const String phoneRequired = 'Phone number is required';
  static const String citizenIdRequired = 'Citizen ID is required';
  static const String invalidCitizenId = 'Invalid citizen ID format';
  
  // Network Errors
  static const String noInternetConnection = 'No internet connection';
  static const String serverError = 'Server error. Please try again later';
  static const String timeoutError = 'Request timeout. Please try again';
  static const String unknownError = 'An unexpected error occurred';
  
  // Feature Errors
  static const String locationPermissionDenied = 'Location permission denied';
  static const String gpsDisabled = 'Please enable GPS';
  static const String noSchedulesFound = 'No schedules found';
  static const String bookingFailed = 'Booking failed. Please try again';
  static const String paymentFailed = 'Payment failed';
  static const String ticketNotFound = 'Ticket not found';
}

class SuccessMessages {
  static const String loginSuccess = 'Login successful';
  static const String registrationSuccess = 'Registration successful';
  static const String profileUpdated = 'Profile updated successfully';
  static const String bookingSuccess = 'Booking confirmed successfully';
  static const String paymentSuccess = 'Payment processed successfully';
  static const String ticketValidated = 'Ticket validated successfully';
  static const String favoriteAdded = 'Added to favorites';
  static const String favoriteRemoved = 'Removed from favorites';
}

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  refunded,
}

enum TicketStatus {
  active,
  used,
  expired,
  cancelled,
}

enum JourneyStatus {
  scheduled,
  boarding,
  inTransit,
  completed,
  cancelled,
  delayed,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
}