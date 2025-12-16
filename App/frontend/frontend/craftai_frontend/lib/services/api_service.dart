import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/detection.dart';
import '../models/report.dart';
import '../models/model_config.dart';
import '../utils/constants.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  // 单例模式：确保全局使用同一个实例，从而共享 Token
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // 内存中存储 Token
  String? _token;

  // 辅助函数：获取带 Token 的 Header
  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 【关键修复】保存 Token
        _token = data['token']; 
        print("登录成功，Token已保存: ${_token?.substring(0, 10)}...");
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

  Future<List<Detection>> getDetectionHistory() async {
    // 检查 Token 是否存在
    if (_token == null) throw Exception('未登录或Token已过期');

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/api/detection/history'),
        headers: _headers, // 【关键修复】注入 Header
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Detection.fromJson(json)).toList();
      }
      throw Exception('获取历史记录失败: ${response.body}');
    } catch (e) {
      print('获取历史记录错误: $e');
      rethrow;
    }
  }

  Future<Detection> uploadSingleImage(File image, ModelConfig model, List<String> categories) async {
    if (_token == null) throw Exception('未登录');

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$BASE_URL/api/detection/single'));
      
      // 添加 Header
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
      });

      // 对于 Web/Desktop，确保文件读取正确
      request.files.add(await http.MultipartFile.fromPath(
        'file', 
        image.path,
        contentType: MediaType('image', 'jpeg'), // 显式指定类型，防止兼容性问题
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

  Future<void> downloadResult(Detection detection) async {
    if (_token == null) throw Exception('未登录');
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL${detection.imageUrl}'),
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

  // 其他方法类似，只需添加 headers: _headers
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
      Uri.parse('$BASE_URL/api/report/history'), // 注意路由可能需要调整为后端实际路由
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Report.fromJson(json)).toList();
    }
    throw Exception('获取报告失败: ${response.body}');
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
    throw Exception('下载失败: ${response.body}');
  }
  
  Future<void> changePassword(int userId, String newPassword) async {
     if (_token == null) throw Exception('未登录');
     // 实现略，记得带 Header
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
      throw Exception('获取失败');
  }
}