import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../providers/detection_provider.dart';
import '../widgets/app_drawer.dart';

class DetectionPage extends StatelessWidget {
  const DetectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('检测详情', style: TextStyle(fontSize: 20)),
      ),
      drawer: const AppDrawer(),
      body: Consumer<DetectionProvider>(
        builder: (context, provider, child) {
          final detection = provider.currentDetection;
          if (detection == null) {
            return const Center(
              child: Text('未选择检测记录', style: TextStyle(fontSize: 18)),
            );
          }

          // 解析 coordinates
          List<dynamic> coordinates = [];
          try {
            coordinates = jsonDecode(detection.coordinates);
          } catch (e) {
            print('解析 coordinates 失败: $e');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 显示图片
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(detection.imageUrl),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) => const Icon(Icons.error),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 检测信息
                Text(
                  '检测 #${detection.id}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('时间: ${detection.timestamp}'),
                Text('材料损失: ${detection.materialLost ? '是' : '否'}'),
                Text('严重程度: ${detection.severity}'),
                Text('摘要: ${detection.summary}'),
                const SizedBox(height: 20),
                // 坐标信息
                const Text(
                  '检测框坐标',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (coordinates.isNotEmpty)
                  ...coordinates.map((coord) => ListTile(
                        title: Text('类别: ${coord['class'] ?? '未知'}'),
                        subtitle: Text(
                          '坐标: (${coord['x']}, ${coord['y']})\n'
                          '宽高: (${coord['w']}, ${coord['h']})\n'
                          '置信度: ${coord['confidence']}',
                        ),
                      ))
                else
                  const Text('无检测框'),
                const SizedBox(height: 20),
                // 下载按钮
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await provider.downloadResult(context, detection);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('下载成功')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('下载失败: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('下载结果'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6699),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}