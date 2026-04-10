import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // === DARK ATHLETIC PALETTE ===
  // Backgrounds
  static const Color bg = Color(0xFF0A0A12);
  static const Color bgSurface = Color(0xFF12121E);
  static const Color bgCard = Color(0xFF1A1A2E);
  static const Color bgCardElevated = Color(0xFF22223A);

  // Primary - Electric Green (energy, go)
  static const Color primary = Color(0xFF00E676);
  static const Color primaryDim = Color(0xFF00B858);
  static const Color primaryDark = Color(0xFF007A3D);

  // Secondary - Cyan Blue (cool, tech)
  static const Color secondary = Color(0xFF00D4FF);
  static const Color secondaryDim = Color(0xFF0099BB);

  // Accent - Fire Orange (intensity, heat)
  static const Color accent = Color(0xFFFF6B00);
  static const Color accentLight = Color(0xFFFF9A4C);

  // Status
  static const Color success = Color(0xFF00E676);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFD600);
  static const Color info = Color(0xFF00D4FF);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9090A8);
  static const Color textHint = Color(0xFF505068);
  static const Color textOnPrimary = Color(0xFF001A0A);

  // Exercise colors
  static const Color squats = Color(0xFF00E676);
  static const Color pushUps = Color(0xFFFF6B00);
  static const Color bicepCurls = Color(0xFF00D4FF);
  static const Color shoulderPress = Color(0xFFAB47BC);
  static const Color lunges = Color(0xFFFFD600);
  static const Color planks = Color(0xFFFF5252);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00B858)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF12121E), Color(0xFF0A0A12)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00D4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Legacy aliases for backward compatibility
  static const Color primaryColor = primary;
  static const Color accentColor = accent;
  static const Color backgroundColor = bg;
  static const Color surfaceColor = bgSurface;
  static const Color cardColor = bgCard;
  static const Color darkBackground = bg;
  static const Color darkSurface = bgSurface;
  static const Color darkCard = bgCard;
  static const Color textWhite = textPrimary;
  static const Color errorColor = error;
  static const Color successColor = success;
  static const Color warningColor = warning;
  static const Color infoColor = info;
  static const Color primaryDark_ = primaryDim;
  static const Color primaryLight = Color(0xFF66FFAB);
  static const Color accentLight_ = accentLight;
  static const Color textPrimary_ = textPrimary;
  static const Color textSecondary_ = textSecondary;
  static const Color textHint_ = textHint;

  static Color exerciseColor(String exerciseName) {
    switch (exerciseName) {
      case 'Squats': return squats;
      case 'Push-ups': return pushUps;
      case 'Bicep Curls': return bicepCurls;
      case 'Shoulder Press': return shoulderPress;
      case 'Lunges': return lunges;
      case 'Planks': return planks;
      default: return primary;
    }
  }
}
