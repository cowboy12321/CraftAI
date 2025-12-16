import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
// 引入所有页面
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/upload_page.dart';
import 'pages/history_page.dart';
import 'pages/report_page.dart';
import 'pages/detection_page.dart';
import 'pages/settings_page.dart';
import 'pages/profile_page.dart';
import 'pages/about_page.dart';
// 引入 Providers
import 'providers/auth_provider.dart';
import 'providers/detection_provider.dart';
import 'providers/report_provider.dart';

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
      title: '匠知 - 古建筑智能检测平台',
      debugShowCheckedModeBanner: false,
      // 使用在 theme/app_theme.dart 中定义的专业主题
      theme: AppTheme.professionalTheme, 
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/upload': (context) => const UploadPage(),
        '/history': (context) => const HistoryPage(),
        '/detection': (context) => const DetectionPage(),
        '/report': (context) => const ReportPage(),
        '/settings': (context) => const SettingsPage(),
        '/about': (context) => const AboutPage(),
        // ProfilePage 需要传入 userId，我们这里通过 AuthProvider 获取，或在跳转时传入
        // 为了路由表简单，这里使用 Provider 获取当前 ID
        '/profile_page': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          return ProfilePage(userId: auth.userId ?? 0);
        },
      },
      // 处理未知道路由
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const LoginPage());
      },
    );
  }
}