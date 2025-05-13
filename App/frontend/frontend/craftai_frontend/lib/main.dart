import 'package:flutter/material.dart';
import 'dart:io'; // For File
import 'package:image_picker/image_picker.dart'; // For ImagePicker
import 'package:http/http.dart' as http; // For HTTP requests
import 'dart:convert'; // For json.encode/decode
import 'history_page.dart'; // Import the new HistoryPage
import 'login_page.dart'; // Import LoginPage

void main() {
  runApp(const CraftAIApp());
}

class CraftAIApp extends StatelessWidget {
  const CraftAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '匠知 · 古建修复AI平台',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(), // Start at LoginPage
    );
  }
}

class DashboardPage extends StatelessWidget {
  final int userId;

  const DashboardPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(userId: userId),
      appBar: AppBar(
        title: const Text('匠知 · 古建修复AI平台'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '欢迎使用匠知AI平台！',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FeatureCard(
                    icon: Icons.upload_file,
                    title: '上传图片',
                    description: '上传古建筑部件图像以检测缺陷。',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadPage(userId: userId),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FeatureCard(
                    icon: Icons.history,
                    title: '历史记录',
                    description: '查看检测历史和结果报告。',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryPage(userId: userId),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FeatureCard(
                    icon: Icons.analytics,
                    title: '缺陷分析',
                    description: '智能分析检测结果，提供修复建议。',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('功能开发中')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FeatureCard(
                    icon: Icons.settings,
                    title: '系统设置',
                    description: '管理账号信息、数据连接等。',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('功能开发中')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.indigo),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(description, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final int userId;

  const AppDrawer({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Text(
              '匠知AI菜单',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('首页'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardPage(userId: userId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('上传图片'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadPage(userId: userId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('检测记录'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryPage(userId: userId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('退出登录'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class UploadPage extends StatefulWidget {
  final int userId;

  const UploadPage({super.key, required this.userId});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _image;
  Map<String, dynamic>? _result;
  bool _isLoading = false;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _isLoading = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:5000/api/predict'),
      );

      request.fields['user_id'] = widget.userId.toString();
      request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final result = json.decode(responseData);

        setState(() {
          _result = {
            'image_url': 'http://127.0.0.1:5000/${result['result_image']}',
            'material_lost': result['material_lost'],
            'severity': result['severity']?.toString() ?? 'N/A',
            'coordinates': result['coordinates'] != null
                ? json.encode(result['coordinates'])
                : 'N/A',
            'summary': result['result_summary'] ?? 'No summary available',
          };
          _isLoading = false;
        });
      } else {
        throw Exception('上传失败: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('错误: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('上传图片检测')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: _pickAndUploadImage,
                child: const Text('选择图片并上传'),
              ),
              const SizedBox(height: 20),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
              if (_result != null) ...[
                Text(
                  _result!['material_lost']
                      ? '存在材料缺失'
                      : '无明显缺陷',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('严重程度: ${_result!['severity']}'),
                const SizedBox(height: 10),
                Text('坐标信息: ${_result!['coordinates']}'),
                const SizedBox(height: 10),
                Text('检测总结: ${_result!['summary']}'),
                const SizedBox(height: 20),
                Image.network(_result!['image_url']),
              ],
            ],
          ),
        ),
      ),
    );
  }
}