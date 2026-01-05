import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart'; 
import '../models/detection.dart';
import '../models/report.dart';
import '../models/model_config.dart';
import '../utils/constants.dart';
import 'package:image_picker/image_picker.dart';

class ApiService {
  // 单例模式：确保全局共享 Token
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  // 辅助函数：获取带 Token 的 Header
  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // ==================== 用户认证 ====================

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token']; // 保存 Token
        print("登录成功");
        return data;
      }
      throw Exception('登录失败: ${response.body}');
    } catch (e) {
      print('登录错误: $e');
      rethrow;
    }
  }

  Future<void> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode != 201) {
        throw Exception('注册失败: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword(int userId, String newPassword) async {
    if (_token == null) throw Exception('未登录');
    // 注意：需确认后端是否有此接口，此处为预留实现
    // 如果后端暂未实现 /api/change_password，调用此方法会报错 404
    /*
    final response = await http.post(
      Uri.parse('$BASE_URL/api/change_password'),
      headers: _headers,
      body: jsonEncode({'user_id': userId, 'new_password': newPassword}),
    );
    if (response.statusCode != 200) {
      throw Exception('修改密码失败: ${response.body}');
    }
    */
    print("修改密码接口待后端实现");
  }

  // ==================== 检测相关 ====================

  Future<List<Detection>> getDetectionHistory() async {
    if (_token == null) throw Exception('未登录');

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/api/detection/history'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Detection.fromJson(json)).toList();
      }
      throw Exception('获取历史失败: ${response.body}');
    } catch (e) {
      print('获取历史错误: $e');
      rethrow;
    }
  }

  Future<Detection> getDetectionById(int id) async {
    if (_token == null) throw Exception('未登录');
    final response = await http.get(
      Uri.parse('$BASE_URL/api/detection/$id'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return Detection.fromJson(jsonDecode(response.body));
    }
    throw Exception('获取检测详情失败');
  }

  Future<Detection> uploadSingleImage(XFile image, ModelConfig model, List<String> categories) async {
    if (_token == null) throw Exception('未登录');

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$BASE_URL/api/detection/single'));
      request.headers['Authorization'] = 'Bearer $_token';

      final bytes = await image.readAsBytes();
      
      request.files.add(http.MultipartFile.fromBytes(
        'file', 
        bytes,
        filename: image.name, // 必须手动指定文件名
        contentType: MediaType('image', 'jpeg'),
      ));
      
      request.fields['categories'] = jsonEncode(categories);
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return Detection.fromJson(jsonDecode(responseBody));
      }
      throw Exception('上传失败 (${response.statusCode}): $responseBody');
    } catch (e) {
      print('上传错误: $e');
      rethrow;
    }
  }

  // 【本次修复重点】补全批量上传方法
  Future<List<Detection>> uploadBatchImages(List<XFile> images, ModelConfig model, List<String> categories) async {
    if (_token == null) throw Exception('未登录');

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$BASE_URL/api/detection/batch'));
      request.headers['Authorization'] = 'Bearer $_token';

      for (var image in images) {
        // 【关键修改】同样改为字节流上传
        final bytes = await image.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'images', 
          bytes,
          filename: image.name,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      request.fields['categories'] = jsonEncode(categories);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(responseBody);
        return data.map((json) => Detection.fromJson(json)).toList();
      }
      throw Exception('批量上传失败 (${response.statusCode}): $responseBody');
    } catch (e) {
      print('批量上传错误: $e');
      rethrow;
    }
  }

  Future<void> downloadResult(Detection detection) async {
    if (_token == null) throw Exception('未登录');
    try {
      // 处理 URL 路径
      String url = detection.imageUrl;
      if (!url.startsWith('http')) {
        url = '$BASE_URL${url.startsWith('/') ? url : '/$url'}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/detection_${detection.id}.jpg');
        await file.writeAsBytes(response.bodyBytes);
      } else {
        throw Exception('下载失败: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ==================== 报告相关 ====================

  Future<Report> generateReport(int detectionId) async {
    if (_token == null) throw Exception('未登录');
    final response = await http.post(
      Uri.parse('$BASE_URL/api/report/generate/$detectionId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return Report.fromJson(jsonDecode(response.body));
    }
    throw Exception('生成报告失败: ${response.body}');
  }

  Future<List<Report>> getReportHistory(int detectionId) async {
    if (_token == null) throw Exception('未登录');
    final response = await http.get(
      Uri.parse('$BASE_URL/api/report/history'), 
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Report.fromJson(json)).toList();
    }
    throw Exception('获取报告历史失败: ${response.body}');
  }

  Future<File> downloadReportFile(int reportId) async {
    if (_token == null) throw Exception('未登录');
    final response = await http.get(
      Uri.parse('$BASE_URL/api/report/$reportId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/report_$reportId.pdf');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    }
    throw Exception('下载报告失败: ${response.body}');
  }
}