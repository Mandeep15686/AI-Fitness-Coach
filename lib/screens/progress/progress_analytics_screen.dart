import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/progress_chart_widget.dart';

class ProgressAnalyticsScreen extends StatefulWidget {
  const ProgressAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<ProgressAnalyticsScreen> createState() => _ProgressAnalyticsScreenState();
}

class _ProgressAnalyticsScreenState extends State<ProgressAnalyticsScreen> {
  Map<String, dynamic>? _statistics;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      final stats = await workoutProvider.getStatistics(authProvider.currentUser!.uid);
      setState(() => _statistics = stats);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Analytics'),
      ),
      body: _statistics == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total Workouts',
                          value: '${_statistics!['totalWorkouts'] ?? 0}',
                          icon: Icons.fitness_center,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          title: 'Total Reps',
                          value: '${_statistics!['totalReps'] ?? 0}',
                          icon: Icons.repeat,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Calories Burned',
                          value: '${(_statistics!['totalCalories'] ?? 0).toStringAsFixed(0)}',
                          icon: Icons.local_fire_department,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          title: 'Total Time (min)',
                          value: '${_statistics!['totalDurationMinutes'] ?? 0}',
                          icon: Icons.timer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Progress chart
                  Text('Weekly Progress',
                    style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  Consumer<WorkoutProvider>(
                    builder: (context, provider, child) {
                      return ProgressChartWidget(workouts: provider.workouts);
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
