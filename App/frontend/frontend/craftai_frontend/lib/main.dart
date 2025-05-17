import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/upload_page.dart';
import 'pages/history_page.dart';
import 'pages/report_page.dart';
import 'pages/settings_page.dart';
import 'pages/profile_page.dart';
import 'providers/auth_provider.dart';
import 'providers/detection_provider.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DetectionProvider()),
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
      title: '匠知 · 古建修复AI平台',
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => DashboardPage(
              userId: Provider.of<AuthProvider>(context, listen: false).userId!,
            ),
        '/upload': (context) => UploadPage(
              userId: Provider.of<AuthProvider>(context, listen: false).userId!,
            ),
        '/history': (context) => HistoryPage(
              userId: Provider.of<AuthProvider>(context, listen: false).userId!,
            ),
        '/report': (context) => ReportPage(
              userId: Provider.of<AuthProvider>(context, listen: false).userId!,
              detectionId: ModalRoute.of(context)!.settings.arguments as int,
            ),
        '/settings': (context) => SettingsPage(
              userId: Provider.of<AuthProvider>(context, listen: false).userId!,
            ),
        '/profile': (context) => ProfilePage(
              userId: Provider.of<AuthProvider>(context, listen: false).userId!,
            ),
      },
    );
  }
}