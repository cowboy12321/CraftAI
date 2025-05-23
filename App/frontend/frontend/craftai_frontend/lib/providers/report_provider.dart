import 'package:flutter/material.dart';
import '../models/detection.dart';
import '../models/report.dart';
import '../services/gpt_service.dart';

class ReportProvider with ChangeNotifier {
  final GptService _gptService;
  Report? _currentReport;
  bool _isGenerating = false;

  Report? get currentReport => _currentReport;
  bool get isGenerating => _isGenerating;

  ReportProvider({GptService? gptService}) : _gptService = gptService ?? GptService();

  Future<void> generateReport(Detection detection) async {
    _isGenerating = true;
    notifyListeners();
    try {
      final input = '''
      检测 ID: ${detection.id}
      图片: ${detection.imageUrl}
      材料损失: ${detection.materialLost ? '是' : '否'}
      严重程度: ${detection.severity}
      坐标: ${detection.coordinates}
      摘要: ${detection.summary}
      时间: ${detection.timestamp}
      生成简短报告，包含问题描述和修复建议。
      ''';

      final content = await _gptService.generateSummary(input);

      _currentReport = Report(
        id: DateTime.now().toString(),
        detectionId: detection.id.toString(),
        content: content,
        timestamp: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw Exception('Failed to generate report: $e');
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> downloadReport() async {
    // TODO: Implement PDF download logic here
    print('下载报告：${_currentReport?.content}');
  }
}
