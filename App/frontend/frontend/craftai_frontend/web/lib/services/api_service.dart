import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000'; // 替换为实际后端URL
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setToken(data['access_token']);
      return data;
    }
    throw Exception('登录失败: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> uploadImage(File image, int userId) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/predict'),
    );
    request.headers['Authorization'] = 'Bearer $_token';
    request.fields['user_id'] = userId.toString();
    request.files.add(await http.MultipartFile.fromPath('file', image.path));
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      return json.decode(responseBody);
    }
    throw Exception('上传失败: ${response.statusCode}');
  }

  static Future<List<dynamic>> fetchHistory(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/history?user_id=$userId'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('获取历史记录失败: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> fetchDetection(int detectionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/detection/$detectionId'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('获取检测记录失败: ${response.statusCode}');
  }
}