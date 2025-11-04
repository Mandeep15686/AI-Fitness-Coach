import 'package:ai_fitness_coach/main.dart';
import 'package:ai_fitness_coach/providers/theme_provider.dart';
import 'package:ai_fitness_coach/services/encryption_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  //This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Create a ThemeProvider instance
    final themeProvider = ThemeProvider();
    await themeProvider.loadTheme(); // Load the theme

    // Create a mock EncryptionService
    final encryptionService = EncryptionService();
    await encryptionService.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(AIFitnessCoachApp(
      themeProvider: themeProvider,
      encryptionService: encryptionService,
    ));

    // Verify that the app builds without crashing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
