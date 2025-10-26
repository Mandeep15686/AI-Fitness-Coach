
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
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
              _InfoTile(
                title: 'Age',
                value: '${user.age} years',
                onTap: () =>
                    _showEditDialog(context, 'Age', user.age.toString(), (newValue) {
                  final newAge = int.tryParse(newValue);
                  if (newAge != null) {
                    final updatedUser = user.copyWith(age: newAge);
                    authProvider.updateProfile(updatedUser);
                  }
                }),
              ),
              _InfoTile(
                title: 'Height',
                value: '${user.height.toStringAsFixed(0)} cm',
                onTap: () => _showEditDialog(
                    context, 'Height', user.height.toStringAsFixed(0),
                    (newValue) {
                  final newHeight = double.tryParse(newValue);
                  if (newHeight != null) {
                    final updatedUser = user.copyWith(height: newHeight);
                    authProvider.updateProfile(updatedUser);
                  }
                }),
              ),
              _InfoTile(
                  title: 'Weight',
                  value: '${user.weight.toStringAsFixed(1)} kg',
                  onTap: () => _showEditDialog(
                          context, 'Weight', user.weight.toStringAsFixed(1),
                          (newValue) {
                        final newWeight = double.tryParse(newValue);
                        if (newWeight != null) {
                          final updatedUser = user.copyWith(weight: newWeight);
                          authProvider.updateProfile(updatedUser);
                        }
                      })),
              _InfoTile(
                title: 'BMI',
                value: user.bmi.toStringAsFixed(1),
              ), // BMI is calculated, so not editable
              _InfoTile(
                  title: 'Fitness Goal',
                  value: user.fitnessGoal,
                  onTap: () =>
                      _showEditDialog(context, 'Fitness Goal', user.fitnessGoal,
                          (newValue) {
                        final updatedUser = user.copyWith(fitnessGoal: newValue);
                        authProvider.updateProfile(updatedUser);
                      })),
              _InfoTile(
                title: 'Fitness Level',
                value: user.fitnessLevel,
                onTap: () => _showEditDialog(
                    context, 'Fitness Level', user.fitnessLevel, (newValue) {
                  final updatedUser = user.copyWith(fitnessLevel: newValue);
                  authProvider.updateProfile(updatedUser);
                }),
              ),

              const SizedBox(height: 30),

              // Sign out button
              ElevatedButton.icon(
                onPressed: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.login);
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

  // Helper function to show the edit dialog
  Future<void> _showEditDialog(
    BuildContext context,
    String title,
    String currentValue,
    Function(String) onSave,
  ) async {
    final TextEditingController controller =
        TextEditingController(text: currentValue);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: 'Enter new $title'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _InfoTile({required this.title, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (onTap != null) const SizedBox(width: 8),
            if (onTap != null)
              const Icon(
                Icons.edit,
                size: 16,
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
