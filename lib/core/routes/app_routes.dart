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

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
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
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => LiveWorkoutScreen(
            exerciseType: args?['exerciseType'] ?? 'Squats',
          ),
        );

      case progress:
        return MaterialPageRoute(builder: (_) => const ProgressAnalyticsScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
