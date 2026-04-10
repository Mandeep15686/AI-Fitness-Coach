import '../models/user_model.dart';
import '../models/workout_model.dart';

class CalorieService {
  static const Map<String, double> _metValues = {
    'Squats': 5.0,
    'Push-ups': 3.8,
    'Bicep Curls': 3.0,
    'Shoulder Press': 4.0,
    'Lunges': 4.5,
    'Planks': 3.5,
  };

  // BUG FIX: Guard against zero duration
  double calculateCalories({
    required String exerciseType,
    required int repetitions,
    required int durationSeconds,
    required UserModel user,
  }) {
    if (durationSeconds <= 0 || user.weight <= 0) return 0.0;

    final double met = _metValues[exerciseType] ?? 4.0;
    final double durationHours = durationSeconds / 3600.0;
    final double baseCalories = met * user.weight * durationHours;

    final double repsPerMinute = repetitions / (durationSeconds / 60.0);
    final double intensityMultiplier = _getIntensityMultiplier(repsPerMinute, exerciseType);

    return (baseCalories * intensityMultiplier).clamp(0.0, double.infinity);
  }

  double _getIntensityMultiplier(double repsPerMinute, String exerciseType) {
    switch (exerciseType) {
      case 'Squats':
        if (repsPerMinute > 20) return 1.3;
        if (repsPerMinute > 15) return 1.15;
        return 1.0;
      case 'Push-ups':
        if (repsPerMinute > 25) return 1.4;
        if (repsPerMinute > 20) return 1.2;
        return 1.0;
      case 'Bicep Curls':
        if (repsPerMinute > 15) return 1.25;
        if (repsPerMinute > 10) return 1.1;
        return 1.0;
      case 'Shoulder Press':
        if (repsPerMinute > 12) return 1.3;
        if (repsPerMinute > 8) return 1.15;
        return 1.0;
      default:
        return 1.0;
    }
  }

  double calculateWorkoutCalories(WorkoutModel workout, UserModel user) {
    return calculateCalories(
      exerciseType: workout.exerciseType,
      repetitions: workout.repetitions,
      durationSeconds: workout.durationSeconds,
      user: user,
    );
  }

  double estimateCaloriesForReps({
    required String exerciseType,
    required int targetReps,
    required UserModel user,
  }) {
    final int estimatedSeconds = (targetReps / 12.0 * 60).round().clamp(1, 9999);
    return calculateCalories(
      exerciseType: exerciseType,
      repetitions: targetReps,
      durationSeconds: estimatedSeconds,
      user: user,
    );
  }

  double calculateBMR(UserModel user, {String gender = 'male'}) {
    if (user.weight <= 0 || user.height <= 0 || user.age <= 0) return 0.0;
    final double s = gender.toLowerCase() == 'male' ? 5 : -161;
    return 10 * user.weight + 6.25 * user.height - 5 * user.age + s;
  }

  double calculateTDEE(double bmr, String activityLevel) {
    const Map<String, double> multipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'Beginner': 1.375,
      'moderate': 1.55,
      'Intermediate': 1.55,
      'active': 1.725,
      'Advanced': 1.725,
      'very_active': 1.9,
    };
    return bmr * (multipliers[activityLevel] ?? 1.55);
  }
}
