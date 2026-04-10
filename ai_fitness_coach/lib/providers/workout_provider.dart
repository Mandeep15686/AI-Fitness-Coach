import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/calorie_service.dart';
import '../services/encryption_service.dart';

class WorkoutProvider with ChangeNotifier {
  late final FirebaseService _firebaseService;
  final CalorieService _calorieService = CalorieService();

  List<WorkoutModel> _workouts = [];
  WorkoutModel? _currentWorkout;
  bool _isLoading = false;
  bool _isWorkoutActive = false;
  String? _errorMessage;

  // Active session state
  String? _activeExerciseType;
  DateTime? _workoutStartTime;

  List<WorkoutModel> get workouts => _workouts;
  WorkoutModel? get currentWorkout => _currentWorkout;
  bool get isLoading => _isLoading;
  bool get isWorkoutActive => _isWorkoutActive;
  String? get errorMessage => _errorMessage;
  String? get activeExerciseType => _activeExerciseType;

  WorkoutProvider(EncryptionService encryptionService) {
    _firebaseService = FirebaseService(encryptionService);
  }

  void startWorkout(String exerciseType) {
    _isWorkoutActive = true;
    _activeExerciseType = exerciseType;
    _workoutStartTime = DateTime.now();
    _errorMessage = null;
    notifyListeners();
  }

  // BUG FIX: Auto-generate a single set from rep/form data so sets != 0
  Future<bool> endWorkout(UserModel user, {int repCount = 0, double formScore = 0.0}) async {
    if (!_isWorkoutActive || _workoutStartTime == null) return false;

    try {
      final endTime = DateTime.now();
      final durationSecs = endTime.difference(_workoutStartTime!).inSeconds.clamp(1, 99999);

      final double calories = _calorieService.calculateCalories(
        exerciseType: _activeExerciseType ?? 'Squats',
        repetitions: repCount,
        durationSeconds: durationSecs,
        user: user,
      );

      final sets = repCount > 0 ? <SetData>[
        SetData(setNumber: 1, reps: repCount, durationSeconds: durationSecs, formScore: formScore, restTimeSeconds: 0),
      ] : <SetData>[];

      final workout = WorkoutModel(
        workoutId: 'workout_${user.uid}_${DateTime.now().millisecondsSinceEpoch}',
        userId: user.uid,
        exerciseType: _activeExerciseType ?? 'Squats',
        repetitions: repCount,
        sets: sets.isEmpty ? 1 : sets.length,
        caloriesBurned: calories,
        durationSeconds: durationSecs,
        startTime: _workoutStartTime!,
        endTime: endTime,
        averageFormScore: formScore,
        setDetails: sets,
      );

      // Try to save to Firebase — don't crash if fails (no config yet)
      try {
        await _firebaseService.saveWorkout(workout);
      } catch (e) {
        debugPrint('Firebase save failed (expected if not configured): $e');
      }

      _workouts.insert(0, workout);
      _currentWorkout = workout;
      _isWorkoutActive = false;
      _activeExerciseType = null;
      _workoutStartTime = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadWorkouts(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _workouts = await _firebaseService.getUserWorkouts(userId);
    } catch (e) {
      debugPrint('loadWorkouts error: $e');
      // Don't crash — keep existing list
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<List<WorkoutModel>> getWorkoutsByDateRange(String userId, DateTime start, DateTime end) async {
    try {
      return await _firebaseService.getWorkoutsByDateRange(userId, start, end);
    } catch (e) {
      return [];
    }
  }

  Future<bool> deleteWorkout(String workoutId) async {
    try {
      await _firebaseService.deleteWorkout(workoutId);
      _workouts.removeWhere((w) => w.workoutId == workoutId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getStatistics(String userId) async {
    try {
      return await _firebaseService.getWorkoutStatistics(userId);
    } catch (e) {
      // Compute from local list if Firebase fails
      final total = _workouts.length;
      final cals = _workouts.fold<double>(0, (s, w) => s + w.caloriesBurned);
      final reps = _workouts.fold<int>(0, (s, w) => s + w.repetitions);
      final secs = _workouts.fold<int>(0, (s, w) => s + w.durationSeconds);
      return {
        'totalWorkouts': total,
        'totalCalories': cals,
        'totalReps': reps,
        'totalDurationMinutes': secs ~/ 60,
      };
    }
  }

  void cancelWorkout() {
    _isWorkoutActive = false;
    _activeExerciseType = null;
    _workoutStartTime = null;
    notifyListeners();
  }
}
