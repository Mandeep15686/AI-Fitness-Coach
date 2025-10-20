import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/workout_card_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        workoutProvider.loadWorkouts(authProvider.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Fitness Coach'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
          ),
        ],
      ),
      body: Consumer2<AuthProvider, WorkoutProvider>(
        builder: (context, authProvider, workoutProvider, child) {
          final user = authProvider.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello, ${user?.name ?? "User"}!',
                          style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Text('Ready to workout today?',
                          style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Start Workout button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.workoutSelection),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Workout'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Progress button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.progress),
                    icon: const Icon(Icons.analytics),
                    label: const Text('View Progress'),
                  ),
                ),
                const SizedBox(height: 30),

                // Recent workouts
                Text('Recent Workouts',
                  style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 10),

                if (workoutProvider.workouts.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text('No workouts yet. Start your first workout!'),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: workoutProvider.workouts.take(5).length,
                    itemBuilder: (context, index) {
                      return WorkoutCardWidget(
                        workout: workoutProvider.workouts[index],
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
