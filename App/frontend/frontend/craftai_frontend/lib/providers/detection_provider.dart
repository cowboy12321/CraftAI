import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../models/detection.dart';
import '../models/model_config.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class DetectionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Detection> _history = [];
  List<Detection> _filteredHistory = [];
  Detection? _currentDetection;
  ModelConfig? _selectedModel;
  List<String> _selectedCategories = [
    '裂缝',
    '变色与沉积物',
    '表面剥落',
    '泛碱',
    '不当修补',
    '生物入侵',
    '砖缝失效',
  ];

  List<Detection> get history => _history;
  List<Detection> get filteredHistory => _filteredHistory;
  Detection? get currentDetection => _currentDetection;
  ModelConfig? get selectedModel => _selectedModel;
  List<String> get selectedCategories => _selectedCategories;

  DetectionProvider() {
    _selectedModel = ModelConfig.getAvailableModels().first;
  }

  void setModel(ModelConfig? model) {
    _selectedModel = model;
    notifyListeners();
  }

  void setCategories(List<String> categories) {
    _selectedCategories = categories;
    notifyListeners();
  }

  void setCurrentDetection(Detection detection) {
    _currentDetection = detection;
    notifyListeners();
  }

  Future<void> loadHistory(BuildContext context) async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null || token.isEmpty) {
        throw Exception('未登录，请先登录');
      }
      _history = await _apiService.getDetectionHistory(token);
      _filteredHistory = _history;
    } catch (e) {
      print('加载历史记录失败: $e');
      _history = [];
      _filteredHistory = [];
    }
    notifyListeners();
  }

  void filterHistory(String query) {
    _filteredHistory = _history
        .where((detection) =>
            detection.id.toString().contains(query) || detection.timestamp.contains(query))
        .toList();
    notifyListeners();
  }

  Future<void> uploadSingleImage(BuildContext context, File image) async {
    if (_selectedModel == null) throw Exception('未选择模型');
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null || token.isEmpty) {
        throw Exception('未登录，请先登录');
      }
      _currentDetection = await _apiService.uploadSingleImage(image, _selectedModel!, _selectedCategories, token);
      _history.insert(0, _currentDetection!);
      _filteredHistory = _history;
    } catch (e) {
      print('上传单张图片失败: $e');
      rethrow;
    }
    notifyListeners();
  }

  Future<void> uploadBatchImages(BuildContext context, List<File> images) async {
    if (_selectedModel == null) throw Exception('未选择模型');
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null || token.isEmpty) {
        throw Exception('未登录，请先登录');
      }
      final detections = await _apiService.uploadBatchImages(images, _selectedModel!, _selectedCategories, token);
      _history.insertAll(0, detections);
      _filteredHistory = _history;
      _currentDetection = detections.isNotEmpty ? detections.first : null;
    } catch (e) {
      print('上传批量图片失败: $e');
      rethrow;
    }
    notifyListeners();
  }

  Future<void> downloadResult(BuildContext context, Detection detection) async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null || token.isEmpty) {
        throw Exception('未登录，请先登录');
      }
      await _apiService.downloadResult(detection, token);
    } catch (e) {
      print('下载结果失败: $e');
    }
    notifyListeners();
  }
}