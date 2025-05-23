import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/detection_provider.dart';
import '../widgets/feature_card.dart';
import '../widgets/app_drawer.dart';
import '../widgets/model_selector.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // 加载历史记录
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DetectionProvider>(context, listen: false).loadHistory(context).then((_) {
        setState(() {
          _isLoading = false;
        });
      }).catchError((e) {
        setState(() {
          _isLoading = false;
          _error = '加载失败: $e';
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final detectionProvider = Provider.of<DetectionProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('匠知 - CraftAI', style: TextStyle(fontSize: 20, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 600;
            final cardWidth = isWideScreen 
                ? constraints.maxWidth / 3 - 24
                : constraints.maxWidth / 2 - 24;
            final availableHeight = constraints.maxHeight - 
                kToolbarHeight - // AppBar高度
                MediaQuery.of(context).padding.top - // 状态栏高度
                16 * 4; // 其他间距

            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(), // 禁用滚动
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - kToolbarHeight - MediaQuery.of(context).padding.top,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 软件介绍
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Color(0xFFD4A017),
                                    child: Icon(Icons.build, size: 40, color: Colors.white),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '欢迎，${authProvider.username ?? '用户'}！',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF8B4513),
                                          ),
                                        ),
                                        const Text(
                                          'AI赋能古建修复 · 智慧守护文化遗产',
                                          style: TextStyle(fontSize: 14, color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                '匠知（CraftAI）',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8B4513),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '核心理念：智能识别、精准修复、文化传承',
                                style: TextStyle(fontSize: 16, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 模型选择
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: detectionProvider.selectedModel != null
                          ? ModelSelector(
                              selectedModel: detectionProvider.selectedModel,
                              onModelChanged: (model) => detectionProvider.setModel(model),
                            )
                          : const Text(
                              '模型未加载',
                              style: TextStyle(color: Colors.red),
                            ),
                    ),
                    const SizedBox(height: 20),
                    // 功能标题
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        '功能',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B4513),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 加载状态
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_error != null)
                      Center(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      )
                    else
                      // 功能卡片 - 两行布局，第一行3个，第二行2个
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // 第一行 - 3个卡片
                            Row(
                              children: [
                                Expanded(
                                  child: FeatureCard(
                                    title: '单张图片检测',
                                    icon: Icons.image,
                                    color: const Color(0xFF8B4513),
                                    onTap: () => Navigator.pushNamed(context, '/upload'),
                                    width: double.infinity,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: FeatureCard(
                                    title: '批量图片检测',
                                    icon: Icons.folder,
                                    color: const Color(0xFF2E7D32),
                                    onTap: () => Navigator.pushNamed(context, '/upload'),
                                    width: double.infinity,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: FeatureCard(
                                    title: '检测历史',
                                    icon: Icons.history,
                                    color: const Color(0xFFD4A017),
                                    onTap: () => Navigator.pushNamed(context, '/history'),
                                    width: double.infinity,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // 第二行 - 2个卡片，居中显示
                            Row(
                              children: [
                                const Spacer(flex: 1),
                                Expanded(
                                  flex: 2,
                                  child: FeatureCard(
                                    title: '生成报告',
                                    icon: Icons.description,
                                    color: const Color(0xFF6D4C41),
                                    onTap: () => Navigator.pushNamed(context, '/report'),
                                    width: double.infinity,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: FeatureCard(
                                    title: '关于匠知',
                                    icon: Icons.info,
                                    color: const Color(0xFF4E342E),
                                    onTap: () => Navigator.pushNamed(context, '/about'),
                                    width: double.infinity,
                                  ),
                                ),
                                const Spacer(flex: 1),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}