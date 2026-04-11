import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../providers/privacy_provider.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text('Privacy', style: GoogleFonts.barlow(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<PrivacyProvider>(
        builder: (context, privacy, _) => privacy.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                children: [
                  // Consent toggle
                  Container(
                    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
                    child: SwitchListTile(
                      title: Text('Data Processing Consent', style: GoogleFonts.barlow(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                      subtitle: Text('Allow processing of personal health data', style: GoogleFonts.barlow(fontSize: 12, color: AppColors.textSecondary)),
                      value: privacy.consentGiven,
                      onChanged: (v) => privacy.updateConsentStatus(v),
                      activeColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Export data
                  Container(
                    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      leading: const Icon(Icons.download_rounded, color: AppColors.secondary),
                      title: Text('Export My Data', style: GoogleFonts.barlow(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
                      onTap: () async {
                        final data = await privacy.exportUserData();
                        if (data != null && context.mounted) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: AppColors.bgCard,
                              title: Text('Your Data', style: GoogleFonts.barlow(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                              content: SingleChildScrollView(child: Text(
                                const JsonEncoder.withIndent('  ').convert(data),
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'monospace'),
                              )),
                              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Delete account
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                      title: Text('Delete Account', style: GoogleFonts.barlow(fontSize: 15, color: AppColors.error, fontWeight: FontWeight.w500)),
                      subtitle: Text('This action is permanent', style: GoogleFonts.barlow(fontSize: 12, color: AppColors.error.withValues(alpha: 0.7))),
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: AppColors.bgCard,
                            title: Text('Delete Account?', style: GoogleFonts.barlow(color: AppColors.error, fontWeight: FontWeight.w700)),
                            content: Text('All your data will be permanently deleted. This cannot be undone.', style: GoogleFonts.barlow(color: AppColors.textSecondary)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true && context.mounted) {
                          final ok = await privacy.deleteUserData();
                          if (ok && context.mounted) {
                            Navigator.of(context).popUntil((r) => r.isFirst);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
