import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1565C0); // Couleur principale
  static const accent = Color(0xFF5E92F3); // Couleur secondaire
  static const background = Color(0xFFF5F5F5); // Couleur d'arrière-plan
  static const text = Color(0xFF212121); // Texte principal
  static const textLight = Color(0xFF757575); // Texte secondaire
  static const success = Colors.green;
  static const error = Colors.red;
}

class AppTextStyles {
  static const header = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const body = TextStyle(fontSize: 16, color: AppColors.text);
  static const subtitle = TextStyle(fontSize: 14, color: AppColors.textLight);
}
