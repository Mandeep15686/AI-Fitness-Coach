import '../models/user_model.dart';
import '../models/workout_model.dart';

class CalorieService {
  // MET (Metabolic Equivalent of Task) values for exercises
  static const Map<String, double> _metValues = {
    'Squats': 5.0,
    'Push-ups': 3.8,
    'Bicep Curls': 3.0,
    'Shoulder Press': 4.0,
    'Lunges': 4.5,
    'Planks': 3.5,
  };

  // Calculate calories burned
  double calculateCalories({
    required String exerciseType,
    required int repetitions,
    required int durationSeconds,
    required UserModel user,
  }) {
    // Get MET value for exercise
    double met = _metValues[exerciseType] ?? 4.0;

    // Calculate using formula: Calories = MET * weight(kg) * time(hours)
    double durationHours = durationSeconds / 3600.0;
    double baseCalories = met * user.weight * durationHours;

    // Adjust based on intensity (reps per minute)
    double repsPerMinute = repetitions / (durationSeconds / 60.0);
    double intensityMultiplier = _getIntensityMultiplier(repsPerMinute, exerciseType);

    return baseCalories * intensityMultiplier;
  }

  // Get intensity multiplier based on reps per minute
  double _getIntensityMultiplier(double repsPerMinute, String exerciseType) {
    // Adjust multiplier based on exercise pace
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

  // Calculate calories for entire workout
  double calculateWorkoutCalories(WorkoutModel workout, UserModel user) {
    return calculateCalories(
      exerciseType: workout.exerciseType,
      repetitions: workout.repetitions,
      durationSeconds: workout.durationSeconds,
      user: user,
    );
  }

  // Estimate calories for target reps
  double estimateCaloriesForReps({
    required String exerciseType,
    required int targetReps,
    required UserModel user,
  }) {
    // Estimate duration based on average pace (12 reps/minute)
    int estimatedSeconds = (targetReps / 12.0 * 60).round();

    return calculateCalories(
      exerciseType: exerciseType,
      repetitions: targetReps,
      durationSeconds: estimatedSeconds,
      user: user,
    );
  }

  // Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor Equation
  double calculateBMR(UserModel user, String gender) {
    // BMR = 10 * weight(kg) + 6.25 * height(cm) - 5 * age(y) + s
    // s = +5 for males, -161 for females
    double s = gender.toLowerCase() == 'male' ? 5 : -161;
    return 10 * user.weight + 6.25 * user.height - 5 * user.age + s;
  }

  // Calculate TDEE (Total Daily Energy Expenditure)
  double calculateTDEE(double bmr, String activityLevel) {
    Map<String, double> activityMultipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };

    return bmr * (activityMultipliers[activityLevel] ?? 1.55);
  }
}
