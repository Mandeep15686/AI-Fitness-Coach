import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// BUG FIX: Correct relative imports (splash_screen.dart is in lib/screens/, not a subdirectory)
import '../core/routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../core/constants/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.7, curve: Curves.elasticOut)),
    );
    _ctrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigate();
    });
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final route = auth.isAuthenticated ? AppRoutes.dashboard : AppRoutes.welcome;
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Opacity(
            opacity: _fadeAnim.value,
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      size: 52,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'AI FITNESS',
                    style: GoogleFonts.barlow(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: 4,
                    ),
                  ),
                  Text(
                    'COACH',
                    style: GoogleFonts.barlow(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      color: AppColors.primary,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: 64),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
