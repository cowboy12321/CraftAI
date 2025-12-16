import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/detection_provider.dart';
import '../services/gpt_service.dart';
import '../models/detection.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ReportPage extends StatefulWidget {
  final Detection? detection;
  const ReportPage({super.key, this.detection});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String? reportContent;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    final detection = widget.detection ?? context.read<DetectionProvider>().currentDetection;
    if (detection != null) {
      _generateReport(detection);
    } else {
      setState(() {
        errorMessage = '未找到检测数据';
        isLoading = false;
      });
    }
  }

  Future<void> _generateReport(Detection detection) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final gptService = GptService();
      reportContent = await gptService.generateReportContent(detection).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('请求超时'),
      );
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

  Future<void> _downloadReport() async {
    if (reportContent == null) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsString(reportContent!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('报告保存至: ${file.path}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存失败: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final detection = widget.detection ?? context.read<DetectionProvider>().currentDetection;
    return Scaffold(
      appBar: AppBar(
        title: const Text('智能检测报告',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          )),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade800,
                Colors.blue.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: isLoading
              ? _buildLoading()
              : errorMessage != null
                  ? _buildError()
                  : _buildReport(),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade800),
            strokeWidth: 5,
          ),
          const SizedBox(height: 20),
          Text(
            '正在生成专业检测报告...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.blue.shade900,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '请稍候片刻',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade800,
            size: 60,
          ),
          const SizedBox(height: 20),
          Text(
            errorMessage!,
            style: TextStyle(
              fontSize: 18,
              color: Colors.red.shade900,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          ElevatedButton.icon(
            icon: Icon(Icons.refresh, color: Colors.white),
            label: const Text('重新生成', style: TextStyle(fontSize: 16)),
            onPressed: () => _generateReport(widget.detection!),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              backgroundColor: Colors.blue.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  '专业检测报告',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Divider(color: Colors.blue.shade200),
                const SizedBox(height: 15),
                Text(
                  '检测编号: #${widget.detection?.id.toString().padLeft(8, '0').substring(0, 8)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Text(
                  reportContent ?? '无可用内容',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _downloadReport,
          icon: Icon(Icons.download_rounded, size: 24),
          label: const Text('下载完整报告', style: TextStyle(fontSize: 17)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.blue.shade800,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
          ),
        ),
      ],
    );
  }
}