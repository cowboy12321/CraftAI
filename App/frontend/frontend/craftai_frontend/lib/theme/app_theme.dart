import 'package:flutter/material.dart';

class AppTheme {
  // 古建核心色：赭石/深棕
  static const Color heritageBrown = Color(0xFF8B4513);
  static const Color heritageLight = Color(0xFFD2B48C);
  // 科技辅助色：深青
  static const Color techBlue = Color(0xFF2C3E50);
  
  static final ThemeData professionalTheme = ThemeData(
    useMaterial3: true,
    primaryColor: heritageBrown,
    scaffoldBackgroundColor: const Color(0xFFF9F9F9),
    colorScheme: ColorScheme.fromSeed(
      seedColor: heritageBrown,
      primary: heritageBrown,
      secondary: techBlue,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: heritageBrown,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    // 【修改】暂时注释掉 cardTheme 配置以解决类型冲突
    // 默认的 Material 3 卡片样式已经包含了圆角和阴影
    /*
    cardTheme: CardTheme(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    ),
    */
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: heritageBrown,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: heritageBrown, width: 2),
      ),
      contentPadding: const EdgeInsets.all(16),
    ),
  );
}