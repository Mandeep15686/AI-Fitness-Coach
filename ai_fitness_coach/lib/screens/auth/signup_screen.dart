import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  String _goal = 'Weight Loss';
  String _level = 'Beginner';
  bool _obscure = true;
  int _step = 0; // Multi-step form

  final List<String> _goals = ['Weight Loss', 'Muscle Gain', 'General Fitness', 'Endurance'];
  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    _ageCtrl.dispose(); _heightCtrl.dispose(); _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.signUp(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      name: _nameCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text) ?? 25,
      height: double.tryParse(_heightCtrl.text) ?? 170,
      weight: double.tryParse(_weightCtrl.text) ?? 70,
      fitnessGoal: _goal,
      fitnessLevel: _level,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.errorMessage ?? 'Signup failed'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Create Account', style: GoogleFonts.barlow(
          fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        )),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step indicator
                Row(
                  children: List.generate(3, (i) => Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: i <= _step ? AppColors.primary : AppColors.bgCard,
                      ),
                    ),
                  )),
                ),
                const SizedBox(height: 32),

                if (_step == 0) ..._step0(),
                if (_step == 1) ..._step1(),
                if (_step == 2) ..._step2(),

                const SizedBox(height: 32),
                if (_step < 2)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _step++),
                      child: Text('Continue', style: GoogleFonts.barlow(
                        fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textOnPrimary,
                      )),
                    ),
                  )
                else
                  Consumer<AuthProvider>(builder: (_, auth, __) => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _signup,
                      child: auth.isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.textOnPrimary))
                          : Text('Create Account', style: GoogleFonts.barlow(
                              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textOnPrimary,
                            )),
                    ),
                  )),

                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: GoogleFonts.barlow(color: AppColors.textSecondary, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: GoogleFonts.barlow(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _step0() => [
    Text('Personal Info', style: GoogleFonts.barlow(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
    const SizedBox(height: 24),
    _field('Full Name', _nameCtrl, Icons.person_outline, validator: Validators.required),
    const SizedBox(height: 16),
    _field('Email', _emailCtrl, Icons.email_outlined, type: TextInputType.emailAddress, validator: Validators.email),
    const SizedBox(height: 16),
    TextFormField(
      controller: _passCtrl,
      obscureText: _obscure,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: Validators.password,
    ),
  ];

  List<Widget> _step1() => [
    Text('Body Stats', style: GoogleFonts.barlow(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
    const SizedBox(height: 24),
    _field('Age', _ageCtrl, Icons.cake_outlined, type: TextInputType.number, validator: Validators.required),
    const SizedBox(height: 16),
    _field('Height (cm)', _heightCtrl, Icons.height, type: TextInputType.number, validator: Validators.required),
    const SizedBox(height: 16),
    _field('Weight (kg)', _weightCtrl, Icons.monitor_weight_outlined, type: TextInputType.number, validator: Validators.required),
  ];

  List<Widget> _step2() => [
    Text('Your Goals', style: GoogleFonts.barlow(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
    const SizedBox(height: 8),
    Text('Help us personalize your plan', style: GoogleFonts.barlow(fontSize: 14, color: AppColors.textSecondary)),
    const SizedBox(height: 24),
    Text('Fitness Goal', style: GoogleFonts.barlow(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
    const SizedBox(height: 8),
    ..._goals.map((g) => _radioCard(g, _goal, (v) => setState(() => _goal = v!))),
    const SizedBox(height: 20),
    Text('Experience Level', style: GoogleFonts.barlow(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
    const SizedBox(height: 8),
    ..._levels.map((l) => _radioCard(l, _level, (v) => setState(() => _level = v!))),
  ];

  Widget _field(String hint, TextEditingController ctrl, IconData icon,
      {TextInputType type = TextInputType.text, String? Function(String?)? validator}) =>
    TextFormField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
      validator: validator,
    );

  Widget _radioCard(String value, String groupValue, void Function(String?) onChanged) => GestureDetector(
    onTap: () => onChanged(value),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: value == groupValue ? AppColors.primary.withValues(alpha: 0.12) : AppColors.bgCard,
        border: Border.all(
          color: value == groupValue ? AppColors.primary : AppColors.textHint,
          width: value == groupValue ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value == groupValue ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: value == groupValue ? AppColors.primary : AppColors.textHint,
                width: 2,
              ),
            ),
            child: value == groupValue
                ? const Icon(Icons.check, size: 12, color: AppColors.textOnPrimary)
                : null,
          ),
          const SizedBox(width: 12),
          Text(value, style: GoogleFonts.barlow(
            fontSize: 15, fontWeight: FontWeight.w500,
            color: value == groupValue ? AppColors.primary : AppColors.textPrimary,
          )),
        ],
      ),
    ),
  );
}
