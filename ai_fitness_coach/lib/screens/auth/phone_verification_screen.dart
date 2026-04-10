import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _codeSent = false;

  @override
  void dispose() { _phoneCtrl.dispose(); _codeCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.sendOtp(_phoneCtrl.text.trim());
    if (ok && mounted) setState(() => _codeSent = true);
    if (!ok && mounted) _snack(auth.errorMessage ?? 'Failed to send code');
  }

  Future<void> _verify() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.verifyOtpAndLink(_codeCtrl.text.trim());
    if (ok && mounted) { _snack('Phone linked!', ok: true); Navigator.of(context).pop(); }
    if (!ok && mounted) _snack(auth.errorMessage ?? 'Verification failed');
  }

  void _snack(String msg, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: ok ? AppColors.primary : AppColors.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text('Phone Verification', style: GoogleFonts.barlow(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_codeSent ? 'Enter the code sent to your phone' : 'Enter your phone number to receive a verification code',
              style: GoogleFonts.barlow(fontSize: 16, color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            if (!_codeSent) ...[
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: '+1 650-555-1234',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: auth.isLoading ? null : _send,
                child: auth.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.textOnPrimary)) : const Text('Send Code'),
              )),
            ] else ...[
              TextField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: '6-digit code',
                  prefixIcon: Icon(Icons.sms_outlined),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: auth.isLoading ? null : _verify,
                child: auth.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.textOnPrimary)) : const Text('Verify'),
              )),
              const SizedBox(height: 12),
              TextButton(onPressed: () => setState(() => _codeSent = false), child: const Text('← Change number')),
            ],
          ],
        ),
      ),
    );
  }
}
