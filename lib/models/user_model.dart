class UserModel {
  final String uid;
  final String email;
  final String name;
  final int age;
  final double height; // in cm
  final double weight; // in kg
  final String fitnessGoal;
  final String fitnessLevel;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.fitnessGoal,
    required this.fitnessLevel,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert UserModel to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'fitnessGoal': fitnessGoal,
      'fitnessLevel': fitnessLevel,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      height: (map['height'] ?? 0.0).toDouble(),
      weight: (map['weight'] ?? 0.0).toDouble(),
      fitnessGoal: map['fitnessGoal'] ?? 'General Fitness',
      fitnessLevel: map['fitnessLevel'] ?? 'Beginner',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  // Calculate BMI
  double get bmi => weight / ((height / 100) * (height / 100));

  // Copy with method for updates
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    int? age,
    double? height,
    double? weight,
    String? fitnessGoal,
    String? fitnessLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
