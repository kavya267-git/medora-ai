import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color.fromARGB(255, 18, 151, 191);
  static const Color primaryDark = Color.fromARGB(255, 87, 158, 245);
  static const Color primaryLight = Color.fromARGB(255, 109, 162, 246);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF1976D2);
  static const Color secondaryDark = Color(0xFF1565C0);
  static const Color secondaryLight = Color(0xFF42A5F5);
  
  // Emergency Colors
  static const Color emergency = Color(0xFFD32F2F);
  static const Color emergencyDark = Color(0xFFC62828);
  static const Color emergencyLight = Color(0xFFEF5350);
  
  // Ayurvedic Colors
  static const Color ayurvedic = Color(0xFF8D6E63);
  static const Color ayurvedicDark = Color(0xFF6D4C41);
  static const Color ayurvedicLight = Color(0xFFA1887F);
  
  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF424242);
  static const Color onBackground = Color(0xFF757575);
  
  // Semantic Colors
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);
  static const Color error = Color(0xFFD32F2F);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
  );
  
  static const LinearGradient emergencyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD32F2F), Color(0xFFEF5350)],
  );
}