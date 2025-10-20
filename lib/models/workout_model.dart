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

  Map<String, dynamic> toMap() {
    return {
      'workoutId': workoutId,
      'userId': userId,
      'exerciseType': exerciseType,
      'repetitions': repetitions,
      'sets': sets,
      'caloriesBurned': caloriesBurned,
      'durationSeconds': durationSeconds,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'averageFormScore': averageFormScore,
      'setDetails': setDetails.map((set) => set.toMap()).toList(),
    };
  }

  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      workoutId: map['workoutId'] ?? '',
      userId: map['userId'] ?? '',
      exerciseType: map['exerciseType'] ?? '',
      repetitions: map['repetitions'] ?? 0,
      sets: map['sets'] ?? 0,
      caloriesBurned: (map['caloriesBurned'] ?? 0.0).toDouble(),
      durationSeconds: map['durationSeconds'] ?? 0,
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      averageFormScore: (map['averageFormScore'] ?? 0.0).toDouble(),
      setDetails: (map['setDetails'] as List<dynamic>)
          .map((item) => SetData.fromMap(item as Map<String, dynamic>))
          .toList(),
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

  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'reps': reps,
      'durationSeconds': durationSeconds,
      'formScore': formScore,
      'restTimeSeconds': restTimeSeconds,
    };
  }

  factory SetData.fromMap(Map<String, dynamic> map) {
    return SetData(
      setNumber: map['setNumber'] ?? 0,
      reps: map['reps'] ?? 0,
      durationSeconds: map['durationSeconds'] ?? 0,
      formScore: (map['formScore'] ?? 0.0).toDouble(),
      restTimeSeconds: map['restTimeSeconds'] ?? 0,
    );
  }
}
