import '../models/user_model.dart';

class MealPlanService {
  // TDEE Calculation (using Mifflin-St Jeor Equation)
  double _calculateBMR(UserModel user) {
    // BMR = 10 * weight (kg) + 6.25 * height (cm) - 5 * age (y) + s (kcal / day)
    // where s is +5 for males and -161 for females
    // For simplicity, we'll use a neutral value. A more advanced implementation would ask for gender.
    return 10 * user.weight + 6.25 * user.height - 5 * user.age + 5;
  }

  double calculateTDEE(UserModel user, String activityLevel) {
    double bmr = _calculateBMR(user);
    switch (activityLevel) {
      case 'Beginner':
        return bmr * 1.375; // Lightly active
      case 'Intermediate':
        return bmr * 1.55; // Moderately active
      case 'Advanced':
        return bmr * 1.725; // Very active
      default:
        return bmr * 1.2; // Sedentary
    }
  }

  // This is a placeholder for a much more complex AI generation logic.
  // In a real app, this would involve a call to a backend service with a generative AI model.
  Future<Map<String, dynamic>> generateMealPlan({
    required UserModel user,
    required String fitnessGoal,
    required List<String> dietaryRestrictions,
    required List<String> foodPreferences,
    required List<String> foodDislikes,
    required double budget, // e.g., weekly budget
  }) async {
    // 1. Calculate TDEE
    double tdee = calculateTDEE(user, user.fitnessLevel);

    // 2. Adjust calories based on goal
    double targetCalories = tdee;
    if (fitnessGoal == 'Weight Loss') {
      targetCalories -= 500; // Caloric deficit
    } else if (fitnessGoal == 'Muscle Building') {
      targetCalories += 500; // Caloric surplus
    }

    // 3. Placeholder for AI-generated meal plan
    // This would be a complex prompt engineering task in a real scenario.
    // We are mocking a simple response.
    await Future.delayed(const Duration(seconds: 2)); // Simulate network call

    return {
      'targetCalories': targetCalories,
      'dailyPlan': {
        'Breakfast': {
          'name': 'Scrambled Eggs with Spinach',
          'calories': 300,
          'recipe': 'Scramble 2 eggs with a handful of spinach. Serve with a slice of whole-wheat toast.'
        },
        'Lunch': {
          'name': 'Grilled Chicken Salad',
          'calories': 450,
          'recipe': 'Grilled chicken breast over a bed of mixed greens with a light vinaigrette.'
        },
        'Dinner': {
          'name': 'Salmon with Quinoa and Broccoli',
          'calories': 550,
          'recipe\'': 'Baked salmon fillet with a side of quinoa and steamed broccoli.'
        },
        'Snack': {
          'name': 'Greek Yogurt with Berries',
          'calories': 200,
          'recipe': 'A cup of Greek yogurt with a handful of mixed berries.'
        },
      },
      'groceryList': [
        'Eggs',
        'Spinach',
        'Whole-wheat toast',
        'Chicken breast',
        'Mixed greens',
        'Vinaigrette',
        'Salmon fillet',
        'Quinoa',
        'Broccoli',
        'Greek yogurt',
        'Berries',
      ],
    };
  }
}
