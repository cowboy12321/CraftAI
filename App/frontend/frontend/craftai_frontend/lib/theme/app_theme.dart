import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: const Color(0xFFFF6699), // Bilibili Pink
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    cardColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFFF6699),
      secondary: Color(0xFF00A1D6), // Bilibili Blue
      surface: Color(0xFFF5F5F5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(const Color(0xFFFF6699)),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        elevation: WidgetStateProperty.all(6),
        overlayColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.hovered) ? Colors.white.withOpacity(0.2) : null,
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF212121)),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 4,
      shadowColor: Colors.black26,
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFFFF6699),
    ),
    cardTheme: CardTheme(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static final darkTheme = ThemeData(
    primaryColor: const Color(0xFF00A1D6), // Bilibili Blue
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00A1D6),
      secondary: Color(0xFFFF6699),
      surface: Color(0xFF1E1E1E),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(const Color(0xFF00A1D6)),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        elevation: WidgetStateProperty.all(6),
        overlayColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.hovered) ? Colors.white.withOpacity(0.2) : null,
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 4,
      shadowColor: Colors.black26,
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Color(0xFFFF6699),
    ),
    cardTheme: CardTheme(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}