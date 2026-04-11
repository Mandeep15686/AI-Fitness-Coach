import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.signIn(email: _emailCtrl.text.trim(), password: _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } else {
      _showError(auth.errorMessage ?? 'Login failed. Please try again.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                // Header
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    boxShadow: [BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 20,
                    )],
                  ),
                  child: const Icon(Icons.bolt_rounded, color: AppColors.textOnPrimary, size: 30),
                ),
                const SizedBox(height: 28),
                Text('Welcome\nBack', style: GoogleFonts.barlow(
                  fontSize: 40, fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary, height: 1.1,
                )),
                const SizedBox(height: 8),
                Text('Sign in to continue your journey', style: GoogleFonts.barlow(
                  fontSize: 16, color: AppColors.textSecondary,
                )),
                const SizedBox(height: 48),

                // Email
                _label('Email'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'you@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: 20),

                // Password
                _label('Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 36),

                // Login button
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.textOnPrimary))
                          : Text('Sign In', style: GoogleFonts.barlow(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textOnPrimary)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: GoogleFonts.barlow(color: AppColors.textSecondary, fontSize: 14)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.signup),
                      child: Text('Sign Up', style: GoogleFonts.barlow(
                        color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14,
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: GoogleFonts.barlow(
    fontSize: 13, fontWeight: FontWeight.w600,
    color: AppColors.textSecondary, letterSpacing: 0.5,
  ));
}
