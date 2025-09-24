import 'package:flutter/material.dart';

class AdaptiveColors {
  // Couleurs pour le mode clair
  static const Color lightPrimary = Color(0xFF1E88E5);
  static const Color lightSecondary = Color(0xFF6c757d);
  static const Color lightSurface = Color(0xFFF5F7FA);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightOnSurface = Color(0xFF1a1a1a);
  static const Color lightOnBackground = Color(0xFF1a1a1a);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFD3D3D3);

  // Couleurs pour le mode sombre avec dégradés bleu-vert
  static const Color darkPrimary = Color(0xFF00BCD4); // Cyan bleu
  static const Color darkSecondary = Color(0xFF4CAF50); // Vert
  static const Color darkTertiary = Color(0xFF2196F3); // Bleu
  static const Color darkSurface = Color(0xFF0A0E1A); // Bleu très foncé
  static const Color darkBackground = Color(0xFF000B1A); // Bleu noir profond
  static const Color darkOnSurface = Color(0xFFE1F5FE); // Bleu très clair
  static const Color darkOnBackground = Color(0xFFE1F5FE);
  static const Color darkCard = Color(0xFF1A2332); // Bleu-gris foncé
  static const Color darkDivider = Color(0xFF2A3A4A);

  // Dégradés pour le mode sombre
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00BCD4), // Cyan bleu
      Color(0xFF2196F3), // Bleu
      Color(0xFF4CAF50), // Vert
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2332), Color(0xFF0F1419)],
  );

  // Méthodes pour obtenir les couleurs selon le thème
  static Color getPrimary(bool isDarkMode) {
    return isDarkMode ? darkPrimary : lightPrimary;
  }

  static Color getSecondary(bool isDarkMode) {
    return isDarkMode ? darkSecondary : lightSecondary;
  }

  static Color getTertiary(bool isDarkMode) {
    return isDarkMode ? darkTertiary : lightPrimary;
  }

  static Color getSurface(bool isDarkMode) {
    return isDarkMode ? darkSurface : lightSurface;
  }

  static Color getBackground(bool isDarkMode) {
    return isDarkMode ? darkBackground : lightBackground;
  }

  static Color getOnSurface(bool isDarkMode) {
    return isDarkMode ? darkOnSurface : lightOnSurface;
  }

  static Color getOnBackground(bool isDarkMode) {
    return isDarkMode ? darkOnBackground : lightOnBackground;
  }

  static Color getCard(bool isDarkMode) {
    return isDarkMode ? darkCard : lightCard;
  }

  static Color getDivider(bool isDarkMode) {
    return isDarkMode ? darkDivider : lightDivider;
  }

  static LinearGradient getGradient(bool isDarkMode) {
    return isDarkMode
        ? darkGradient
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [lightPrimary, Color(0xFF0D47A1)],
          );
  }

  static LinearGradient getCardGradient(bool isDarkMode) {
    return isDarkMode
        ? darkCardGradient
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [lightCard, lightCard],
          );
  }
}
