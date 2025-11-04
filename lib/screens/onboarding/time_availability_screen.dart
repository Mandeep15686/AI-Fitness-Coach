import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/onboarding_provider.dart';

class TimeAvailabilityScreen extends StatelessWidget {
  const TimeAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time Availability')),
      body: ListView(
        children: [
          _buildTimeTile(context, '15 minutes/day'),
          _buildTimeTile(context, '30 minutes/day'),
          _buildTimeTile(context, '45-60 minutes/day'),
        ],
      ),
    );
  }

  Widget _buildTimeTile(BuildContext context, String title) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
    return ListTile(
      title: Text(title),
      onTap: () {
        onboardingProvider.setTimeAvailability(title);
        Navigator.of(context).pushNamed(AppRoutes.workoutLocation);
      },
    );
  }
}
