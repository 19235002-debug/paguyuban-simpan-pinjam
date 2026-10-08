import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accent (Website Teal & Cyan Palette)
  static const Color primary = Color(0xFF0D9488);        // Teal 600 (--primary)
  static const Color primaryDark = Color(0xFF0F766E);    // Teal 700 (--primary-dark)
  static const Color primaryLight = Color(0xFF14B8A6);   // Teal 500
  static const Color secondary = Color(0xFF2563EB);      // Blue 600 (--secondary)
  static const Color secondaryLight = Color(0xFF60A5FA);  // Blue 400
  static const Color accent = Color(0xFF06B6D4);         // Cyan 500
  static const Color accentLight = Color(0xFF22D3EE);    // Cyan 400

  // Background & Surfaces (Matching Website Body #F8FAFC)
  static const Color bgLight = Color(0xFFF8FAFC);        // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceSubtleLight = Color(0xFFF1F5F9); // Slate 100
  static const Color borderLight = Color(0xFFE2E8F0);     // Slate 200

  // Background & Surfaces (Dark)
  static const Color bgDark = Color(0xFF0F172A);         // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B);    // Slate 800
  static const Color surfaceSubtleDark = Color(0xFF334155); // Slate 700
  static const Color borderDark = Color(0xFF334155);      // Slate 700

  // Text Colors (Light)
  static const Color textPrimaryLight = Color(0xFF1E293B);   // Slate 800
  static const Color textSecondaryLight = Color(0xFF475569); // Slate 600
  static const Color textMutedLight = Color(0xFF94A3B8);     // Slate 400

  // Text Colors (Dark)
  static const Color textPrimaryDark = Color(0xFFF8FAFC);    // Slate 50
  static const Color textSecondaryDark = Color(0xFFCBD5E1);  // Slate 300
  static const Color textMutedDark = Color(0xFF64748B);      // Slate 500

  // Quick Action Tile Colors (Matching Website Grid)
  static const Color cyanBg = Color(0xFFECFEFF);        // cyan-50
  static const Color cyanText = Color(0xFF0891B2);      // cyan-600

  static const Color violetBg = Color(0xFFF5F3FF);      // violet-50
  static const Color violetText = Color(0xFF7C3AED);    // violet-600

  static const Color emeraldBg = Color(0xFFECFDF5);     // emerald-50
  static const Color emeraldText = Color(0xFF059669);   // emerald-600

  static const Color orangeBg = Color(0xFFFFF7ED);      // orange-50
  static const Color orangeText = Color(0xFFEA580C);    // orange-600

  static const Color amberBg = Color(0xFFFEF3C7);       // amber-100
  static const Color amberText = Color(0xFFD97706);     // amber-600

  // Functional Status Colors
  static const Color success = Color(0xFF166534);       // Emerald 800
  static const Color successBg = Color(0xFFDCFCE7);     // Emerald 100
  static const Color successBorder = Color(0xFFBBF7D0);

  static const Color warning = Color(0xFF854D0E);       // Amber 800
  static const Color warningBg = Color(0xFFFEF3C7);     // Amber 100
  static const Color warningBorder = Color(0xFFFDE68A);

  static const Color error = Color(0xFF991B1B);         // Red 800
  static const Color errorBg = Color(0xFFFEE2E2);       // Red 100
  static const Color errorBorder = Color(0xFFFCA5A5);

  static const Color info = Color(0xFF1E40AF);          // Blue 800
  static const Color infoBg = Color(0xFFDBEAFE);        // Blue 100
  static const Color infoBorder = Color(0xFFBFDBFE);

  // Gradients (Matching Website Gradient Cards & Buttons)
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0D9488), Color(0xFF06B6D4), Color(0xFF2563EB)], // from-teal-500 via-cyan-500 to-blue-600
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D9488), Color(0xFF06B6D4)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
