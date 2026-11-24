import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors (Violet & Indigo)
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color primaryLight = Color(0xFFEEF2FF);
  static const Color primaryAccent = Color(0xFF6366F1);

  // Status Colors
  static const Color income = Color(0xFF16A34A);
  static const Color incomeLight = Color(0xFFDCFCE7);
  static const Color expense = Color(0xFFDC2626);
  static const Color expenseLight = Color(0xFFFEE2E2);

  static const Color savings = Color(0xFF7C3AED);
  static const Color savingsLight = Color(0xFFF3E8FF);
  static const Color investment = Color(0xFF0284C7);
  static const Color investmentLight = Color(0xFFE0F2FE);

  // Surfaces & Backgrounds
  static const Color surface = Color(0xFFF6F8FC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSoft = Color(0xFFF1F5F9);

  // Typography
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);

  // Gradients
  static const LinearGradient balanceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4F46E5),
      Color(0xFF4338CA),
      Color(0xFF3730A3),
    ],
  );

  static const LinearGradient loginButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF3B82F6),
      Color(0xFF1D4ED8),
    ],
  );

  static const LinearGradient loginBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEBF1FD),
      Color(0xFFF3F7FE),
      Color(0xFFFFFFFF),
    ],
  );
}
