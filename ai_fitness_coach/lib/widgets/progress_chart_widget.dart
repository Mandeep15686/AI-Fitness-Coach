import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/workout_model.dart';
import '../core/constants/colors.dart';

class ProgressChartWidget extends StatelessWidget {
  final List<WorkoutModel> workouts;

  const ProgressChartWidget({super.key, required this.workouts});

  @override
  Widget build(BuildContext context) {
    // Group calories by date
    final Map<String, double> dailyCals = {};
    for (final w in workouts) {
      final key = '${w.startTime.month}/${w.startTime.day}';
      dailyCals[key] = (dailyCals[key] ?? 0) + w.caloriesBurned;
    }

    // Take last 7 entries
    final entries = dailyCals.entries.toList().reversed.take(7).toList().reversed.toList();
    final maxVal = entries.isEmpty ? 1.0 : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calories Burned', style: GoogleFonts.barlow(
            fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
          )),
          const SizedBox(height: 4),
          Text('Last 7 days', style: GoogleFonts.barlow(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No data yet', style: GoogleFonts.barlow(color: AppColors.textHint))),
            )
          else
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: entries.map((e) {
                  final frac = (e.value / maxVal).clamp(0.02, 1.0);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(e.value.toInt().toString(), style: GoogleFonts.barlow(
                            fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.w600,
                          )),
                          const SizedBox(height: 4),
                          Flexible(
                            child: FractionallySizedBox(
                              heightFactor: frac,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.primary, AppColors.secondary],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(e.key, style: GoogleFonts.barlow(
                            fontSize: 9, color: AppColors.textSecondary,
                          )),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
