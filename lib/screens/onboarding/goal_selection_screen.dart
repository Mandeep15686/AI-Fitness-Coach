import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/onboarding_provider.dart';

class GoalSelectionScreen extends StatelessWidget {
  const GoalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Goal')),
      body: ListView(
        children: [
          _buildGoalTile(context, 'Weight Loss'),
          _buildGoalTile(context, 'Muscle Building'),
          _buildGoalTile(context, 'Stay Active & Healthy'),
          _buildGoalTile(context, 'Improve Endurance'),
          _buildGoalTile(context, 'Flexibility & Mobility'),
        ],
      ),
    );
  }

  Widget _buildGoalTile(BuildContext context, String title) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
    return ListTile(
      title: Text(title),
      onTap: () {
        onboardingProvider.setGoal(title);
        Navigator.of(context).pushNamed(AppRoutes.fitnessLevel);
      },
    );
  }
}
