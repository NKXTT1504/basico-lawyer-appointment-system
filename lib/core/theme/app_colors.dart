import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2E7D32); // Green
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFA5D6A7);
  static const Color onPrimaryContainer = Color(0xFF1B5E20);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF1976D2); // Blue
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFBBDEFB);
  static const Color onSecondaryContainer = Color(0xFF0D47A1);
  
  // Tertiary Colors
  static const Color tertiary = Color(0xFF7B1FA2); // Purple
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFE1BEE7);
  static const Color onTertiaryContainer = Color(0xFF4A148C);
  
  // Error Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFCDD2);
  static const Color onErrorContainer = Color(0xFFB71C1C);
  
  // Success Colors
  static const Color success = Color(0xFF388E3C);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFC8E6C9);
  static const Color onSuccessContainer = Color(0xFF1B5E20);
  
  // Warning Colors
  static const Color warning = Color(0xFFF57C00);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFE0B2);
  static const Color onWarningContainer = Color(0xFFE65100);
  
  // Info Colors
  static const Color info = Color(0xFF1976D2);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFBBDEFB);
  static const Color onInfoContainer = Color(0xFF0D47A1);
  
  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  
  // Background Colors
  static const Color background = Color(0xFFFFFBFE);
  static const Color onBackground = Color(0xFF1C1B1F);
  
  // Outline Colors
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);
  
  // Shadow Colors
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkOnBackground = Color(0xFFE1E1E1);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnSurface = Color(0xFFE1E1E1);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkOnSurfaceVariant = Color(0xFFB3B3B3);
  static const Color darkOutline = Color(0xFF79747E);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
