import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, auth, _) {
      final user = auth.currentUser;
      if (user == null) {
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: Center(child: Text('Not signed in', style: GoogleFonts.barlow(color: AppColors.textSecondary))),
        );
      }
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.bg,
          title: Text('Profile', style: GoogleFonts.barlow(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            // Avatar
            Center(child: Column(children: [
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 20)],
                ),
                child: Center(child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: GoogleFonts.barlow(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.textOnPrimary),
                )),
              ),
              const SizedBox(height: 14),
              Text(user.name, style: GoogleFonts.barlow(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Text(user.email, style: GoogleFonts.barlow(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(user.fitnessLevel, style: GoogleFonts.barlow(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ])),
            const SizedBox(height: 28),

            // Body stats
            _sectionTitle('Body Stats'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _statBox('${user.age}', 'Age', 'yrs')),
              const SizedBox(width: 10),
              Expanded(child: _statBox('${user.height.toInt()}', 'Height', 'cm')),
              const SizedBox(width: 10),
              Expanded(child: _statBox(user.weight.toStringAsFixed(1), 'Weight', 'kg')),
              const SizedBox(width: 10),
              Expanded(child: _statBox(user.bmi.toStringAsFixed(1), 'BMI', '')),
            ]),
            const SizedBox(height: 24),

            // Editable fields
            _sectionTitle('Fitness Profile'),
            const SizedBox(height: 10),
            _editTile(context, 'Fitness Goal', user.fitnessGoal, Icons.flag_rounded, AppColors.primary, (val) {
              auth.updateProfile(user.copyWith(fitnessGoal: val));
            }),
            const SizedBox(height: 10),
            _editTile(context, 'Fitness Level', user.fitnessLevel, Icons.bar_chart_rounded, AppColors.secondary, (val) {
              auth.updateProfile(user.copyWith(fitnessLevel: val));
            }),
            const SizedBox(height: 10),
            _editTile(context, 'Weight (kg)', user.weight.toString(), Icons.monitor_weight_outlined, AppColors.accent, (val) {
              final d = double.tryParse(val);
              if (d != null) auth.updateProfile(user.copyWith(weight: d));
            }),
            const SizedBox(height: 28),

            // Sign out
            ElevatedButton.icon(
              onPressed: () async {
                await auth.signOut();
                if (context.mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error.withOpacity(0.12),
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withOpacity(0.4)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    });
  }

  Widget _sectionTitle(String t) => Text(t, style: GoogleFonts.barlow(
    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5,
  ));

  Widget _statBox(String val, String label, String unit) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(val, style: GoogleFonts.barlow(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      if (unit.isNotEmpty) Text(unit, style: GoogleFonts.barlow(fontSize: 10, color: AppColors.primary)),
      Text(label, style: GoogleFonts.barlow(fontSize: 10, color: AppColors.textSecondary)),
    ]),
  );

  Widget _editTile(BuildContext context, String label, String value, IconData icon, Color color, Function(String) onSave) =>
    GestureDetector(
      onTap: () => _showEdit(context, label, value, onSave),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: GoogleFonts.barlow(fontSize: 11, color: AppColors.textSecondary)),
            Text(value, style: GoogleFonts.barlow(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ])),
          const Icon(Icons.edit_outlined, size: 16, color: AppColors.textHint),
        ]),
      ),
    );

  void _showEdit(BuildContext context, String label, String current, Function(String) onSave) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text('Edit $label', style: GoogleFonts.barlow(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl, autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { onSave(ctrl.text); Navigator.pop(context); },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
