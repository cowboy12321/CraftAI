import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/detection_provider.dart';
import '../providers/report_provider.dart';
import '../widgets/app_drawer.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final detectionProvider = Provider.of<DetectionProvider>(context);
    final reportProvider = Provider.of<ReportProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('生成报告', style: TextStyle(fontSize: 20, color: Colors.white)),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Text(
                '检测报告',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              // 选择检测
              if (detectionProvider.currentDetection == null)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('请先选择一个检测记录', style: TextStyle(fontSize: 16, color: Colors.red)),
                  ),
                )
              else
                Card(
                  child: ListTile(
                    title: Text('检测 #${detectionProvider.currentDetection!.id}'),
                    subtitle: Text('时间: ${detectionProvider.currentDetection!.timestamp}'),
                    trailing: reportProvider.isGenerating
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              try {
                                await reportProvider.generateReport(detectionProvider.currentDetection!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('报告生成成功')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('生成失败: $e')),
                                );
                              }
                            },
                            child: const Text('生成报告'),
                          ),
                  ),
                ),
              const SizedBox(height: 20),
              // 报告内容
              if (reportProvider.currentReport != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '报告 ID: ${reportProvider.currentReport!.id}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('检测 ID: ${reportProvider.currentReport!.detectionId}'),
                        Text('时间: ${reportProvider.currentReport!.timestamp}'),
                        const SizedBox(height: 16),
                        const Text(
                          '报告内容',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(reportProvider.currentReport!.content),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await reportProvider.downloadReport();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('报告下载成功')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('下载失败: $e')),
                              );
                            }
                          },
                          child: const Text('下载报告'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('暂无报告', style: TextStyle(fontSize: 16)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}