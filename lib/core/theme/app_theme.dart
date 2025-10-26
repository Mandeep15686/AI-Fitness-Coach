import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppTheme {
  // 1. Make the class non-instantiable
  AppTheme._();

  // 2. Define the shared base theme data
  static final ThemeData _baseTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primaryColor,
    // Define shared themes that don't depend on brightness
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textWhite,
      ),
    ),
    // In the _baseTheme definition

    cardTheme: CardThemeData( // <-- FIX: Changed from CardTheme to CardThemeData
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      // Note: The color is now correctly defined in the light/dark theme overrides
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.textHint),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.textHint),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorColor),
      ),
    ),
  );

  // 3. Define the light theme by extending the base theme
  static ThemeData get lightTheme {
    return _baseTheme.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.accentColor,
        surface: AppColors.surfaceColor,
        error: AppColors.errorColor,
        onPrimary: AppColors.textWhite,
        onSecondary: AppColors.textWhite,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textWhite,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textWhite,
        iconTheme: IconThemeData(color: AppColors.textWhite),
      ),
      cardTheme: _baseTheme.cardTheme.copyWith(
        color: AppColors.cardColor,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
      inputDecorationTheme: _baseTheme.inputDecorationTheme.copyWith(
        fillColor: AppColors.surfaceColor,
      ),
    );
  }

  // 4. Define the dark theme by extending the base theme
  static ThemeData get darkTheme {
    return _baseTheme.copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.accentColor,
        surface: AppColors.darkSurface,
        error: AppColors.errorColor,
        onPrimary: AppColors.textWhite,
        onSecondary: AppColors.textWhite,
        onSurface: AppColors.textWhite,
        onError: AppColors.textWhite,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _baseTheme.elevatedButtonTheme.style!.copyWith(
          backgroundColor: WidgetStateProperty.all(AppColors.primaryDark),
        )
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.textWhite,
      ),
      cardTheme: _baseTheme.cardTheme.copyWith(
        color: AppColors.darkCard,
      ),
      // Optionally define a dark text theme if colors differ
      textTheme: _baseTheme.textTheme.copyWith(
        // Example: Override text colors for dark mode
        bodyLarge: const TextStyle(fontSize: 16, color: AppColors.textWhite),
        headlineMedium: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textWhite),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textWhite.withAlpha(179)),
      ),
    );
  }
}
