class ProgressModel {
  final String progressId;
  final String userId;
  final DateTime date;
  final int totalWorkouts;
  final int totalReps;
  final double totalCalories;
  final int totalDurationSeconds;
  final Map<String, int> exerciseBreakdown;
  final double averageFormScore;

  ProgressModel({
    required this.progressId,
    required this.userId,
    required this.date,
    required this.totalWorkouts,
    required this.totalReps,
    required this.totalCalories,
    required this.totalDurationSeconds,
    required this.exerciseBreakdown,
    required this.averageFormScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'progressId': progressId,
      'userId': userId,
      'date': date.toIso8601String(),
      'totalWorkouts': totalWorkouts,
      'totalReps': totalReps,
      'totalCalories': totalCalories,
      'totalDurationSeconds': totalDurationSeconds,
      'exerciseBreakdown': exerciseBreakdown,
      'averageFormScore': averageFormScore,
    };
  }

  factory ProgressModel.fromMap(Map<String, dynamic> map) {
    return ProgressModel(
      progressId: map['progressId'] ?? '',
      userId: map['userId'] ?? '',
      date: DateTime.parse(map['date']),
      totalWorkouts: map['totalWorkouts'] ?? 0,
      totalReps: map['totalReps'] ?? 0,
      totalCalories: (map['totalCalories'] ?? 0.0).toDouble(),
      totalDurationSeconds: map['totalDurationSeconds'] ?? 0,
      exerciseBreakdown: Map<String, int>.from(map['exerciseBreakdown'] ?? {}),
      averageFormScore: (map['averageFormScore'] ?? 0.0).toDouble(),
    );
  }
}

class WeeklyProgress {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int totalWorkouts;
  final double totalCalories;
  final int totalDurationMinutes;
  final Map<String, int> exerciseCounts;

  WeeklyProgress({
    required this.weekStart,
    required this.weekEnd,
    required this.totalWorkouts,
    required this.totalCalories,
    required this.totalDurationMinutes,
    required this.exerciseCounts,
  });
}
