import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/detection_provider.dart';

class UploadPage extends StatefulWidget {
  final int userId;
  const UploadPage({super.key, required this.userId});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && context.mounted) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final detectionProvider = Provider.of<DetectionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('上传图片检测')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('选择图片'),
              ),
              const SizedBox(height: 16),
              if (_image != null) ...[
                Image.file(_image!, height: 200, fit: BoxFit.cover),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: detectionProvider.isLoading
                      ? null
                      : () async {
                          if (_image == null) return;
                          await detectionProvider.uploadImage(
                              _image!, widget.userId);
                          if (detectionProvider.error == null &&
                              context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('上传成功')),
                            );
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('上传失败: ${detectionProvider.error}')),
                            );
                          }
                        },
                  child: const Text('上传并检测'),
                ),
              ],
              const SizedBox(height: 16),
              if (detectionProvider.isLoading)
                const Center(child: CircularProgressIndicator()),
              if (detectionProvider.detection != null) ...[
                Text(
                  detectionProvider.detection!.materialLost
                      ? '存在材料缺失'
                      : '无明显缺陷',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('严重程度: ${detectionProvider.detection!.severity}'),
                const SizedBox(height: 10),
                Text('坐标信息: ${detectionProvider.detection!.coordinates}'),
                const SizedBox(height: 10),
                Text('检测总结: ${detectionProvider.detection!.summary}'),
                const SizedBox(height: 20),
                Image.network(
                  detectionProvider.detection!.imageUrl,
                  errorBuilder: (context, error, stackTrace) =>
                      const Text('无法加载图片'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}