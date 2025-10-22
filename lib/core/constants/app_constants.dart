class AppConstants {
  // App Information
  static const String appName = 'AI Fitness Coach';
  static const String appVersion = '1.0.0';

  // Exercise Types
  static const List<String> supportedExercises = [
    'Squats',
    'Push-ups',
    'Bicep Curls',
    'Shoulder Press',
    'Lunges',
    'Planks',
  ];

  // Pose Detection
  static const int poseKeypointCount = 33;
  static const double poseConfidenceThreshold = 0.5;
  static const int frameSequenceLength = 30;

  // Performance Metrics
  static const double exerciseAccuracyTarget = 0.99;
  static const double repCountingAccuracyTarget = 0.91;
  static const double calorieEstimationR2Target = 0.77;

  // Timing
  static const int splashDuration = 3; // seconds
  static const int restPeriodDefault = 60; // seconds
  static const int workoutTimeoutSeconds = 300;

  // Camera Settings
  static const int targetFPS = 30;
  static const int cameraResolutionWidth = 1280;
  static const int cameraResolutionHeight = 720;

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String workoutsCollection = 'workouts';
  static const String progressCollection = 'progress';

  // Shared Preferences Keys
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserId = 'userId';
  static const String keyUserName = 'userName';
  static const String keyThemeMode = 'themeMode';
}
