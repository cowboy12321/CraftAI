import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/detection_provider.dart';
import '../providers/report_provider.dart';
import '../models/detection.dart';
import '../models/report.dart';
import '../widgets/app_drawer.dart';

class ReportPage extends StatefulWidget {
  final Detection? detection;
  const ReportPage({super.key, this.detection});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool isLoading = false;
  String? errorMessage;
  List<Report> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final detection = widget.detection ?? context.read<DetectionProvider>().currentDetection;
    if (detection != null) {
      try {
        final reports = await context.read<ReportProvider>().loadReports(detection.id);
        setState(() {
          _reports = reports;
        });
      } catch (e) {
        setState(() {
          errorMessage = '加载报告失败: $e';
        });
      }
    } else {
      setState(() {
        errorMessage = '未找到检测数据';
      });
    }
  }

  Future<void> _generateReport(Detection detection) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await context.read<ReportProvider>().generateReport(detection);
      await _loadReports();
    } catch (e) {
      setState(() {
        errorMessage = '报告生成失败: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _downloadReport(Report report) async {
    try {
      final file = await context.read<ReportProvider>().downloadReport(report.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('报告保存至: ${file.path}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final detection = widget.detection ?? context.read<DetectionProvider>().currentDetection;
    return Scaffold(
      appBar: AppBar(
        title: const Text('智能检测报告', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF8B4513),
        elevation: 4,
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF8B4513).withOpacity(0.1),
              const Color(0xFFF5F5F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? _buildLoading()
            : errorMessage != null
                ? _buildError()
                : _buildReportList(detection),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('正在生成报告...', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 60),
          const SizedBox(height: 20),
          Text(errorMessage!, style: const TextStyle(fontSize: 18, color: Colors.red)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: widget.detection != null ? () => _generateReport(widget.detection!) : null,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportList(Detection? detection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('检测报告', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  '检测编号: #${detection?.id.toString().padLeft(8, '0') ?? '未知'}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: detection != null ? () => _generateReport(detection) : null,
          child: const Text('生成新报告', style: TextStyle(fontSize: 18)),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _reports.isEmpty
              ? const Center(child: Text('暂无报告', style: TextStyle(fontSize: 18)))
              : ListView.builder(
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    final report = _reports[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: ListTile(
                        title: Text(
                          '报告 #${report.id}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '生成时间: ${report.timestamp}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.download, color: Color(0xFF8B4513)),
                          onPressed: () => _downloadReport(report),
                        ),
                        onTap: () {
                          context.read<ReportProvider>().setCurrentReport(report);
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: Text('报告 #${report.id}'),
                              content: SingleChildScrollView(
                                child: Text(
                                  report.content,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
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
        ),
      ],
    );
  }
}