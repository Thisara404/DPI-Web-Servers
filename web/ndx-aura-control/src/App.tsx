import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Index from "./pages/Index";
import AuthPage from "./pages/AuthPage";
import RoutesPage from "./pages/RoutesPage";
import RouteDetailsPage from "./pages/RouteDetailsPage";
import SchedulesPage from "./pages/SchedulesPage";
import ScheduleDetailsPage from "./pages/ScheduleDetailsPage";
import JourneysPage from "./pages/JourneysPage";
import JourneyDetailsPage from "./pages/JourneyDetailsPage";
import BookJourneyPage from "./pages/BookJourneyPage";
import MapPage from "./pages/MapPage";
import SearchLocationsPage from "./pages/SearchLocationsPage";
import AnalyticsPage from "./pages/AnalyticsPage";
import NotFound from "./pages/NotFound";
import ProtectedRoute from "./components/ProtectedRoute";
import Header from "./components/Header";
import { useAuth } from "./hooks/useAuth";

const queryClient = new QueryClient();

const AppContent = () => {
  const { isAuthenticated } = useAuth();

  return (
    <>
      {isAuthenticated && <Header />}
      <Routes>
        <Route path="/auth" element={<AuthPage />} />
        <Route path="/" element={
          <ProtectedRoute><Index /></ProtectedRoute>
        } />
        <Route path="/routes" element={
          <ProtectedRoute><RoutesPage /></ProtectedRoute>
        } />
        <Route path="/routes/:routeId" element={
          <ProtectedRoute><RouteDetailsPage /></ProtectedRoute>
        } />
        <Route path="/schedules" element={
          <ProtectedRoute><SchedulesPage /></ProtectedRoute>
        } />
        <Route path="/schedules/:id" element={
          <ProtectedRoute><ScheduleDetailsPage /></ProtectedRoute>
        } />
        <Route path="/journeys" element={
          <ProtectedRoute><JourneysPage /></ProtectedRoute>
        } />
        <Route path="/journeys/book" element={
          <ProtectedRoute><BookJourneyPage /></ProtectedRoute>
        } />
        <Route path="/journeys/:id" element={
          <ProtectedRoute><JourneyDetailsPage /></ProtectedRoute>
        } />
        <Route path="/map" element={
          <ProtectedRoute><MapPage /></ProtectedRoute>
        } />
        <Route path="/search" element={
          <ProtectedRoute><SearchLocationsPage /></ProtectedRoute>
        } />
        <Route path="/analytics" element={
          <ProtectedRoute><AnalyticsPage /></ProtectedRoute>
        } />
        {/* ADD ALL CUSTOM ROUTES ABOVE THE CATCH-ALL "*" ROUTE */}
        <Route path="*" element={<NotFound />} />
      </Routes>
    </>
  );
};

const App = () => (
  <QueryClientProvider client={queryClient}>
    <TooltipProvider>
      <Toaster />
      <Sonner />
      <BrowserRouter>
        <AppContent />
      </BrowserRouter>
    </TooltipProvider>
  </QueryClientProvider>
);

export default App;
