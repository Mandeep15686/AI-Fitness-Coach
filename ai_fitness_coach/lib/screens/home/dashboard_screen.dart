import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/exercise_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/workout_card_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final workouts = Provider.of<WorkoutProvider>(context, listen: false);
      if (auth.currentUser != null) workouts.loadWorkouts(auth.currentUser!.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: _navIndex,
        children: const [
          _HomeTab(),
          _WorkoutTab(),
          _ProgressTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() => Container(
    decoration: BoxDecoration(
      color: AppColors.bgSurface,
      border: const Border(top: BorderSide(color: AppColors.bgCardElevated, width: 1)),
    ),
    child: BottomNavigationBar(
      currentIndex: _navIndex,
      onTap: (i) => setState(() => _navIndex = i),
      backgroundColor: Colors.transparent,
      elevation: 0,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: GoogleFonts.barlow(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.barlow(fontSize: 11),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.fitness_center_outlined), activeIcon: Icon(Icons.fitness_center_rounded), label: 'Workout'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart_rounded), label: 'Progress'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    ),
  );
}

// ─── Home Tab ────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Good Morning' : now.hour < 17 ? 'Good Afternoon' : 'Good Evening';

    return Consumer2<AuthProvider, WorkoutProvider>(
      builder: (context, auth, workoutProvider, _) {
        final user = auth.currentUser;
        final workouts = workoutProvider.workouts;
        final totalCals = workouts.fold<double>(0, (s, w) => s + w.caloriesBurned);
        final totalReps = workouts.fold<int>(0, (s, w) => s + w.repetitions);

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.bg,
              floating: true,
              pinned: false,
              expandedHeight: 0,
              toolbarHeight: 70,
              flexibleSpace: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(greeting, style: GoogleFonts.barlow(fontSize: 13, color: AppColors.textSecondary)),
                          Text(user?.name ?? 'Athlete', style: GoogleFonts.barlow(
                            fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
                          )),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.bgCard,
                          border: Border.all(color: AppColors.bgCardElevated),
                        ),
                        child: const Icon(Icons.settings_outlined, color: AppColors.textSecondary, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(delegate: SliverChildListDelegate([
                // Hero banner
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E676), Color(0xFF00D4FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 24, offset: const Offset(0, 8),
                    )],
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ready to\nCrush It?', style: GoogleFonts.barlow(
                            fontSize: 26, fontWeight: FontWeight.w900,
                            color: AppColors.textOnPrimary, height: 1.2,
                          )),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.workoutSelection),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('Start Workout →', style: GoogleFonts.barlow(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: AppColors.textOnPrimary,
                              )),
                            ),
                          ),
                        ],
                      )),
                      const Icon(Icons.bolt_rounded, size: 80, color: Colors.white24),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Stats row
                Text('Your Stats', style: GoogleFonts.barlow(
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                )),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _statCard('${workouts.length}', 'Workouts', Icons.fitness_center_rounded, AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('$totalReps', 'Total Reps', Icons.repeat_rounded, AppColors.secondary)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('${totalCals.toInt()}', 'Calories', Icons.local_fire_department_rounded, AppColors.accent)),
                ]),
                const SizedBox(height: 28),

                // Quick exercises
                Text('Quick Start', style: GoogleFonts.barlow(
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                )),
                const SizedBox(height: 12),
                SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ExerciseModel.getDefaultExercises().map((e) => GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.liveWorkout, arguments: {'exerciseType': e.name},
                      ),
                      child: Container(
                        width: 90, height: 90,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: AppColors.exerciseColor(e.name).withValues(alpha: 0.12),
                          border: Border.all(color: AppColors.exerciseColor(e.name).withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_exerciseIcon(e.name), color: AppColors.exerciseColor(e.name), size: 28),
                            const SizedBox(height: 6),
                            Text(e.name.split(' ').first, style: GoogleFonts.barlow(
                              fontSize: 11, fontWeight: FontWeight.w600,
                              color: AppColors.exerciseColor(e.name),
                            )),
                          ],
                        ),
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 28),

                // Recent workouts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Workouts', style: GoogleFonts.barlow(
                      fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                    )),
                    if (workouts.isNotEmpty)
                      TextButton(
                        onPressed: () {},
                        child: Text('See All', style: GoogleFonts.barlow(
                          fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600,
                        )),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (workoutProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (workouts.isEmpty)
                  _emptyWorkouts(context)
                else
                  ...workouts.take(5).map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: WorkoutCardWidget(workout: w),
                  )),
                const SizedBox(height: 100),
              ])),
            ),
          ],
        );
      },
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.barlow(
          fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
        )),
        Text(label, style: GoogleFonts.barlow(
          fontSize: 11, color: AppColors.textSecondary,
        ), textAlign: TextAlign.center),
      ],
    ),
  );

  Widget _emptyWorkouts(BuildContext context) => Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        const Icon(Icons.fitness_center_rounded, size: 48, color: AppColors.textHint),
        const SizedBox(height: 16),
        Text('No workouts yet', style: GoogleFonts.barlow(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        )),
        const SizedBox(height: 8),
        Text('Start your first workout to see your history here', style: GoogleFonts.barlow(
          fontSize: 14, color: AppColors.textSecondary,
        ), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.workoutSelection),
          child: const Text('Start Now'),
        ),
      ],
    ),
  );

  IconData _exerciseIcon(String name) {
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

// ─── Workout Tab ─────────────────────────────────────────────────────────────
class _WorkoutTab extends StatelessWidget {
  const _WorkoutTab();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const _WorkoutSelectionInner(),
      ),
    );
  }
}

