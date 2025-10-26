import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/calorie_service.dart';

class WorkoutProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final CalorieService _calorieService = CalorieService();

  List<WorkoutModel> _workouts = [];
  WorkoutModel? _currentWorkout;
  bool _isLoading = false;
  bool _isWorkoutActive = false;
  String? _errorMessage;

  // Current workout session data
  String? _activeExerciseType;
  int _currentReps = 0;
  int _currentSets = 0;
  DateTime? _workoutStartTime;
  List<SetData> _setDetails = [];

  List<WorkoutModel> get workouts => _workouts;
  WorkoutModel? get currentWorkout => _currentWorkout;
  bool get isLoading => _isLoading;
  bool get isWorkoutActive => _isWorkoutActive;
  String? get errorMessage => _errorMessage;
  String? get activeExerciseType => _activeExerciseType;
  int get currentReps => _currentReps;
  int get currentSets => _currentSets;

  // Start workout session
  void startWorkout(String exerciseType) {
    _isWorkoutActive = true;
    _activeExerciseType = exerciseType;
    _workoutStartTime = DateTime.now();
    _currentReps = 0;
    _currentSets = 0;
    _setDetails = [];
    notifyListeners();
  }

  // Update rep count
  void updateReps(int reps) {
    _currentReps = reps;
    notifyListeners();
  }

  // Complete a set
  void completeSet({
    required int reps,
    required int durationSeconds,
    required double formScore,
    int restTimeSeconds = 60,
  }) {
    _currentSets++;
    _setDetails.add(
      SetData(
        setNumber: _currentSets,
        reps: reps,
        durationSeconds: durationSeconds,
        formScore: formScore,
        restTimeSeconds: restTimeSeconds,
      ),
    );
    _currentReps = 0; // Reset reps for next set
    notifyListeners();
  }

  // End workout and save
  Future<bool> endWorkout(UserModel user) async {
    if (!_isWorkoutActive || _workoutStartTime == null) return false;

    try {
      DateTime endTime = DateTime.now();
      int totalDuration = endTime.difference(_workoutStartTime!).inSeconds;
      int totalReps = _setDetails.fold(0, (sum, set) => sum + set.reps);
      double avgFormScore = _setDetails.isEmpty
          ? 0.0
          : _setDetails.fold(0.0, (sum, set) => sum + set.formScore) / _setDetails.length;

      // Calculate calories
      double calories = _calorieService.calculateCalories(
        exerciseType: _activeExerciseType!,
        repetitions: totalReps,
        durationSeconds: totalDuration,
        user: user,
      );

      // Create workout model
      String workoutId = 'workout_${user.uid}_${DateTime.now().millisecondsSinceEpoch}';
      WorkoutModel workout = WorkoutModel(
        workoutId: workoutId,
        userId: user.uid,
        exerciseType: _activeExerciseType!,
        repetitions: totalReps,
        sets: _currentSets,
        caloriesBurned: calories,
        durationSeconds: totalDuration,
        startTime: _workoutStartTime!,
        endTime: endTime,
        averageFormScore: avgFormScore,
        setDetails: _setDetails,
      );

      // Save to Firebase
      await _firebaseService.saveWorkout(workout);

      // Add to local list
      _workouts.insert(0, workout);
      _currentWorkout = workout;

      // Reset workout state
      _isWorkoutActive = false;
      _activeExerciseType = null;
      _currentReps = 0;
      _currentSets = 0;
      _workoutStartTime = null;
      _setDetails = [];

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Load user workouts
  Future<void> loadWorkouts(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _workouts = await _firebaseService.getUserWorkouts(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get workouts by date range
  Future<List<WorkoutModel>> getWorkoutsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _firebaseService.getWorkoutsByDateRange(
        userId,
        startDate,
        endDate,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Delete workout
  Future<bool> deleteWorkout(String workoutId) async {
    try {
      await _firebaseService.deleteWorkout(workoutId);
      _workouts.removeWhere((w) => w.workoutId == workoutId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get workout statistics
  Future<Map<String, dynamic>> getStatistics(String userId) async {
    try {
      return await _firebaseService.getWorkoutStatistics(userId);
    } catch (e) {
      return {};
    }
  }

  // Cancel active workout
  void cancelWorkout() {
    _isWorkoutActive = false;
    _activeExerciseType = null;
    _currentReps = 0;
    _currentSets = 0;
    _workoutStartTime = null;
    _setDetails = [];
    notifyListeners();
  }
}
