import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/schedules_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/tickets_screen.dart';
import 'screens/journey_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';

class TransitLankaApp extends StatelessWidget {
  const TransitLankaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return MaterialApp.router(
          title: 'Transit Lanka Passenger',
          theme: AppTheme.darkTheme,
          routerConfig: _createRouter(authProvider),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: authProvider.isAuthenticated ? '/home' : '/auth',
      redirect: (context, state) {
        final bool isAuthenticated = authProvider.isAuthenticated;
        final String location = state.location;

        // If not authenticated and trying to access protected routes
        if (!isAuthenticated && !location.startsWith('/auth')) {
          return '/auth';
        }

        // If authenticated and trying to access auth routes
        if (isAuthenticated && location.startsWith('/auth')) {
          return '/home';
        }

        return null; // No redirect needed
      },
      routes: [
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/schedules',
          builder: (context, state) => const SchedulesScreen(),
        ),
        GoRoute(
          path: '/booking',
          builder: (context, state) {
            final scheduleId = state.queryParameters['scheduleId'];
            return BookingScreen(scheduleId: scheduleId);
          },
        ),
        GoRoute(
          path: '/tickets',
          builder: (context, state) => const TicketsScreen(),
        ),
        GoRoute(
          path: '/journey',
          builder: (context, state) => const JourneyScreen(),
        ),
        GoRoute(
          path: '/map',
          builder: (context, state) => const MapScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    );
  }
}