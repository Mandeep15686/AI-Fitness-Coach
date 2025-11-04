import 'package:ai_fitness_coach/screens/auth/phone_verification_screen.dart';
import 'package:ai_fitness_coach/screens/meal_plan/meal_plan_screen.dart';
import 'package:ai_fitness_coach/screens/onboarding/equipment_screen.dart';
import 'package:ai_fitness_coach/screens/onboarding/fitness_level_screen.dart';
import 'package:ai_fitness_coach/screens/onboarding/goal_selection_screen.dart';
import 'package:ai_fitness_coach/screens/onboarding/time_availability_screen.dart';
import 'package:ai_fitness_coach/screens/onboarding/welcome_screen.dart';
import 'package:ai_fitness_coach/screens/onboarding/workout_location_screen.dart';
import 'package:ai_fitness_coach/screens/settings/privacy_settings_screen.dart';
import 'package:ai_fitness_coach/screens/settings/security_settings_screen.dart';
import 'package:ai_fitness_coach/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import '../../screens/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/home/dashboard_screen.dart';
import '../../screens/workout/workout_selection_screen.dart';
import '../../screens/workout/live_workout_screen.dart';
import '../../screens/progress/progress_analytics_screen.dart';
import '../../screens/profile/profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String workoutSelection = '/workout-selection';
  static const String liveWorkout = '/live-workout';
  static const String progress = '/progress';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String securitySettings = '/security-settings';
  static const String privacySettings = '/privacy-settings';
  static const String phoneVerification = '/phone-verification';
  static const String mealPlan = '/meal-plan';

  // Onboarding
  static const String welcome = '/welcome';
  static const String goalSelection = '/goal-selection';
  static const String fitnessLevel = '/fitness-level';
  static const String equipment = '/equipment';
  static const String timeAvailability = '/time-availability';
  static const String workoutLocation = '/workout-location';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case workoutSelection:
        return MaterialPageRoute(builder: (_) => const WorkoutSelectionScreen());

      case liveWorkout:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => LiveWorkoutScreen(
            exerciseType: args?['exerciseType'] ?? 'Squats',
          ),
        );

      case progress:
        return MaterialPageRoute(builder: (_) => const ProgressAnalyticsScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case securitySettings:
        return MaterialPageRoute(builder: (_) => const SecuritySettingsScreen());

      case privacySettings:
        return MaterialPageRoute(builder: (_) => const PrivacySettingsScreen());

      case phoneVerification:
        return MaterialPageRoute(builder: (_) => const PhoneVerificationScreen());

      case mealPlan:
        return MaterialPageRoute(builder: (_) => const MealPlanScreen());

      // Onboarding
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case goalSelection:
        return MaterialPageRoute(builder: (_) => const GoalSelectionScreen());
      case fitnessLevel:
        return MaterialPageRoute(builder: (_) => const FitnessLevelScreen());
      case equipment:
        return MaterialPageRoute(builder: (_) => const EquipmentScreen());
      case timeAvailability:
        return MaterialPageRoute(builder: (_) => const TimeAvailabilityScreen());
      case workoutLocation:
        return MaterialPageRoute(builder: (_) => const WorkoutLocationScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}
