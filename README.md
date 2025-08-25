# 🚀 Digital Public Infrastructure (DPI) - ReviveNation Hackathon

A comprehensive transportation management system built with Node.js microservices and Flutter mobile applications, designed for Sri Lanka's digital public infrastructure.

## 📋 Project Overview

This project implements a complete digital public infrastructure ecosystem consisting of:

### Backend Services (Node.js)
- **SLUDI** (Port 3001) - Sri Lanka Unified Digital Identity & Authentication
- **NDX** (Port 3002) - National Data Exchange for Routes & Journeys  
- **PayDPI** (Port 3003) - Payment Digital Public Infrastructure
- **Driver API** (Port 4001) - Driver Management & Tracking
- **Passenger API** (Port 4002) - Passenger Services & Mobile App Backend
- **API Gateway** (Port 5000) - Central routing and load balancing

### Mobile Applications (Flutter)
- **Driver App** - Schedule management, journey tracking, live GPS tracking
- **Passenger App** - Route planning, booking, real-time tracking (⚠️ *In Development*)

## 🏗️ System Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Driver App    │    │ Passenger App   │
│   (Flutter)     │    │   (Flutter)     │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          └──────────┬───────────┘
                     │
        ┌────────────▼────────────┐
        │     API Gateway         │
        │      (Port 5000)        │
        └──┬──┬──┬──┬──┬─────────┘
           │  │  │  │  │
    ┌──────▼─┐│  │  │  └─────┐
    │ SLUDI  ││  │  │        │
    │ :3001  ││  │  │        │
    └────────┘│  │  │        │
     ┌────────▼─┐│  │        │
     │   NDX    ││  │        │
     │  :3002   ││  │        │
     └──────────┘│  │        │
      ┌──────────▼─┐│        │
      │  PayDPI    ││        │
      │   :3003    ││        │
      └────────────┘│        │
       ┌─────────────▼───┐    │
       │   Driver API    │    │
       │     :4001       │    │
       └─────────────────┘    │
        ┌─────────────────────▼┐
        │   Passenger API      │
        │      :4002           │
        └──────────────────────┘
```

## 🚀 Quick Start Guide

### Prerequisites

- **Node.js** (v16 or higher)
- **MongoDB** (running locally or connection string)
- **Flutter SDK** (3.0.0 or higher) 
- **Google Maps API Key**
- **Stripe Account** (for payments)

### 📱 Environment Setup

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd "3 DPI Servers"
   ```

2. **Install root dependencies**
   ```bash
   npm install
   ```

### 🗄️ Database Setup

Ensure MongoDB is running locally or have connection strings ready for:
- `sludi` database
- `ndx` database  
- `paydpi` database
- `driver` database
- `passenger` database

## ⚙️ Server Configuration

### 1. SLUDI Server (Authentication & Identity)

```bash
cd Server/SLUDI
cp .env.example .env
```

Edit `.env`:
```env
PORT=3001
MONGODB_URI=mongodb://localhost:27017/sludi
JWT_SECRET=your_super_secret_jwt_key_here
NODE_ENV=development
```

```bash
npm install
npm start
```

**Health Check**: http://localhost:3001/health

### 2. NDX Server (Routes & Data Exchange)

```bash
cd Server/NDX
cp .env.example .env
```

Edit `.env`:
```env
PORT=3002
MONGODB_URI=mongodb://localhost:27017/ndx
JWT_SECRET=your_super_secret_jwt_key_here  # MUST match SLUDI
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
NODE_ENV=development
```

```bash
npm install
npm start
```

**Health Check**: http://localhost:3002/health

### 3. PayDPI Server (Payment Infrastructure)

```bash
cd Server/PayDPI
cp .env.example .env
```

Edit `.env`:
```env
PORT=3003
MONGODB_URI=mongodb://localhost:27017/paydpi
JWT_SECRET=your_super_secret_jwt_key_here  # MUST match SLUDI
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret
NODE_ENV=development
```

```bash
npm install
npm start
```

**Health Check**: http://localhost:3003/health

### 4. Driver API Server

```bash
cd Server/Driver
cp .env.example .env
```

