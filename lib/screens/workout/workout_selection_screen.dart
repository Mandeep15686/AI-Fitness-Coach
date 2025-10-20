import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/exercise_model.dart';

class WorkoutSelectionScreen extends StatelessWidget {
  const WorkoutSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final exercises = ExerciseModel.getDefaultExercises();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Exercise'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryColor,
                child: const Icon(Icons.fitness_center, color: Colors.white),
              ),
              title: Text(exercise.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(exercise.description),
                  const SizedBox(height: 4),
                  Text('${exercise.defaultSets} sets x ${exercise.defaultReps} reps',
                    style: const TextStyle(fontSize: 12)),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.liveWorkout,
                  arguments: {'exerciseType': exercise.name},
                );
              },
            ),
          );
        },
      ),
    );
  }
}
