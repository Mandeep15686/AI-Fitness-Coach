import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../core/constants/colors.dart';

class WorkoutCardWidget extends StatelessWidget {
  final WorkoutModel workout;

  const WorkoutCardWidget({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  workout.exerciseType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${workout.caloriesBurned.toStringAsFixed(0)} cal',
                  style: const TextStyle(
                    color: AppColors.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.repeat, size: 16),
                const SizedBox(width: 4),
                Text('${workout.repetitions} reps'),
                const SizedBox(width: 16),
                const Icon(Icons.fitness_center, size: 16),
                const SizedBox(width: 4),
                Text('${workout.sets} sets'),
                const SizedBox(width: 16),
                const Icon(Icons.timer, size: 16),
                const SizedBox(width: 4),
                Text('${workout.durationSeconds ~/ 60} min'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${workout.startTime.day}/${workout.startTime.month}/${workout.startTime.year}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
