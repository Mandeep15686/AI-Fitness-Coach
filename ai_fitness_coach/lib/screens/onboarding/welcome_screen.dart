import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/routes/app_routes.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),

                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text('AI-POWERED FITNESS', style: GoogleFonts.barlow(
                      fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700, letterSpacing: 1.5,
                    )),
                  ),
                  const SizedBox(height: 20),

                  Text('Train Smarter.\nNot Harder.', style: GoogleFonts.barlow(
                    fontSize: 44, fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary, height: 1.1,
                  )),
                  const SizedBox(height: 16),
                  Text(
                    'Real-time pose detection, rep counting, and personalized coaching — right from your phone.',
                    style: GoogleFonts.barlow(fontSize: 16, color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 48),

                  // Features
                  ...[
                    ('🤖', 'AI Pose Detection', 'Real-time body tracking'),
                    ('🔁', 'Rep Counting', 'Automatic & accurate'),
                    ('🔥', 'Calorie Tracking', 'MET-based estimation'),
                  ].map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(children: [
                      Text(f.$1, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(f.$2, style: GoogleFonts.barlow(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        Text(f.$3, style: GoogleFonts.barlow(fontSize: 12, color: AppColors.textSecondary)),
                      ]),
                    ]),
                  )),

                  const Spacer(flex: 3),

                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.signup),
                      child: Text('Get Started Free', style: GoogleFonts.barlow(
                        fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textOnPrimary,
                      )),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.login),
                      child: Text('Sign In', style: GoogleFonts.barlow(
                        fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.primary,
                      )),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
