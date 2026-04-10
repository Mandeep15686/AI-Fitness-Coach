import 'package:flutter/material.dart';
import '../../screens/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/phone_verification_screen.dart';
import '../../screens/home/dashboard_screen.dart';
import '../../screens/workout/workout_selection_screen.dart';
import '../../screens/workout/live_workout_screen.dart';
import '../../screens/progress/progress_analytics_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/settings/security_settings_screen.dart';
import '../../screens/settings/privacy_settings_screen.dart';
import '../../screens/meal_plan/meal_plan_screen.dart';
import '../../screens/onboarding/welcome_screen.dart';
import '../../screens/onboarding/goal_selection_screen.dart';
import '../../screens/onboarding/fitness_level_screen.dart';
import '../../screens/onboarding/equipment_screen.dart';
import '../../screens/onboarding/time_availability_screen.dart';
import '../../screens/onboarding/workout_location_screen.dart';

// BUG FIX: Use correct relative imports — app_routes.dart is in lib/core/routes/
// so screens are ../../screens/... not ../../screens/...

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
  static const String welcome = '/welcome';
  static const String goalSelection = '/goal-selection';
  static const String fitnessLevel = '/fitness-level';
  static const String equipment = '/equipment';
  static const String timeAvailability = '/time-availability';
  static const String workoutLocation = '/workout-location';

  static Route<dynamic> generateRoute(RouteSettings settings_) {
    switch (settings_.name) {
      case splash: return _route(const SplashScreen());
      case login: return _route(const LoginScreen());
      case signup: return _route(const SignupScreen());
      case dashboard: return _route(const DashboardScreen());
      case workoutSelection: return _route(const WorkoutSelectionScreen());
      case liveWorkout:
        final args = settings_.arguments as Map<String, dynamic>?;
        return _route(LiveWorkoutScreen(exerciseType: args?['exerciseType'] ?? 'Squats'));
      case progress: return _route(const ProgressAnalyticsScreen());
      case profile: return _route(const ProfileScreen());
      case settings: return _route(const SettingsScreen());
      case securitySettings: return _route(const SecuritySettingsScreen());
      case privacySettings: return _route(const PrivacySettingsScreen());
      case phoneVerification: return _route(const PhoneVerificationScreen());
      case mealPlan: return _route(const MealPlanScreen());
      case welcome: return _route(const WelcomeScreen());
      case goalSelection: return _route(const GoalSelectionScreen());
      case fitnessLevel: return _route(const FitnessLevelScreen());
      case equipment: return _route(const EquipmentScreen());
      case timeAvailability: return _route(const TimeAvailabilityScreen());
      case workoutLocation: return _route(const WorkoutLocationScreen());
      default: return _route(Scaffold(
        body: Center(child: Text('No route: ${settings_.name}')),
      ));
    }
  }

  static MaterialPageRoute<dynamic> _route(Widget page) =>
    MaterialPageRoute(builder: (_) => page);
}
