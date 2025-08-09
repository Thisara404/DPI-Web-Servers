const express = require("express");
const MapController = require("../controllers/mapController");

const router = express.Router();

// PUBLIC ROUTES (No authentication required for map data)
router.get("/routes/:routeId", MapController.getRouteMapData);
router.get("/buses/live", MapController.getLiveBusLocations);
router.get("/stops/nearby", MapController.findNearbyStops);
router.get("/directions", MapController.getRouteDirections);

module.exports = router;
