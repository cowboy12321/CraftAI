import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/feature_card.dart';
import '../widgets/app_drawer.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('匠知工作台')),
      drawer: const AppDrawer(),
      body: Container(
        // 全局背景，增加质感
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          image: DecorationImage(
            image: const AssetImage('assets/logo.png'), // 如果有背景图更好，这里用logo做水印
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.05), BlendMode.dstATop),
            fit: BoxFit.cover,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 欢迎 Banner - 优化布局和阴影
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      const Color(0xFFA0522D)
                    ], // 古建红到棕的渐变
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '早安，${authProvider.username ?? "检测师"}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'AI 赋能古建修复 · 守护文明瑰宝',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              Row(
                children: [
                  Container(width: 4, height: 24, color: theme.primaryColor),
                  const SizedBox(width: 12),
                  Text("核心功能",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800])),
                ],
              ),
              const SizedBox(height: 24),

              // 响应式 Grid 布局 - 关键修改
              // 使用 MaxCrossAxisExtent 让卡片宽度保持在合理范围，而不是无限拉伸
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300, // 卡片最大宽度
                  childAspectRatio: 1.1,   // 宽高比
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  final features = [
                    {
                      'title': '智能检测',
                      'icon': Icons.camera_alt_outlined,
                      'color': const Color(0xFF8B4513),
                      'route': '/upload'
                    },
                    {
                      'title': '历史档案',
                      'icon': Icons.history_edu,
                      'color': const Color(0xFF2C3E50),
                      'route': '/history'
                    },
                    {
                      'title': '生成报告',
                      'icon': Icons.picture_as_pdf_outlined,
                      'color': const Color(0xFFC0392B),
                      'route': '/report'
                    },
                    {
                      'title': '个人中心',
                      'icon': Icons.person_outline,
                      'color': const Color(0xFF27AE60),
                      'route': '/profile_page'
                    },
                  ];
                  
                  final f = features[index];
                  return FeatureCard(
                    title: f['title'] as String,
                    icon: f['icon'] as IconData,
                    color: f['color'] as Color,
                    onTap: () => Navigator.pushNamed(context, f['route'] as String),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}