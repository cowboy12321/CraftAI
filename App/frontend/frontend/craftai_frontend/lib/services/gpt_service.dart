import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../models/detection.dart';

class GptService {
  Future<String> generateSummary(String input) async {
    try {
      final response = await http.post(
        Uri.parse(GPT_API_URL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $GPT_API_KEY',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {'role': 'user', 'content': '生成摘要：$input'},
          ],
          'max_tokens': 100,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      }
      throw Exception('生成摘要失败: ${response.body}');
    } catch (e) {
      print('生成摘要错误: $e');
      return '无法生成摘要';
    }
  }

  Future<String> generateReportContent(Detection detection) async {
    try {
      final input = '''
      检测 ID: ${detection.id}
      图片: ${detection.imageUrl}
      材料损失: ${detection.materialLost ? '是' : '否'}
      严重程度: ${detection.severity}
      坐标: ${detection.coordinates}
      摘要: ${detection.summary}
      时间: ${detection.timestamp}
      ''';

      final response = await http.post(
        Uri.parse(GPT_API_URL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $GPT_API_KEY',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'user',
              'content': '基于以下检测结果生成详细报告，包含问题描述、严重程度、修复建议和文化价值评估：\n$input',
            },
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      }
      throw Exception('生成报告失败: ${response.body}');
    } catch (e) {
      print('生成报告错误: $e');
      throw Exception('无法生成报告: $e');
    }
  }
}
