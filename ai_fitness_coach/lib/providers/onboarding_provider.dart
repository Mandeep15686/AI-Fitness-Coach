import 'package:flutter/material.dart';

class OnboardingProvider with ChangeNotifier {
  String? _goal;
  String? _fitnessLevel;
  String? _equipment;
  String? _timeAvailability;
  String? _workoutLocation;

  String? get goal => _goal;
  String? get fitnessLevel => _fitnessLevel;
  String? get equipment => _equipment;
  String? get timeAvailability => _timeAvailability;
  String? get workoutLocation => _workoutLocation;

  void setGoal(String goal) {
    _goal = goal;
    notifyListeners();
  }

  void setFitnessLevel(String level) {
    _fitnessLevel = level;
    notifyListeners();
  }

  void setEquipment(String equipment) {
    _equipment = equipment;
    notifyListeners();
  }

  void setTimeAvailability(String time) {
    _timeAvailability = time;
    notifyListeners();
  }

  void setWorkoutLocation(String location) {
    _workoutLocation = location;
    notifyListeners();
  }
}
