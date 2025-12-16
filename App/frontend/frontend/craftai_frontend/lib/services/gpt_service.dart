import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../models/detection.dart';

class GptService {
  Future<String> generateSummary(String input) async {
    return input;
  }

  Future<String> generateReportContent(Detection detection) async {
    const maxRetries = 3;
    int attempt = 0;

    while (attempt < maxRetries) {
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
            'model': 'moonshot-v1-8k',
            'messages': [
              {
                'role': 'user',
                'content': '基于以下检测结果生成详细报告，包含问题描述、严重程度、修复建议和文化价值评估：\n$input',
              },
            ],
            'max_tokens': 500,
            'temperature': 0.7,
          }),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['choices'][0]['message']['content'].trim();
        }
        throw Exception('生成报告失败: ${response.body}');
      } catch (e) {
        attempt++;
        if (attempt == maxRetries) {
          print('生成报告失败，第 $attempt 次尝试: $e');
          rethrow;
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    return '无法生成报告';
  }
}