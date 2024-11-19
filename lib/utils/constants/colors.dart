// lib/utils/constants/colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const Color primaryColor = Color(0xFF6200EE); // Couleur primaire
  static const Color accentColor = Color(0xFF03DAC5);  // Couleur d'accentuation
  static const Color backgroundColor = Color(0xFFF5F5F5); // Fond de l'application

  // Texte
  static const Color textColor = Colors.grey;           // Gris pour le texte secondaire
  static const Color primaryTextColor = Colors.black87; // Noir pour le texte principal
  static const Color buttonTextColor = Colors.white;    // Couleur blanche pour le texte des boutons

  // Bordures et ombres
  static const Color borderColor = Color(0xFFE0E0E0);  // Gris pour les bordures de champs de texte
  static const Color focusedBorderColor = Colors.blue;  // Bordure lorsque le champ est focus
  static const Color shadowColor = Color(0x33000000);   // Ombre avec 20% d'opacité
  static const Color greyColor = Colors.grey;           // Gris pour les icônes, etc.

  // Boutons
  static const Color buttonBackgroundColor = primaryColor;   // Fond du bouton principal
  static const Color disabledButtonColor = Color(0xFFBDBDBD); // Fond pour bouton désactivé

  // États de fond
  static const Color successColor = Color(0xFF4CAF50); // Couleur pour les états de succès
  static const Color errorColor = Color(0xFFF44336);   // Couleur pour les erreurs
  static const Color warningColor = Color(0xFFFFC107); // Couleur pour les avertissements

  // Couleurs supplémentaires
  static const Color lightGreyColor = Color(0xFFFAFAFA);    // Gris clair pour les fonds secondaires
  static const Color darkGreyColor = Color(0xFF616161);     // Gris foncé pour le texte ou les icônes
  static const Color dividerColor = Color(0xFFBDBDBD);      // Gris pour les diviseurs
  
  // Couleur de fond des champs de texte
  static const Color textFieldBackgroundColor = Color(0xFFF0F0F0); 

  // Couleur d'indication de saisie
  static const Color hintTextColor = Color(0xFF9E9E9E);

  static const Color background = Colors.white;
  static const Color primaryText = Colors.black;
  static const Color secondaryText = Colors.grey;
  static const Color accent = Colors.blue;
  static const Color divider = Colors.grey;
  static const Color socialButton = Colors.blue;
  static const Color loadingOverlay = Colors.black54;
}
