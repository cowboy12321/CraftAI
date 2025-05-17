import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/detection_provider.dart';

class ReportPage extends StatelessWidget {
  final int userId;
  final int detectionId;

  const ReportPage({
    super.key,
    required this.userId,
    required this.detectionId,
  });

  @override
  Widget build(BuildContext context) {
    final detectionProvider = Provider.of<DetectionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('检测报告')),
      body: FutureBuilder(
        future: detectionProvider.fetchDetection(detectionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final detection = detectionProvider.detection;
          if (detection == null) {
            return const Center(child: Text('无法加载报告'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detection.materialLost ? '材料缺失报告' : '无缺陷报告',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Image.network(
                    detection.imageUrl,
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('无法加载图片'),
                  ),
                  const SizedBox(height: 16),
                  Text('严重程度: ${detection.severity}'),
                  const SizedBox(height: 10),
                  Text('坐标信息: ${detection.coordinates}'),
                  const SizedBox(height: 10),
                  Text('检测总结: ${detection.summary}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('报告保存中...')),
                      );
                    },
                    child: const Text('下载报告'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}