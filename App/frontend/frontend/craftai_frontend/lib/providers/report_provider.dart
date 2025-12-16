import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/gpt_service.dart';
import '../models/detection.dart';
import '../models/report.dart';
import 'dart:io';

class ReportProvider with ChangeNotifier {
  final GptService _gptService;
  final ApiService _apiService;
  Report? _currentReport;
  List<Report> _reports = [];
  bool _isGenerating = false;

  Report? get currentReport => _currentReport;
  List<Report> get reports => _reports;
  bool get isGenerating => _isGenerating;

  ReportProvider({GptService? gptService, ApiService? apiService})
      : _gptService = gptService ?? GptService(),
        _apiService = apiService ?? ApiService();

  void setCurrentReport(Report report) {
    _currentReport = report;
    notifyListeners();
  }

  Future<void> generateReport(Detection detection) async {
    _isGenerating = true;
    notifyListeners();
    try {
      final content = await _gptService.generateReportContent(detection);
      final report = await _apiService.generateReport(detection.id);
      _currentReport = Report(
        id: report.id,
        detectionId: detection.id,
        reportUrl: report.reportUrl,
        content: content,
        timestamp: report.timestamp,
      );
      _reports.insert(0, _currentReport!);
      notifyListeners();
    } catch (e) {
      throw Exception('生成报告失败: $e');
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<List<Report>> loadReports(int detectionId) async {
    try {
      _reports = await _apiService.getReportHistory(detectionId);
      notifyListeners();
      return _reports;
    } catch (e) {
      throw Exception('加载报告失败: $e');
    }
  }

  Future<File> downloadReport(int reportId) async {
    try {
      final file = await _apiService.downloadReportFile(reportId);
      return file;
    } catch (e) {
      throw Exception('下载报告失败: $e');
    }
  }
}