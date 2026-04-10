import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/routes/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text('Settings', style: GoogleFonts.barlow(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        children: [
          _group('Account', [
            _tile(context, Icons.security_outlined, 'Security', AppRoutes.securitySettings, AppColors.primary),
            _tile(context, Icons.privacy_tip_outlined, 'Privacy', AppRoutes.privacySettings, AppColors.secondary),
          ]),
          const SizedBox(height: 16),
          _group('Legal', [
            _tile(context, Icons.article_outlined, 'Terms of Service', null, AppColors.textSecondary, onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms of Service — coming soon')),
              );
            }),
          ]),
          const SizedBox(height: 24),
          Center(child: Text('AI Fitness Coach v1.0.0', style: GoogleFonts.barlow(
            fontSize: 12, color: AppColors.textHint,
          ))),
        ],
      ),
    );
  }

  Widget _group(String title, List<Widget> tiles) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(title.toUpperCase(), style: GoogleFonts.barlow(
          fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1,
        )),
      ),
      Container(
        decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
        child: Column(children: tiles),
      ),
    ],
  );

  Widget _tile(BuildContext context, IconData icon, String title, String? route, Color color, {VoidCallback? onTap}) =>
    ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: Icon(icon, color: color, size: 22),
      title: Text(title, style: GoogleFonts.barlow(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
      onTap: onTap ?? (route != null ? () => Navigator.of(context).pushNamed(route) : null),
    );
}
