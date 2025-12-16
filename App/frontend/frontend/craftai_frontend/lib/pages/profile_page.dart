import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_drawer.dart';

class ProfilePage extends StatelessWidget {
  final int userId;

  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 头部卡片
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    child: Icon(Icons.person, size: 50, color: theme.primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    authProvider.username ?? "未登录",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('用户 ID: $userId', style: TextStyle(color: Colors.grey[600])),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 功能列表
            _buildSettingsGroup(context, "账户安全", [
              _buildSettingsTile(
                context,
                icon: Icons.lock_outline,
                title: "修改密码",
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.history,
                title: "操作日志",
                onTap: () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('日志功能开发中')));
                },
              ),
            ]),
            
            const SizedBox(height: 20),
            
            _buildSettingsGroup(context, "系统设置", [
              _buildSettingsTile(
                context,
                icon: Icons.settings_outlined,
                title: "通用设置",
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.info_outline,
                title: "关于匠知",
                onTap: () => Navigator.pushNamed(context, '/about'),
              ),
            ]),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                   authProvider.logout();
                   Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  elevation: 0,
                  side: BorderSide(color: Colors.red.shade100),
                ),
                child: const Text("退出登录"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600])),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}