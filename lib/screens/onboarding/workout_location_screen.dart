import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/onboarding_provider.dart';

class WorkoutLocationScreen extends StatelessWidget {
  const WorkoutLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Location')),
      body: ListView(
        children: [
          _buildLocationTile(context, 'Home'),
          _buildLocationTile(context, 'Gym'),
          _buildLocationTile(context, 'Outdoors'),
          _buildLocationTile(context, 'Mix of all'),
        ],
      ),
    );
  }

  Widget _buildLocationTile(BuildContext context, String title) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
    return ListTile(
      title: Text(title),
      onTap: () {
        onboardingProvider.setWorkoutLocation(title);
        // In a real app, you would now use the collected data to customize the user experience.
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.dashboard,
          (route) => false,
        );
      },
    );
  }
}
