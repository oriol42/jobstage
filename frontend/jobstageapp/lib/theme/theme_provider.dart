import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'dark_mode';

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF007bff),
      secondary: Color(0xFF6c757d),
      surface: Color(0xFFF5F7FA),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1a1a1a),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF007bff),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF007bff)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF007bff), width: 2),
      ),
    ),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00BCD4), // Cyan bleu
      secondary: Color(0xFF4CAF50), // Vert
      tertiary: Color(0xFF2196F3), // Bleu
      surface: Color(0xFF0A0E1A), // Bleu noir profond
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onSurface: Color(0xFFE1F5FE),
      surfaceContainerHighest: Color(0xFF1A2332), // Bleu-gris foncé
      surfaceContainer: Color(0xFF0F1419), // Bleu-gris très foncé
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A0E1A),
      foregroundColor: Color(0xFFE1F5FE),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1A2332),
      elevation: 4,
      shadowColor: const Color(0xFF00BCD4).withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF2A3A4A), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1A2332),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2A3A4A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2A3A4A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
      ),
      labelStyle: const TextStyle(color: Color(0xFFB0BEC5)),
      hintStyle: const TextStyle(color: Color(0xFF78909C)),
    ),
    scaffoldBackgroundColor: const Color(0xFF000B1A),
    dividerColor: const Color(0xFF2A3A4A),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFE1F5FE)),
      bodyMedium: TextStyle(color: Color(0xFFB0BEC5)),
      bodySmall: TextStyle(color: Color(0xFF78909C)),
      titleLarge: TextStyle(color: Color(0xFFE1F5FE)),
      titleMedium: TextStyle(color: Color(0xFFE1F5FE)),
      titleSmall: TextStyle(color: Color(0xFFB0BEC5)),
    ),
  );

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }
}
