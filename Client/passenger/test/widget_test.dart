// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger/app.dart';
import 'package:provider/provider.dart';

import 'package:passenger/main.dart';
import 'package:passenger/services/storage_service.dart';
import 'package:passenger/providers/auth_provider.dart';
import 'package:passenger/providers/schedule_provider.dart';
import 'package:passenger/providers/journey_provider.dart';

void main() {
  group('App Widget Tests', () {
    setUpAll(() async {
      // Initialize storage service for tests
      await StorageService.init();
    });

    testWidgets('App loads without crashing', (WidgetTester tester) async {
      // Build our app with proper providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => ScheduleProvider()),
            ChangeNotifierProvider(create: (_) => JourneyProvider()),
          ],
          child: const TransitLankaApp(),
        ),
      );

      // Wait for the app to settle
      await tester.pumpAndSettle();

      // Verify that the app loads successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Basic widget rendering test', (WidgetTester tester) async {
      // Build a simple test widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Transit Lanka Test'),
            ),
          ),
        ),
      );

      // Verify that the test text is displayed
      expect(find.text('Transit Lanka Test'), findsOneWidget);
    });
  });
}
