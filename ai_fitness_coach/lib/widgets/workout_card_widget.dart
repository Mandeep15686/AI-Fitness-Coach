import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/workout_model.dart';
import '../core/constants/colors.dart';

class WorkoutCardWidget extends StatelessWidget {
  final WorkoutModel workout;

  const WorkoutCardWidget({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.exerciseColor(workout.exerciseType);
    final duration = workout.durationSeconds;
    final mins = duration ~/ 60;
    final secs = duration % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withOpacity(0.14),
            ),
            child: Icon(_iconFor(workout.exerciseType), color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workout.exerciseType, style: GoogleFonts.barlow(
                  fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                )),
                const SizedBox(height: 4),
                Row(children: [
                  _pill('${workout.repetitions} reps', AppColors.secondary),
                  const SizedBox(width: 6),
                  _pill('${workout.sets} sets', AppColors.primary),
                  const SizedBox(width: 6),
                  _pill(mins > 0 ? '${mins}m ${secs}s' : '${secs}s', AppColors.warning),
                ]),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${workout.caloriesBurned.toStringAsFixed(0)}', style: GoogleFonts.barlow(
                fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.accent,
              )),
              Text('kcal', style: GoogleFonts.barlow(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(
                '${workout.startTime.day}/${workout.startTime.month}',
                style: GoogleFonts.barlow(fontSize: 11, color: AppColors.textHint),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
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
