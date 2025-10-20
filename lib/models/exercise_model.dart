class ExerciseModel {
  final String exerciseId;
  final String name;
  final String category;
  final String description;
  final String difficulty;
  final List<String> muscleGroups;
  final String? imageUrl;
  final String? videoUrl;
  final int defaultReps;
  final int defaultSets;
  final double caloriesPerRep;

  ExerciseModel({
    required this.exerciseId,
    required this.name,
    required this.category,
    required this.description,
    required this.difficulty,
    required this.muscleGroups,
    this.imageUrl,
    this.videoUrl,
    required this.defaultReps,
    required this.defaultSets,
    required this.caloriesPerRep,
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'category': category,
      'description': description,
      'difficulty': difficulty,
      'muscleGroups': muscleGroups,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'defaultReps': defaultReps,
      'defaultSets': defaultSets,
      'caloriesPerRep': caloriesPerRep,
    };
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      exerciseId: map['exerciseId'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? 'Beginner',
      muscleGroups: List<String>.from(map['muscleGroups'] ?? []),
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
      defaultReps: map['defaultReps'] ?? 10,
      defaultSets: map['defaultSets'] ?? 3,
      caloriesPerRep: (map['caloriesPerRep'] ?? 0.5).toDouble(),
    );
  }

  // Predefined exercises
  static List<ExerciseModel> getDefaultExercises() {
    return [
      ExerciseModel(
        exerciseId: 'ex_001',
        name: 'Squats',
        category: 'Lower Body',
        description: 'A fundamental lower body exercise targeting quads, glutes, and hamstrings',
        difficulty: 'Beginner',
        muscleGroups: ['Quadriceps', 'Glutes', 'Hamstrings'],
        defaultReps: 15,
        defaultSets: 3,
        caloriesPerRep: 0.6,
      ),
      ExerciseModel(
        exerciseId: 'ex_002',
        name: 'Push-ups',
        category: 'Upper Body',
        description: 'Classic upper body exercise for chest, shoulders, and triceps',
        difficulty: 'Intermediate',
        muscleGroups: ['Chest', 'Shoulders', 'Triceps', 'Core'],
        defaultReps: 12,
        defaultSets: 3,
        caloriesPerRep: 0.5,
      ),
      ExerciseModel(
        exerciseId: 'ex_003',
        name: 'Bicep Curls',
        category: 'Arms',
        description: 'Isolation exercise for bicep development',
        difficulty: 'Beginner',
        muscleGroups: ['Biceps', 'Forearms'],
        defaultReps: 12,
        defaultSets: 3,
        caloriesPerRep: 0.3,
      ),
      ExerciseModel(
        exerciseId: 'ex_004',
        name: 'Shoulder Press',
        category: 'Upper Body',
        description: 'Overhead press for shoulder and upper body strength',
        difficulty: 'Intermediate',
        muscleGroups: ['Shoulders', 'Triceps', 'Upper Chest'],
        defaultReps: 10,
        defaultSets: 3,
        caloriesPerRep: 0.7,
      ),
    ];
  }
}
