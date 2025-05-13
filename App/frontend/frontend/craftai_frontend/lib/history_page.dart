import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  final int userId;

  const HistoryPage({super.key, required this.userId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/api/history?user_id=${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _history = data['pictures'];
          _isLoading = false;
        });
      } else {
        throw Exception('获取历史记录失败: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('错误: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('检测记录')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(child: Text('暂无检测记录'))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: Image.network(
                          'http://127.0.0.1:5000/${item['processed_path']}',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error),
                        ),
                        title: Text(
                          item['material_lost']
                              ? '材料缺失'
                              : '无明显缺陷',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('时间: ${item['timestamp']}'),
                            Text(
                                '严重程度: ${item['material_lost_pic']?['severity'] ?? 'N/A'}'),
                            Text(
                                '坐标: ${item['material_lost_pic']?['coordinates'] != null ? json.encode(item['material_lost_pic']['coordinates']) : 'N/A'}'),
                          ],
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('检测详情'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.network(
                                      'http://127.0.0.1:5000/${item['processed_path']}',
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Text('无法加载图片'),
                                    ),
                                    const SizedBox(height: 10),
                                    Text('总结: ${item['result_summary'] ?? '无'}'),
                                    Text(
                                        '严重程度: ${item['material_lost_pic']?['severity'] ?? 'N/A'}'),
                                    Text(
                                        '坐标: ${item['material_lost_pic']?['coordinates'] != null ? json.encode(item['material_lost_pic']['coordinates']) : 'N/A'}'),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('关闭'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}