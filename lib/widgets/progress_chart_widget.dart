import 'package:flutter/material.dart';
import '../models/workout_model.dart';

class ProgressChartWidget extends StatelessWidget {
  final List<WorkoutModel> workouts;

  const ProgressChartWidget({Key? key, required this.workouts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Group workouts by date
    Map<String, double> dailyCalories = {};

    for (var workout in workouts) {
      String date = '${workout.startTime.month}/${workout.startTime.day}';
      dailyCalories[date] = (dailyCalories[date] ?? 0) + workout.caloriesBurned;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Calories Burned',
              style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Simple bar chart representation
            SizedBox(
              height: 200,
              child: dailyCalories.isEmpty
                  ? const Center(child: Text('No data available'))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dailyCalories.length,
                      itemBuilder: (context, index) {
                        final entry = dailyCalories.entries.elementAt(index);
                        final maxCalories = dailyCalories.values.reduce((a, b) => a > b ? a : b);
                        final height = (entry.value / maxCalories) * 150;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('${entry.value.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 10)),
                              const SizedBox(height: 4),
                              Container(
                                width: 40,
                                height: height,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(entry.key, style: const TextStyle(fontSize: 10)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
