import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/onboarding_provider.dart';

class FitnessLevelScreen extends StatelessWidget {
  const FitnessLevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Fitness Level')),
      body: ListView(
        children: [
          _buildLevelTile(context, 'Beginner', 'Just starting out'),
          _buildLevelTile(context, 'Intermediate', 'Workout 1-3x/week'),
          _buildLevelTile(context, 'Advanced', 'Workout 4+ times/week'),
        ],
      ),
    );
  }

  Widget _buildLevelTile(BuildContext context, String title, String subtitle) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {
        onboardingProvider.setFitnessLevel(title);
        Navigator.of(context).pushNamed(AppRoutes.equipment);
      },
    );
  }
}
