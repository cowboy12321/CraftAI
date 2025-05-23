import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/detection_provider.dart';
import '../widgets/model_selector.dart';
import '../widgets/app_drawer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    // 延迟检查主题，避免 initState 中的上下文问题
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isDarkTheme = Theme.of(context).brightness == Brightness.dark;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置', style: TextStyle(fontSize: 20)),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView( // 添加滚动，防止溢出
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('模型选择', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Consumer<DetectionProvider>(
              builder: (context, provider, child) {
                return provider.selectedModel != null
                    ? ModelSelector(
                        selectedModel: provider.selectedModel,
                        onModelChanged: (model) => provider.setModel(model),
                      )
                    : const Text('模型未加载', style: TextStyle(color: Colors.red));
              },
            ),
            const SizedBox(height: 20),
            const Text('界面设置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              title: const Text('暗色主题'),
              trailing: Switch(
                value: _isDarkTheme,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  setState(() => _isDarkTheme = value);
                  // 实现主题切换逻辑（可选）
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text('账号设置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              title: const Text('修改密码'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('功能开发中')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}