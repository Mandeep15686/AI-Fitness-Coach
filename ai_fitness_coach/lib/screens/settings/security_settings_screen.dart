import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/routes/app_routes.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text('Security', style: GoogleFonts.barlow(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        children: [
          Container(
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: const Icon(Icons.phone_android_rounded, color: AppColors.primary),
              title: Text('Two-Factor Authentication', style: GoogleFonts.barlow(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
              subtitle: Text('Link your phone number', style: GoogleFonts.barlow(fontSize: 12, color: AppColors.textSecondary)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.phoneVerification),
            ),
          ),
        ],
      ),
    );
  }
}
