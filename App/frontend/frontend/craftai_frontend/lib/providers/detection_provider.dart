import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/detection.dart';

class DetectionProvider with ChangeNotifier {
  Detection? _detection;
  List<Detection> _history = [];
  String? _error;
  bool _isLoading = false;

  Detection? get detection => _detection;
  List<Detection> get history => _history;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> uploadImage(File image, int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.uploadImage(image, userId);
      _detection = Detection(
        id: response['id'],
        imageUrl: response['image_url'],
        materialLost: response['material_lost'] ?? false,
        severity: response['severity']?.toString() ?? 'N/A',
        coordinates: response['coordinates']?.toString() ?? 'N/A',
        summary: response['summary'] ?? '无摘要',
        timestamp: response['timestamp'] ?? DateTime.now().toIso8601String(),
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchHistory(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchHistory(userId);
      _history = response
          .map<Detection>((item) => Detection(
                id: item['id'],
                imageUrl: item['image_url'],
                materialLost: item['material_lost'] ?? false,
                severity: item['severity']?.toString() ?? 'N/A',
                coordinates: item['coordinates']?.toString() ?? 'N/A',
                summary: item['summary'] ?? '无摘要',
                timestamp: item['timestamp'] ?? DateTime.now().toIso8601String(),
              ))
          .toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchDetection(int detectionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchDetection(detectionId);
      _detection = Detection(
        id: response['id'],
        imageUrl: response['image_url'],
        materialLost: response['material_lost'] ?? false,
        severity: response['severity']?.toString() ?? 'N/A',
        coordinates: response['coordinates']?.toString() ?? 'N/A',
        summary: response['summary'] ?? '无摘要',
        timestamp: response['timestamp'] ?? DateTime.now().toIso8601String(),
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}