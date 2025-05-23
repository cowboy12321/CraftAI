import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/detection.dart';
import '../models/model_config.dart';
import '../utils/constants.dart';

class ApiService {
  static Future<void> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode != 201) throw Exception('注册失败: ${response.body}');
    } catch (e) {
      print('注册错误: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('登录失败: ${response.body}');
    } catch (e) {
      print('登录错误: $e');
      rethrow;
    }
  }

  static Future<void> changePassword(int userId, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/api/change_password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'new_password': newPassword}),
      );
      if (response.statusCode != 200) throw Exception('修改密码失败: ${response.body}');
    } catch (e) {
      print('修改密码错误: $e');
      rethrow;
    }
  }

  Future<List<Detection>> getDetectionHistory(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/api/detection/history'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Detection.fromJson(json)).toList();
      }
      throw Exception('获取历史记录失败: ${response.body}');
    } catch (e) {
      print('获取历史记录错误: $e');
      return [];
    }
  }

  Future<Detection> uploadSingleImage(File image, ModelConfig model, List<String> categories, String token) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$BASE_URL/api/detection/single'));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return Detection.fromJson(jsonDecode(responseBody));
      }
      throw Exception('上传单张图片失败: ${response.statusCode} - $responseBody');
    } catch (e) {
      print('上传单张图片错误: $e');
      rethrow;
    }
  }

  Future<List<Detection>> uploadBatchImages(List<File> images, ModelConfig model, List<String> categories, String token) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$BASE_URL/api/detection/batch'));
      request.headers['Authorization'] = 'Bearer $token';
      for (var image in images) {
        request.files.add(await http.MultipartFile.fromPath('images', image.path));
      }
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(responseBody);
        return jsonData.map((json) => Detection.fromJson(json)).toList();
      }
      throw Exception('上传批量图片失败: ${response.statusCode} - $responseBody');
    } catch (e) {
      print('上传批量图片错误: $e');
      rethrow;
    }
  }

  Future<void> downloadResult(Detection detection, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/api/detection/${detection.id}/download'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        print('下载成功: ${detection.id}');
      } else {
        throw Exception('下载失败: ${response.body}');
      }
    } catch (e) {
      print('下载结果错误: $e');
      rethrow;
    }
  }
}