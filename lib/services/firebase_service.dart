import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';
import '../models/progress_model.dart';
import '../core/constants/app_constants.dart';
import 'encryption_service.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EncryptionService _encryptionService;

  FirebaseService(this._encryptionService);

  // Save workout to Firestore
  Future<void> saveWorkout(WorkoutModel workout) async {
    try {
      await _firestore
          .collection(AppConstants.workoutsCollection)
          .doc(workout.workoutId)
          .set(workout.toMap(_encryptionService));
    } catch (e) {
      throw Exception('Failed to save workout: ${e.toString()}');
    }
  }

  // Get user workouts
  Future<List<WorkoutModel>> getUserWorkouts(String userId, {int limit = 20}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.workoutsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => WorkoutModel.fromMap(doc.data() as Map<String, dynamic>, _encryptionService))
          .toList();
    } catch (e) {
      throw Exception('Failed to get workouts: ${e.toString()}');
    }
  }

  // Get workouts by date range
  Future<List<WorkoutModel>> getWorkoutsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.workoutsCollection)
          .where('userId', isEqualTo: userId)
          .where('startTime', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('startTime', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      return snapshot.docs
          .map((doc) => WorkoutModel.fromMap(doc.data() as Map<String, dynamic>, _encryptionService))
          .toList();
    } catch (e) {
      throw Exception('Failed to get workouts by date: ${e.toString()}');
    }
  }

  // Save progress
  Future<void> saveProgress(ProgressModel progress) async {
    try {
      await _firestore
          .collection(AppConstants.progressCollection)
          .doc(progress.progressId)
          .set(progress.toMap());
    } catch (e) {
      throw Exception('Failed to save progress: ${e.toString()}');
    }
  }

  // Get user progress
  Future<List<ProgressModel>> getUserProgress(
    String userId,
    {DateTime? startDate, DateTime? endDate}
  ) async {
    try {
      Query query = _firestore
          .collection(AppConstants.progressCollection)
          .where('userId', isEqualTo: userId);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: endDate.toIso8601String());
      }

      QuerySnapshot snapshot = await query.orderBy('date', descending: true).get();

      return snapshot.docs
          .map((doc) => ProgressModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get progress: ${e.toString()}');
    }
  }

  // Delete workout
  Future<void> deleteWorkout(String workoutId) async {
    try {
      await _firestore
          .collection(AppConstants.workoutsCollection)
          .doc(workoutId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete workout: ${e.toString()}');
    }
  }

  // Get workout statistics
  Future<Map<String, dynamic>> getWorkoutStatistics(String userId) async {
    try {
      final workouts = await getUserWorkouts(userId, limit: 1000); // Get all workouts

      int totalWorkouts = workouts.length;
      double totalCalories = 0;
      int totalReps = 0;
      int totalDurationSeconds = 0;

      for (var workout in workouts) {
        totalCalories += workout.caloriesBurned;
        totalReps += workout.repetitions;
        totalDurationSeconds += workout.durationSeconds;
      }

      return {
        'totalWorkouts': totalWorkouts,
        'totalCalories': totalCalories,
        'totalReps': totalReps,
        'totalDurationMinutes': totalDurationSeconds ~/ 60,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: ${e.toString()}');
    }
  }
}