Edit `.env`:
```env
PORT=4001
MONGODB_URI=mongodb://localhost:27017/driver
JWT_SECRET=your_super_secret_jwt_key_here  # MUST match SLUDI
NODE_ENV=development
SLUDI_SERVER_URL=http://localhost:3001
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

```bash
npm install
npm start
```

**Health Check**: http://localhost:4001/health

### 5. Passenger API Server

```bash
cd Server/Passenger
cp .env.example .env
```

Edit `.env`:
```env
PORT=4002
MONGODB_URI=mongodb://localhost:27017/passenger
JWT_SECRET=your_super_secret_jwt_key_here  # MUST match SLUDI
NODE_ENV=development
API_GATEWAY_URL=http://localhost:5000
SLUDI_URL=http://localhost:3001
NDX_URL=http://localhost:3002
PAYDPI_URL=http://localhost:3003
```

```bash
npm install
npm start
```

**Health Check**: http://localhost:4002/health

### 6. API Gateway (Central Router)

```bash
cd Server
cp .env.example .env
```

Edit `.env`:
```env
PORT=5000
NODE_ENV=development
```

```bash
npm install
npm start
```

**Health Check**: http://localhost:5000/health/all
**API Documentation**: http://localhost:5000/api/docs

## 🧪 Server Testing & Proof of Concept

### Automated Health Checks

```bash
# Start all servers simultaneously
npm run start:all
```

### Manual Testing with Postman

1. **Import Collections**:
   - [`SLUDI_Auth_Testing_Collection.postman_collection.json`](Server/API%20Documentation/SLUDI_Auth_Testing_Collection.postman_collection.json)
   - [`PayDPI_Postman_Collection.json`](Server/API%20Documentation/PayDPI_Postman_Collection.json)

2. **Import Environment**:
   - [`SLUDI_Auth_Environment.postman_environment.json`](Server/API%20Documentation/SLUDI_Auth_Environment.postman_environment.json)

3. **Follow Testing Guides**:
   - [SLUDI Testing Guide](Server/API%20Documentation/SLUDI_Testing_Guide.md)
   - [PayDPI Testing Guide](Server/API%20Documentation/PayDPI_Testing_Guide.md)
   - [Complete DPI Testing Guide](Server/API%20Documentation/DPI_Complete_Testing_Guide.md)

### 📸 System Demonstration

#### PayDPI Health Check - Payment Infrastructure Running
![PayDPI Health Check](PayDPI%20health.png)
*PayDPI server successfully running with database connectivity and Stripe configuration*

#### NDX Location Search - Route Discovery
![NDX Location Search](NDX%20location%20search.png)
*NDX service demonstrating location search functionality for "Colombo" with GPS coordinates*

#### SLUDI Authentication - User Management
![SLUDI Login](SLUDI.png)
*SLUDI authentication system with successful login and JWT token generation*

#### SLUDI User Profile - Digital Identity
![SLUDI Profile](SLUDI%20Profile.png)
*Complete user profile management with Sri Lankan citizen ID integration*

#### Database Collections - Data Persistence

**NDX Database - Journey Management**
![NDX Database](ndx%20DB.png)
*Journey bookings with passenger details, route information, and payment status*

**PayDPI Database - Subsidy Management**  
![PayDPI Database](paydpi%20DB.png)
*Student subsidy applications with eligibility verification and usage tracking*

**SLUDI Database - Citizen Registry**
![SLUDI Database](sludi%20DB.png)
*Digital citizen profiles with verification status and role-based access*

### Health Check All Services

```bash
curl http://localhost:3001/health  # SLUDI
curl http://localhost:3002/health  # NDX
curl http://localhost:3003/health  # PayDPI
curl http://localhost:4001/health  # Driver API
curl http://localhost:4002/health  # Passenger API
curl http://localhost:5000/health/all  # Gateway
```

## 📱 Flutter Mobile Applications

### Driver App (✅ Ready for Testing)

```bash
cd Client/driver
```

1. **Configure Environment**
   ```bash
   cp example.env .env
   ```
   
   Edit `.env`:
   ```env
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   ```

2. **Update API Endpoints**
   
   Edit [`lib/config/api.endpoints.dart`](Client/driver/lib/config/api.endpoints.dart):
   ```dart
   class ApiEndpoints {
     static const String baseUrl = 'http://localhost:5000'; // API Gateway
     // ... other endpoints
   }
   ```

3. **Install Dependencies & Run**
   ```bash
   flutter pub get
   flutter run
   ```

**Features Available**:
- ✅ Driver Authentication (Login/Register)
- ✅ Schedule Management 
- ✅ Journey Tracking with GPS
- ✅ Google Maps Integration
- ✅ Real-time Location Updates

### Passenger App (⚠️ In Development)

```bash
cd Client/passenger
```

**Current Status**:
- ✅ UI Structure Complete
- ✅ State Management Setup (Provider)
- ✅ API Service Layer Ready
- ⚠️ **Server Integration Incomplete**
- ⚠️ **API Endpoints Not Fully Connected**

```bash
flutter pub get
flutter run
```

**Planned Features**:
- 🔄 Passenger Registration/Login
- 🔄 Route Search & Planning
- 🔄 Real-time Bus Tracking
- 🔄 Booking & Payment Integration
- 🔄 QR Code Ticket Generation
- 🔄 Journey History

## 🔧 API Endpoints

### Authentication (SLUDI - Port 3001)
```
POST /api/auth/register - Register new user
POST /api/auth/login - User login
GET /api/auth/profile - Get user profile
PUT /api/auth/profile - Update profile
POST /api/auth/refresh-token - Refresh token
```

### Routes & Journeys (NDX - Port 3002)
```
GET /api/routes/search-locations - Search locations
GET /api/routes/find-routes - Find routes between points
GET /api/routes/nearby-stops - Find nearby bus stops
GET /api/schedules/route/:routeId - Get route schedules
POST /api/journeys - Create journey
```

### Payments (PayDPI - Port 3003)
```
GET /api/payments/methods - Get payment methods
POST /api/payments/process - Process payment
GET /api/payments/history - Payment history
POST /api/subsidies/apply - Apply for subsidy
GET /api/subsidies/active - Get active subsidies
```

### Driver Services (Port 4001)
```
POST /api/driver/auth/login - Driver login
GET /api/driver/schedules - Get driver schedules
POST /api/driver/tracking/start - Start location tracking
POST /api/driver/tracking/update - Update location
```

### Passenger Services (Port 4002)
```
POST /api/passenger/auth/register - Register passenger
GET /api/passenger/dashboard - Get dashboard
POST /api/bookings - Create booking
GET /api/tickets - Get tickets
POST /api/passenger/tracking/subscribe - Subscribe to tracking
```

## 🔒 Security Features

- **JWT Authentication** across all services
- **OAuth 2.0** implementation (SLUDI)
- **Rate Limiting** on API endpoints
- **CORS** configuration for cross-origin requests
- **Input Validation** and sanitization
- **Password Hashing** with bcrypt

## 📊 Current Project Status

### ✅ Completed (Backend)
- All 6 Node.js servers fully functional
- Complete authentication system
- Route planning and journey management
- Payment processing with Stripe
- Real-time tracking capabilities
- Comprehensive API documentation
- Postman collections for testing

### ✅ Completed (Mobile)
- Driver app fully functional
- Complete driver authentication flow
- Schedule management integration
- GPS tracking implementation
- Google Maps integration

### ⚠️ In Progress (Mobile)
- Passenger app server integration
- API endpoint connections
- Real-time features implementation
- Payment flow integration

### 🔮 Planned Features
- Push notifications
- Advanced analytics dashboard
- Multi-language support
- Offline mode capabilities

## 🛠️ Development Notes

### Important Environment Variables

**Critical**: All servers must use the **same JWT_SECRET** for cross-service authentication:

```env
JWT_SECRET=your_super_secret_jwt_key_here
```

### Google Maps Configuration

Required for both Driver app and backend services:

1. Get API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable Maps SDK for Android/iOS
3. Add key to all relevant `.env` files

### Database Configuration

Each service uses a separate MongoDB database:
- `sludi` - User authentication data
- `ndx` - Routes, schedules, journey data  
- `paydpi` - Payment transactions, subsidies
- `driver` - Driver profiles, tracking data
- `passenger` - Passenger data, bookings, tickets

## 📞 Support & Documentation

### Additional Resources
- [Complete Testing Guide](Server/API%20Documentation/DPI_Complete_Testing_Guide.md)
- [OAuth Implementation Guide](Server/API%20Documentation/OAuth_Authorization_Guide.md)
- [Driver App Documentation](Client/driver/README.md)
- [NDX API Documentation](Server/API%20Documentation/NDX_API_Documentation.md)

### Getting Help

1. **Server Issues**: Check individual server logs and health endpoints
2. **Flutter Issues**: Ensure API endpoints match your server configuration
3. **Database Issues**: Verify MongoDB connections and database names
4. **API Testing**: Use provided Postman collections

## 🏆 ReviveNation Hackathon

This project demonstrates a complete digital public infrastructure implementation for Sri Lanka's transportation sector, showcasing:

- **Microservices Architecture**
- **Cross-platform Mobile Development**
- **Real-time Data Processing**
- **Secure Authentication Systems**
- **Payment Gateway Integration**
- **Government Digital Services**

---

**🇱🇰 Built for Sri Lanka's Digital Future - ReviveNation Hackathon 2024**

### Quick Commands Reference

```bash
# Start all servers
npm run start:all

# Test all health endpoints
curl http://localhost:5000/health/all

# Run driver app
cd Client/driver && flutter run

# Run passenger app (in development)
cd Client/passenger && flutter run
```
