import 'package:flutter/material.dart';
import '../models/detection.dart';

class DetectionResult extends StatelessWidget {
  final Detection detection;

  const DetectionResult({super.key, required this.detection});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('检测结果', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(
          children: [
            // 原图
            Expanded(
              child: Column(
                children: [
                  const Text('原图', style: TextStyle(fontSize: 16)),
                  Container(
                    height: 300,
                    color: Colors.grey[800],
                    child: detection.originalImage != null
                        ? Image.file(detection.originalImage!, fit: BoxFit.contain)
                        : const Center(child: Text('无图片')),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // 结果图
            Expanded(
              child: Column(
                children: [
                  const Text('检测结果', style: TextStyle(fontSize: 16)),
                  Container(
                    height: 300,
                    color: Colors.grey[800],
                    child: detection.resultImage != null
                        ? Image.file(detection.resultImage!, fit: BoxFit.contain)
                        : const Center(child: Text('无结果')),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // 检测详情
        const Text('详情', style: TextStyle(fontSize: 16)),
        Text('病害类别: ${detection.details['categories'].join(', ')}'),
        Text('置信度: ${detection.details['confidence']}'),
      ],
    );
  }
}