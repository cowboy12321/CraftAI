import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/detection_provider.dart';
import 'report_page.dart';

class HistoryPage extends StatelessWidget {
  final int userId;

  const HistoryPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final detectionProvider = Provider.of<DetectionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('检测历史')),
      body: FutureBuilder(
        future: detectionProvider.fetchHistory(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (detectionProvider.history.isEmpty) {
            return const Center(child: Text('暂无历史记录'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: detectionProvider.history.length,
            itemBuilder: (context, index) {
              final detection = detectionProvider.history[index];
              return Card(
                child: ListTile(
                  leading: Image.network(
                    detection.imageUrl,
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                  ),
                  title: Text(detection.materialLost ? '材料缺失' : '无缺陷'),
                  subtitle: Text('时间: ${detection.timestamp}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportPage(
                        userId: userId,
                        detectionId: detection.id,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}