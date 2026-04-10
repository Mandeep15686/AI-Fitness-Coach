import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../providers/workout_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/progress_chart_widget.dart';
import '../../widgets/workout_card_widget.dart';

class ProgressAnalyticsScreen extends StatefulWidget {
  const ProgressAnalyticsScreen({super.key});

  @override
  State<ProgressAnalyticsScreen> createState() => _ProgressAnalyticsScreenState();
}

class _ProgressAnalyticsScreenState extends State<ProgressAnalyticsScreen> {
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final workouts = Provider.of<WorkoutProvider>(context, listen: false);
    if (auth.currentUser != null) {
      final stats = await workouts.getStatistics(auth.currentUser!.uid);
      if (mounted) setState(() => _stats = stats);
    } else {
      if (mounted) setState(() => _stats = {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text('Analytics', style: GoogleFonts.barlow(
          fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
        )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _stats == null
          ? const Center(child: CircularProgressIndicator())
          : Consumer<WorkoutProvider>(
              builder: (_, wp, __) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats grid
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _statCard('${_stats!['totalWorkouts'] ?? 0}', 'Workouts', Icons.fitness_center_rounded, AppColors.primary),
                        _statCard('${_stats!['totalReps'] ?? 0}', 'Total Reps', Icons.repeat_rounded, AppColors.secondary),
                        _statCard(
                          '${((_stats!['totalCalories'] ?? 0) as num).toStringAsFixed(0)}',
                          'Calories', Icons.local_fire_department_rounded, AppColors.accent,
                        ),
                        _statCard('${_stats!['totalDurationMinutes'] ?? 0}m', 'Duration', Icons.timer_rounded, AppColors.warning),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Chart
                    ProgressChartWidget(workouts: wp.workouts),
                    const SizedBox(height: 24),

                    Text('History', style: GoogleFonts.barlow(
                      fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                    )),
                    const SizedBox(height: 12),

                    if (wp.workouts.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16)),
                        child: Center(child: Text('No workouts yet', style: GoogleFonts.barlow(color: AppColors.textSecondary))),
                      )
                    else
                      ...wp.workouts.map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: WorkoutCardWidget(workout: w),
                      )),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(icon, color: color, size: 24),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: GoogleFonts.barlow(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          Text(label, style: GoogleFonts.barlow(fontSize: 12, color: AppColors.textSecondary)),
        ]),
      ],
    ),
  );
}
