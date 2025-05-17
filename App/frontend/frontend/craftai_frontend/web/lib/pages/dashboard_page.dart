import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/feature_card.dart';
import 'upload_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import 'profile_page.dart';

class DashboardPage extends StatelessWidget {
  final int userId;

  const DashboardPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(userId: userId),
      appBar: AppBar(
        title: const Text('匠知 · 古建修复AI平台'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfilePage(userId: userId),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '欢迎使用匠知AI平台！',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
                children: [
                  FeatureCard(
                    icon: Icons.upload_file,
                    title: '上传图片',
                    description: '上传古建筑部件图像以检测缺陷。',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UploadPage(userId: userId),
                      ),
                    ),
                  ),
                  FeatureCard(
                    icon: Icons.history,
                    title: '历史记录',
                    description: '查看检测历史和结果报告。',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HistoryPage(userId: userId),
                      ),
                    ),
                  ),
                  FeatureCard(
                    icon: Icons.settings,
                    title: '系统设置',
                    description: '管理账号信息、数据连接等。',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingsPage(userId: userId),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}