const mongoose = require('mongoose');

const passengerSchema = new mongoose.Schema({
  citizenId: {
    type: String,
    required: true,
    unique: true
  },
  firstName: {
    type: String,
    required: true,
    trim: true
  },
  lastName: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  phone: {
    type: String,
    required: true,
    trim: true
  },
  dateOfBirth: {
    type: Date
  },
  address: {
    street: String,
    city: String,
    state: String,
    zipCode: String,
    country: { type: String, default: 'Sri Lanka' }
  },
  preferences: {
    favoriteRoutes: [{
      routeId: String,
      routeName: String,
      addedAt: { type: Date, default: Date.now }
    }],
    paymentMethod: {
      type: String,
      enum: ['cash', 'card', 'digital_wallet', 'bank_transfer'],
      default: 'cash'
    },
    notifications: {
      email: { type: Boolean, default: true },
      sms: { type: Boolean, default: false },
      push: { type: Boolean, default: true }
    },
    language: { type: String, default: 'en' }
  },
  status: {
    type: String,
    enum: ['active', 'inactive', 'suspended'],
    default: 'active'
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  verificationCode: String,
  lastLogin: Date,
  bookingHistory: [{
    bookingId: String,
    scheduleId: String,
    routeName: String,
    date: Date,
    amount: Number
  }],
  totalJourneys: {
    type: Number,
    default: 0
  },
  totalSpent: {
    type: Number,
    default: 0
  }
}, {
  timestamps: true
});

// Virtual for full name
passengerSchema.virtual('fullName').get(function() {
  return `${this.firstName} ${this.lastName}`;
});

// Instance methods
passengerSchema.methods.addToFavorites = function(routeData) {
  const existingFavorite = this.preferences.favoriteRoutes.find(
    route => route.routeId === routeData.routeId
  );
  
  if (!existingFavorite) {
    this.preferences.favoriteRoutes.push(routeData);
    return this.save();
  }
  return Promise.resolve(this);
};

passengerSchema.methods.removeFromFavorites = function(routeId) {
  this.preferences.favoriteRoutes = this.preferences.favoriteRoutes.filter(
    route => route.routeId !== routeId
  );
  return this.save();
};

passengerSchema.methods.updateLastLogin = function() {
  this.lastLogin = new Date();
  return this.save();
};

passengerSchema.methods.addToBookingHistory = function(bookingData) {
  this.bookingHistory.unshift(bookingData);
  if (this.bookingHistory.length > 50) {
    this.bookingHistory = this.bookingHistory.slice(0, 50);
  }
  this.totalJourneys += 1;
  this.totalSpent += bookingData.amount || 0;
  return this.save();
};

module.exports = mongoose.model('Passenger', passengerSchema);