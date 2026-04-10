import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/exercise_model.dart';

class WorkoutSelectionScreen extends StatelessWidget {
  const WorkoutSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exercises = ExerciseModel.getDefaultExercises();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text('Select Exercise', style: GoogleFonts.barlow(
          fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
        )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        itemCount: exercises.length,
        itemBuilder: (context, i) {
          final e = exercises[i];
          final color = AppColors.exerciseColor(e.name);
          return GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.liveWorkout, arguments: {'exerciseType': e.name},
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: color.withOpacity(0.15),
                    ),
                    child: Icon(_iconFor(e.name), color: color, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.name, style: GoogleFonts.barlow(
                          fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                        )),
                        const SizedBox(height: 2),
                        Text(e.description, style: GoogleFonts.barlow(
                          fontSize: 12, color: AppColors.textSecondary,
                        ), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Wrap(spacing: 6, children: [
                          _chip('${e.defaultSets} Sets', color),
                          _chip('${e.defaultReps} Reps', color),
                          _chip(e.difficulty, color),
                          _chip(e.category, color),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.play_circle_rounded, color: color, size: 36),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _chip(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: GoogleFonts.barlow(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
  );

  IconData _iconFor(String name) {
    switch (name) {
      case 'Squats': return Icons.accessibility_new_rounded;
      case 'Push-ups': return Icons.fitness_center_rounded;
      case 'Bicep Curls': return Icons.sports_gymnastics_rounded;
      case 'Shoulder Press': return Icons.sports_handball_rounded;
      case 'Lunges': return Icons.directions_walk_rounded;
      case 'Planks': return Icons.self_improvement_rounded;
      default: return Icons.fitness_center_rounded;
    }
  }
}
