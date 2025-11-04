import 'package:ai_fitness_coach/core/routes/app_routes.dart';
import 'package:flutter/material.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.phone_android),
            title: const Text('Two-Factor Authentication'),
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.phoneVerification);
            },
          ),
        ],
      ),
    );
  }
}
