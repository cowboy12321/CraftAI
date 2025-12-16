import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('关于匠知', style: TextStyle(fontSize: 22, color: Colors.white)),
        backgroundColor: theme.primaryColor,
        elevation: 4,
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF8B4513).withOpacity(0.8),
              const Color(0xFFF5F5F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/logo.png',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.build,
                            size: 120,
                            color: Color(0xFFD4A017),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '匠知（CraftAI）',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '口号：AI赋能古建修复 · 智慧守护文化遗产',
                            style: TextStyle(fontSize: 18, color: Colors.black87),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '核心理念：\n'
                            '· 智能识别：利用AI技术精准检测古建筑病害\n'
                            '· 精准修复：提供科学修复建议\n'
                            '· 文化传承：守护历史遗产，延续文化记忆',
                            style: TextStyle(fontSize: 18, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '关于我们',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '匠知团队由一群热爱文化遗产保护和人工智能技术的专业人士组成，致力于将先进技术应用于古建筑保护领域。',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '联系方式：\n'
                            '邮箱：support@craftai.com\n'
                            '电话：+86 123-456-7890\n'
                            '地址：中国北京市文化科技园',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('感谢您的支持！')),
                      );
                    },
                    child: const Text('联系我们', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}