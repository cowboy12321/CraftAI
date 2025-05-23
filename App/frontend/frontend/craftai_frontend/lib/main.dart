import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/upload_page.dart';
import 'pages/history_page.dart';
import 'pages/detection_page.dart';
import 'pages/settings_page.dart';
import 'pages/about_page.dart';
import 'pages/report_page.dart';
import 'providers/auth_provider.dart';
import 'providers/detection_provider.dart';
import 'providers/report_provider.dart';
import 'services/gpt_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DetectionProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: const CraftAIApp(),
    ),
  );
}

class CraftAIApp extends StatelessWidget {
  const CraftAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '匠知 - CraftAI',
      theme: ThemeData(
        primaryColor: const Color(0xFF8B4513),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B4513)),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        cardTheme: CardTheme(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B4513),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/upload': (context) => const UploadPage(),
        '/history': (context) => const HistoryPage(),
        '/detection': (context) => const DetectionPage(),
        '/settings': (context) => const SettingsPage(),
        '/report': (context) => const ReportPage(),
        '/about': (context) => const AboutPage(),
      },
    );
  }
}