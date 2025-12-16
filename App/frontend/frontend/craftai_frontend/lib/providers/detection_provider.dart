import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // 新增导入
import '../models/detection.dart';
import '../models/model_config.dart';
import '../services/api_service.dart';
import '../pages/detection_page.dart';

class DetectionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Detection> _history = [];
  List<Detection> _filteredHistory = [];
  Detection? _currentDetection;
  ModelConfig? _selectedModel;
  List<String> _selectedCategories = [
    '色差',
    '表面剥落',
    '过大缝隙',
    '水渍',
  ];
  File? _processedImage;

  List<Detection> get history => _history;
  List<Detection> get filteredHistory => _filteredHistory;
  Detection? get currentDetection => _currentDetection;
  ModelConfig? get selectedModel => _selectedModel;
  List<String> get selectedCategories => _selectedCategories;
  File? get processedImage => _processedImage;

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
      _history = await _apiService.getDetectionHistory();
      _filteredHistory = _history;
      notifyListeners();
    } catch (e) {
      print('加载历史记录失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载历史失败: $e')),
      );
      _history = [];
      _filteredHistory = [];
      notifyListeners();
    }
  }

  void filterHistory(String query) {
    _filteredHistory = _history
        .where((detection) =>
            detection.id.toString().contains(query) ||
            detection.timestamp.contains(query))
        .toList();
    notifyListeners();
  }

  Future<void> uploadSingleImage(BuildContext context, File image) async {
    if (_selectedModel == null) throw Exception('未选择模型');
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      _currentDetection = await _apiService.uploadSingleImage(
          image, _selectedModel!, _selectedCategories);
      _history.insert(0, _currentDetection!);
      _filteredHistory = _history;

      // 下载处理后的图片
      await _apiService.downloadResult(_currentDetection!);
      final dir = await getApplicationDocumentsDirectory();
      _processedImage = File('${dir.path}/detection_${_currentDetection!.id}.jpg');

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('图片上传并处理成功')),
      );
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DetectionPage(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      print('上传单张图片失败: $e');
      String errorMessage = '上传失败: $e';
      if (e.toString().contains('400')) {
        errorMessage = '无效的图片文件，请检查格式或大小';
      } else if (e.toString().contains('422')) {
        errorMessage = '图片处理失败，请检查输入';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      rethrow;
    }
  }

  Future<void> uploadBatchImages(BuildContext context, List<File> images) async {
    if (_selectedModel == null) throw Exception('未选择模型');
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final detections = await _apiService.uploadBatchImages(
          images, _selectedModel!, _selectedCategories);
      _history.insertAll(0, detections);
      _filteredHistory = _history;
      _currentDetection = detections.isNotEmpty ? detections.first : null;

      // 下载第一个检测的处理后图片（可选）
      if (_currentDetection != null) {
        await _apiService.downloadResult(_currentDetection!);
        final dir = await getApplicationDocumentsDirectory();
        _processedImage = File('${dir.path}/detection_${_currentDetection!.id}.jpg');
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('批量上传并处理成功，共 ${detections.length} 张图片')),
      );
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DetectionPage(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      print('上传批量图片失败: $e');
      String errorMessage = '批量上传失败: $e';
      if (e.toString().contains('400')) {
        errorMessage = '无效的图片文件，请检查格式或大小';
      } else if (e.toString().contains('422')) {
        errorMessage = '批量图片处理失败，请检查输入';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      rethrow;
    }
  }

  Future<void> downloadResult(BuildContext context, Detection detection) async {
    try {
      await _apiService.downloadResult(detection);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('下载成功')),
      );
    } catch (e) {
      print('下载结果失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('下载失败: $e')),
      );
      rethrow;
    }
  }

  Future<void> refreshCurrentDetection(BuildContext context) async {
    if (_currentDetection == null) return;
    try {
      _currentDetection = await _apiService.getDetectionById(_currentDetection!.id);
      notifyListeners();
    } catch (e) {
      print('刷新检测数据失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('刷新失败: $e')),
      );
      rethrow;
    }
  }
}