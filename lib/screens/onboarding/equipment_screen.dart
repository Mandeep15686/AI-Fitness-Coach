import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/onboarding_provider.dart';

class EquipmentScreen extends StatelessWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipment Available')),
      body: ListView(
        children: [
          _buildEquipmentTile(context, 'No equipment (bodyweight)'),
          _buildEquipmentTile(context, 'Dumbbells'),
          _buildEquipmentTile(context, 'Resistance bands'),
          _buildEquipmentTile(context, 'Full gym access'),
        ],
      ),
    );
  }

  Widget _buildEquipmentTile(BuildContext context, String title) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
    return ListTile(
      title: Text(title),
      onTap: () {
        onboardingProvider.setEquipment(title);
        Navigator.of(context).pushNamed(AppRoutes.timeAvailability);
      },
    );
  }
}
