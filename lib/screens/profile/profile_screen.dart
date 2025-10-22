import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(child: Text('No user data'));
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Profile header
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person, size: 50),
                    ),
                    const SizedBox(height: 16),
                    Text(user.name,
                      style: Theme.of(context).textTheme.headlineMedium),
                    Text(user.email,
                      style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // User info
              _InfoTile(title: 'Age', value: '${user.age} years'),
              _InfoTile(title: 'Height', value: '${user.height.toStringAsFixed(0)} cm'),
              _InfoTile(title: 'Weight', value: '${user.weight.toStringAsFixed(1)} kg'),
              _InfoTile(title: 'BMI', value: user.bmi.toStringAsFixed(1)),
              _InfoTile(title: 'Fitness Goal', value: user.fitnessGoal),
              _InfoTile(title: 'Fitness Level', value: user.fitnessLevel),

              const SizedBox(height: 30),

              // Sign out button
              ElevatedButton.icon(
                onPressed: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
