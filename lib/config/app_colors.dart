import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1A237E);
  static const Color primaryLight = Color(0xFF3949AB);
  static const Color primaryDark = Color(0xFF0D1B4A);
  static const Color accent = Color(0xFF2979FF);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Neutral Colors
  static const Color background = Color(0xFFF5F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6C757D);
  
  // Department Colors
  static const Color cse = Color(0xFF1565C0);
  static const Color eee = Color(0xFFF57C00);
  static const Color me = Color(0xFF2E7D32);
  static const Color ipe = Color(0xFF6A1B9A);
  static const Color ce = Color(0xFFC62828);
  static const Color ict = Color(0xFF00838F);
  static const Color bba = Color(0xFF455A64);
  static const Color ais = Color(0xFF7B1FA2);
  static const Color english = Color(0xFF558B2F);
  
  static Color getDepartmentColor(String department) {
    switch (department.toUpperCase()) {
      case 'CSE': return cse;
      case 'EEE': return eee;
      case 'ME': return me;
      case 'IPE': return ipe;
      case 'CE': return ce;
      case 'ICT': return ict;
      case 'BBA': return bba;
      case 'AIS': return ais;
      case 'ENGLISH': return english;
      default: return primary;
    }
  }
}