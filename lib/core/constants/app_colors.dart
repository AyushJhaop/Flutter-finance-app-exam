import 'package:flutter/material.dart';

/// FinTrack design-system color tokens.
/// Single source of truth — do NOT scatter Color() literals in widgets.
class AppColors {
  AppColors._();

  // --- Brand ---
  static const Color primary = Color(0xFF4F46E5);       // Indigo-600 (Primary Blue/Indigo)
  static const Color primaryDark = Color(0xFF4338CA);   // Indigo-700
  static const Color primaryLight = Color(0xFFEEF2FF);  // Indigo-50
  static const Color accent = Color(0xFF2563EB);        // Royal Blue-600 (Consistent Brand Blue)
  static const Color accentLight = Color(0xFF3B82F6);   // Blue-500
  static const Color accentSubtle = Color(0xFFEFF6FF);  // Blue-50

  // --- Backgrounds for Light Theme ---
  static const Color bgDark = Color(0xFFF8FAFC);        // Crisp off-white / Slate 50
  static const Color bgCard = Color(0xFFFFFFFF);        // Pure White card
  static const Color bgSurface = Color(0xFFF1F5F9);     // Slate 100 surface
  static const Color bgModal = Color(0xFFFFFFFF);       // White modal / sheet
  static const Color cardDark = bgCard;                 // Backward compatibility alias
  static const Color surfaceDark = bgSurface;           // Backward compatibility alias

  // --- Text for Light Theme ---
  static const Color textPrimary = Color(0xFF0F172A);    // Slate 900 (crisp high contrast)
  static const Color textSecondary = Color(0xFF475569);  // Slate 600 (readable subtitle)
  static const Color textMuted = Color(0xFF94A3B8);      // Slate 400 (hints, captions)
  static const Color textInverse = Color(0xFFFFFFFF);    // White text on dark/colored containers

  // --- Semantic ---
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFD97706);       // Amber-600 (better light contrast)
  static const Color error = Color(0xFFDC2626);         // Red-600
  static const Color info = Color(0xFF2563EB);          // Blue-600

  // --- Financial ---
  static const Color income = Color(0xFF059669);        // Green for income
  static const Color expense = Color(0xFFDC2626);       // Red for expense
  static const Color savingsBlue = Color(0xFF2563EB);

  // --- Chart palette ---
  static const List<Color> chartColors = [
    Color(0xFF4F46E5),
    Color(0xFF2563EB),
    Color(0xFF059669),
    Color(0xFFD97706),
    Color(0xFFDC2626),
    Color(0xFFDB2777),
    Color(0xFF7C3AED),
    Color(0xFF0D9488),
  ];

  // --- Borders / Dividers ---
  static const Color borderSubtle = Color(0xFFE2E8F0);  // Slate 200
  static const Color divider = Color(0xFFE2E8F0);

  // --- Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient balanceGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
