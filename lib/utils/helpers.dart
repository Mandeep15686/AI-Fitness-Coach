import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  static String formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  static Color getBMIColor(double bmi) {
    if (bmi < 18.5) return const Color(0xFF2196F3); // Blue
    if (bmi < 25) return const Color(0xFF4CAF50); // Green
    if (bmi < 30) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }
}
