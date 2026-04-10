import '../services/encryption_service.dart';

class WorkoutModel {
  final String workoutId;
  final String userId;
  final String exerciseType;
  final int repetitions;
  final int sets;
  final double caloriesBurned;
  final int durationSeconds;
  final DateTime startTime;
  final DateTime endTime;
  final double averageFormScore;
  final List<SetData> setDetails;

  WorkoutModel({
    required this.workoutId,
    required this.userId,
    required this.exerciseType,
    required this.repetitions,
    required this.sets,
    required this.caloriesBurned,
    required this.durationSeconds,
    required this.startTime,
    required this.endTime,
    required this.averageFormScore,
    required this.setDetails,
  });

  Map<String, dynamic> toMap(EncryptionService encryptionService) {
    return {
      'workoutId': workoutId,
      'userId': userId,
      'exerciseType': exerciseType,
      'repetitions': repetitions,
      'sets': sets,
      'caloriesBurned': encryptionService.encrypt(caloriesBurned.toString()),
      'durationSeconds': durationSeconds,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'averageFormScore': encryptionService.encrypt(averageFormScore.toString()),
      'setDetails': setDetails.map((s) => s.toMap()).toList(),
    };
  }

  factory WorkoutModel.fromMap(Map<String, dynamic> map, EncryptionService encryptionService) {
    double parseSafe(dynamic val, double fallback) {
      if (val is String) {
        try { return double.parse(encryptionService.decrypt(val)); } catch (_) { return fallback; }
      }
      if (val is num) return val.toDouble();
      return fallback;
    }

    // BUG FIX: Handle null setDetails safely
    final rawSets = map['setDetails'];
    final List<SetData> sets = rawSets is List
        ? rawSets.map((item) => SetData.fromMap(item as Map<String, dynamic>)).toList()
        : [];

    return WorkoutModel(
      workoutId: map['workoutId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      exerciseType: map['exerciseType'] as String? ?? '',
      repetitions: (map['repetitions'] as num?)?.toInt() ?? 0,
      sets: (map['sets'] as num?)?.toInt() ?? 0,
      caloriesBurned: parseSafe(map['caloriesBurned'], 0.0),
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      startTime: map['startTime'] != null ? DateTime.parse(map['startTime']) : DateTime.now(),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : DateTime.now(),
      averageFormScore: parseSafe(map['averageFormScore'], 0.0),
      setDetails: sets,
    );
  }
}

class SetData {
  final int setNumber;
  final int reps;
  final int durationSeconds;
  final double formScore;
  final int restTimeSeconds;

  SetData({
    required this.setNumber,
    required this.reps,
    required this.durationSeconds,
    required this.formScore,
    required this.restTimeSeconds,
  });

  Map<String, dynamic> toMap() => {
    'setNumber': setNumber,
    'reps': reps,
    'durationSeconds': durationSeconds,
    'formScore': formScore,
    'restTimeSeconds': restTimeSeconds,
  };

  factory SetData.fromMap(Map<String, dynamic> map) => SetData(
    setNumber: (map['setNumber'] as num?)?.toInt() ?? 0,
    reps: (map['reps'] as num?)?.toInt() ?? 0,
    durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
    formScore: (map['formScore'] as num?)?.toDouble() ?? 0.0,
    restTimeSeconds: (map['restTimeSeconds'] as num?)?.toInt() ?? 0,
  );
}
