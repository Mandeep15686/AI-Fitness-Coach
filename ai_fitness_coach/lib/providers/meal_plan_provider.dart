import 'package:flutter/material.dart';
import '../services/meal_plan_service.dart';
import '../models/user_model.dart';

class MealPlanProvider with ChangeNotifier {
  final MealPlanService _mealPlanService = MealPlanService();

  Map<String, dynamic>? _mealPlan;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get mealPlan => _mealPlan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> generateMealPlan({
    required UserModel user,
    required String fitnessGoal,
    required List<String> dietaryRestrictions,
    required List<String> foodPreferences,
    required List<String> foodDislikes,
    required double budget,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _mealPlan = await _mealPlanService.generateMealPlan(
        user: user,
        fitnessGoal: fitnessGoal,
        dietaryRestrictions: dietaryRestrictions,
        foodPreferences: foodPreferences,
        foodDislikes: foodDislikes,
        budget: budget,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
