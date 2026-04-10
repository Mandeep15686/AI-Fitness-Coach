// Theme switcher - simplified to avoid asset crash (icons were missing)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../core/constants/colors.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = Provider.of<ThemeProvider>(context);
    return Switch(
      value: tp.isDarkMode,
      onChanged: (_) => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
      activeColor: AppColors.primary,
      inactiveThumbColor: AppColors.textSecondary,
    );
  }
}
