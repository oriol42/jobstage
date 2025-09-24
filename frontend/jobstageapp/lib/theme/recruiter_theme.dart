import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecruiterTheme {
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color secondaryColor = Color(0xFF2E7D32);
  static const Color surfaceColor = Color(0xFFF5F5F5);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);
  static const Color successColor = Color(0xFF4CAF50);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.robotoTextTheme(),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[100],
        labelStyle: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  // Couleurs personnalisées
  static const Map<String, Color> customColors = {
    'blue_light': Color(0xFFE3F2FD),
    'blue_medium': Color(0xFFBBDEFB),
    'blue_dark': Color(0xFF1E88E5),
    'green_light': Color(0xFFE8F5E8),
    'green_dark': Color(0xFF4CAF50),
    'orange_light': Color(0xFFFFF3E0),
    'orange_dark': Color(0xFFFF9800),
    'purple_light': Color(0xFFF3E5F5),
    'purple_dark': Color(0xFF9C27B0),
    'red_light': Color(0xFFFFEBEE),
    'red_dark': Color(0xFFF44336),
    'primary_text': Color(0xFF1C1B1F),
    'secondary_text': Color(0xFF49454F),
    'surface_bg': Color(0xFFF5F5F5),
    'white': Color(0xFFFFFFFF),
    'divider_color': Color(0xFFD3D3D3),
    'verified_color': Color(0xFF4CAF50),
  };

  // Styles de texte personnalisés
  static TextStyle get headlineLarge => GoogleFonts.roboto(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: customColors['primary_text'],
  );

  static TextStyle get headlineMedium => GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: customColors['primary_text'],
  );

  static TextStyle get headlineSmall => GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: customColors['primary_text'],
  );

  static TextStyle get titleLarge => GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: customColors['primary_text'],
  );

  static TextStyle get titleMedium => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: customColors['primary_text'],
  );

  static TextStyle get titleSmall => GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: customColors['primary_text'],
  );

  static TextStyle get bodyLarge => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: customColors['primary_text'],
  );

  static TextStyle get bodyMedium => GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: customColors['primary_text'],
  );

  static TextStyle get bodySmall => GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: customColors['secondary_text'],
  );

  static TextStyle get labelLarge => GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: customColors['primary_text'],
  );

  static TextStyle get labelMedium => GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: customColors['secondary_text'],
  );

  static TextStyle get labelSmall => GoogleFonts.roboto(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: customColors['secondary_text'],
  );
}