class _WorkoutSelectionInner extends StatelessWidget {
  const _WorkoutSelectionInner();

  @override
  Widget build(BuildContext context) {
    final exercises = ExerciseModel.getDefaultExercises();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Choose Exercise', style: GoogleFonts.barlow(
          fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
        )),
        backgroundColor: AppColors.bg,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        itemCount: exercises.length,
        itemBuilder: (context, i) {
          final e = exercises[i];
          final color = AppColors.exerciseColor(e.name);
          return GestureDetector(
            onTap: () => Navigator.of(context, rootNavigator: true).pushNamed(
              AppRoutes.liveWorkout, arguments: {'exerciseType': e.name},
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: color.withValues(alpha: 0.15),
                    ),
                    child: Icon(_iconFor(e.name), color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.name, style: GoogleFonts.barlow(
                          fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                        )),
                        const SizedBox(height: 2),
                        Text(e.category, style: GoogleFonts.barlow(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Row(children: [
                          _chip('${e.defaultSets} Sets', color),
                          const SizedBox(width: 8),
                          _chip('${e.defaultReps} Reps', color),
                          const SizedBox(width: 8),
                          _chip(e.difficulty, color),
                        ]),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
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
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
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

// ─── Progress Tab ─────────────────────────────────────────────────────────────
class _ProgressTab extends StatefulWidget {
  const _ProgressTab();

  @override
  State<_ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<_ProgressTab> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

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
      if (mounted) setState(() { _stats = stats; _loading = false; });
    } else {
      if (mounted) setState(() { _stats = {}; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        automaticallyImplyLeading: false,
        title: Text('Progress', style: GoogleFonts.barlow(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ),
      body: _loading
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
                      childAspectRatio: 1.4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _statTile('${_stats?['totalWorkouts'] ?? 0}', 'Workouts', Icons.fitness_center_rounded, AppColors.primary),
                        _statTile('${_stats?['totalReps'] ?? 0}', 'Total Reps', Icons.repeat_rounded, AppColors.secondary),
                        _statTile(
                          '${((_stats?['totalCalories'] ?? 0) as num).toStringAsFixed(0)}',
                          'Calories', Icons.local_fire_department_rounded, AppColors.accent,
                        ),
                        _statTile('${_stats?['totalDurationMinutes'] ?? 0}m', 'Duration', Icons.timer_rounded, AppColors.warning),
                      ],
                    ),
                    const SizedBox(height: 28),

                    Text('Workout History', style: GoogleFonts.barlow(
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
                      ...wp.workouts.take(10).map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: WorkoutCardWidget(workout: w),
                      )),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _statTile(String value, String label, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(value, style: GoogleFonts.barlow(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          Text(label, style: GoogleFonts.barlow(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ],
    ),
  );
}

// ─── Profile Tab ─────────────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.currentUser;
        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            backgroundColor: AppColors.bg,
            automaticallyImplyLeading: false,
            title: Text('Profile', style: GoogleFonts.barlow(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
              ),
            ],
          ),
          body: user == null
              ? Center(child: Text('Not signed in', style: GoogleFonts.barlow(color: AppColors.textSecondary)))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // Avatar
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 90, height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20)],
                            ),
                            child: Center(child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                              style: GoogleFonts.barlow(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.textOnPrimary),
                            )),
                          ),
                          const SizedBox(height: 16),
                          Text(user.name, style: GoogleFonts.barlow(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          Text(user.email, style: GoogleFonts.barlow(fontSize: 14, color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Text(user.fitnessLevel, style: GoogleFonts.barlow(
                              fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600,
                            )),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Body stats grid
                    Text('Body Stats', style: GoogleFonts.barlow(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _bodyStatCard('${user.age}', 'Age', 'yrs')),
                      const SizedBox(width: 12),
                      Expanded(child: _bodyStatCard('${user.height.toInt()}', 'Height', 'cm')),
                      const SizedBox(width: 12),
                      Expanded(child: _bodyStatCard('${user.weight.toStringAsFixed(1)}', 'Weight', 'kg')),
                      const SizedBox(width: 12),
                      Expanded(child: _bodyStatCard(user.bmi.toStringAsFixed(1), 'BMI', '')),
                    ]),
                    const SizedBox(height: 28),

                    // Goal
                    Text('Fitness Goal', style: GoogleFonts.barlow(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.flag_rounded, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(user.fitnessGoal, style: GoogleFonts.barlow(fontSize: 16, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Actions
                    _actionTile(context, Icons.privacy_tip_outlined, 'Privacy Settings', AppRoutes.privacySettings),
                    _actionTile(context, Icons.security_outlined, 'Security', AppRoutes.securitySettings),
                    _actionTile(context, Icons.restaurant_menu_outlined, 'Meal Plan', AppRoutes.mealPlan),
                    const SizedBox(height: 16),

                    // Sign out
                    ElevatedButton.icon(
                      onPressed: () async {
                        await auth.signOut();
                        if (context.mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sign Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error.withValues(alpha: 0.15),
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
        );
      },
    );
  }

  Widget _bodyStatCard(String value, String label, String unit) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12)),
    child: Column(
      children: [
        Text(value, style: GoogleFonts.barlow(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        Text(unit, style: GoogleFonts.barlow(fontSize: 10, color: AppColors.primary)),
        Text(label, style: GoogleFonts.barlow(fontSize: 11, color: AppColors.textSecondary)),
      ],
    ),
  );

  Widget _actionTile(BuildContext context, IconData icon, String label, String route) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      tileColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(label, style: GoogleFonts.barlow(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
      onTap: () => Navigator.of(context).pushNamed(route),
    ),
  );
}
