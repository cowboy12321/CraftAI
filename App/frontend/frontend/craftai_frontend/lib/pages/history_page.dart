import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/detection_provider.dart';
import '../widgets/app_drawer.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final detectionProvider = Provider.of<DetectionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('检测历史', style: TextStyle(fontSize: 20, color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
      ),
      drawer: const AppDrawer(),
      body: detectionProvider.filteredHistory.isEmpty
          ? const Center(child: Text('暂无检测记录', style: TextStyle(fontSize: 18)))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: detectionProvider.filteredHistory.length,
              itemBuilder: (context, index) {
                final detection = detectionProvider.filteredHistory[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: ListTile(
                    leading: detection.imageUrl.isNotEmpty
                        ? Image.network(
                            detection.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                          )
                        : const Icon(Icons.image),
                    title: Text('检测 #${detection.id}'),
                    subtitle: Text('时间: ${detection.timestamp}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () async {
                        try {
                          await detectionProvider.downloadResult(context, detection);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('下载成功')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('下载失败: $e')),
                          );
                        }
                      },
                    ),
                    onTap: () {
                      detectionProvider.setCurrentDetection(detection);
                      Navigator.pushNamed(context, '/detection');
                    },
                  ),
                );
              },
            ),
    );
  }
}