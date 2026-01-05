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
    
    // 获取屏幕宽度，用于响应式计算
    final screenWidth = MediaQuery.of(context).size.width;

    // 【布局核心逻辑】
    // 只有4个功能，绝对禁止出现3列布局（否则就是3+1倒三角）。
    // 宽屏(PC) => 4列 (1行)
    // 窄屏(Pad/手机) => 2列 (2行)
    final int crossAxisCount = screenWidth > 1100 ? 4 : 2;
    
    // 【宽高比调整】
    // 列数多时(4列)，卡片显得窄，高度要相对压低，比例设大一点(如1.2)
    // 列数少时(2列)，卡片显得宽，比例可以设小一点(如1.5)让内容不拥挤
    final double childAspectRatio = screenWidth > 1100 ? 1.2 : 1.4;

    return Scaffold(
      appBar: AppBar(
        title: const Text('匠知工作台', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA), // 浅灰底色，凸显白卡片
          image: DecorationImage(
            image: const AssetImage('assets/logo.png'),
            colorFilter: ColorFilter.mode(
              Colors.grey.withOpacity(0.03), // 极淡的水印，不抢眼
              BlendMode.dstATop,
            ),
            fit: BoxFit.cover,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
          child: Center(
            child: ConstrainedBox(
              // 【约束盒子】
              // 无论屏幕多宽，内容区域死死锁在 1200px 以内
              // 这样在 4K 屏上也不会变成一条横幅
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 欢迎 Banner
                  _buildWelcomeBanner(context, authProvider, theme),
                  
                  const SizedBox(height: 40),
                  
                  // 2. 标题栏
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 28,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "核心功能",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),

                  // 3. 功能矩阵 (Grid)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount, // 强制 4 或 2
                      childAspectRatio: childAspectRatio,
                      crossAxisSpacing: 24, // 卡片间距加大，更有呼吸感
                      mainAxisSpacing: 24,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final features = [
                        {
                          'title': '智能检测',
                          'icon': Icons.camera_enhance_rounded,
                          'color': const Color(0xFF8B4513), // 赭石
                          'route': '/upload'
                        },
                        {
                          'title': '历史档案',
                          'icon': Icons.history_edu_rounded,
                          'color': const Color(0xFF2C3E50), // 墨色
                          'route': '/history'
                        },
                        {
                          'title': '生成报告',
                          'icon': Icons.assignment_turned_in_rounded,
                          'color': const Color(0xFFC0392B), // 朱红
                          'route': '/report'
                        },
                        {
                          'title': '个人中心',
                          'icon': Icons.account_circle_rounded,
                          'color': const Color(0xFF27AE60), // 翠绿
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
                  
                  const SizedBox(height: 60),
                  
                  // 4. 底部版权 (让页面不至于在底部突然切断)
                  Center(
                    child: Text(
                      "CraftAI System v1.0.0",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, AuthProvider auth, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor, // 主色
            const Color(0xFFA0522D), // 渐变深色
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          )
        ],
        image: const DecorationImage(
          image: AssetImage('assets/logo.png'), // 如果没有背景图，可以去掉这行
          alignment: Alignment.centerRight,
          opacity: 0.15, // 让 Logo 隐约显示在右侧
          scale: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Text(
                '早安，${auth.username ?? "工程师"}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'AI 赋能古建修复 · 守护文明瑰宝',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}