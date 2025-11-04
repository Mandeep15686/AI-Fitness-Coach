import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/privacy_provider.dart';
import 'dart:convert';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final privacyProvider = Provider.of<PrivacyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
      ),
      body: privacyProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  title: const Text('Explicit Consent'),
                  subtitle: const Text(
                      'I agree to the processing of my personal health data.'),
                  value: privacyProvider.consentGiven,
                  onChanged: (bool value) {
                    privacyProvider.updateConsentStatus(value);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Right to Deletion'),
                  subtitle: const Text('Request to delete your account and data.'),
                  onTap: () async {
                    final confirmed = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Account'),
                        content: const Text(
                            'Are you sure you want to delete your account? This action is irreversible.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed ?? false) {
                      final success = await privacyProvider.deleteUserData();
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Account deleted successfully')),
                        );
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(privacyProvider.errorMessage ??
                                'Failed to delete account'),
                          ),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Data Export'),
                  subtitle: const Text('Download a copy of your data.'),
                  onTap: () async {
                    final data = await privacyProvider.exportUserData();
                    if (data != null && context.mounted) {
                      // For demonstration, we just show the data in a dialog.
                      // In a real app, you would save this to a file.
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Your Data'),
                          content: SingleChildScrollView(
                            child: Text(const JsonEncoder.withIndent('  ')
                                .convert(data)),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(privacyProvider.errorMessage ??
                              'Failed to export data'),
                        ),
                      );
                    }
                  },
                ),
                // CCPA Compliance
                SwitchListTile(
                  title: const Text('Do Not Sell My Personal Information'),
                  subtitle: const Text(
                      'Opt out of the sale of your personal information.'),
                  value: false, // Replace with actual value
                  onChanged: (bool value) {
                    // In a real app, you would have a mechanism to handle this.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Your request has been recorded.')),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
