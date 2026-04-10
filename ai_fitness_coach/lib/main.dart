import 'package:ai_fitness_coach/providers/meal_plan_provider.dart';
import 'package:ai_fitness_coach/providers/onboarding_provider.dart';
import 'package:ai_fitness_coach/providers/privacy_provider.dart';
import 'package:ai_fitness_coach/providers/theme_provider.dart';
import 'package:ai_fitness_coach/services/encryption_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/pose_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization skipped: $e');
  }

  // Initialize encryption service
  final encryptionService = EncryptionService();
  await encryptionService.init();

  // Load the theme
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(AIFitnessCoachApp(
    themeProvider: themeProvider,
    encryptionService: encryptionService,
  ));
}

class AIFitnessCoachApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final EncryptionService encryptionService;

  const AIFitnessCoachApp({
    super.key,
    required this.themeProvider,
    required this.encryptionService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(encryptionService)),
        ChangeNotifierProvider(create: (_) => WorkoutProvider(encryptionService)),
        ChangeNotifierProvider(create: (_) => PoseProvider()),
        ChangeNotifierProvider(create: (_) => PrivacyProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => MealPlanProvider()),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: MaterialApp(
        title: 'AI Fitness Coach',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // Always dark
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
