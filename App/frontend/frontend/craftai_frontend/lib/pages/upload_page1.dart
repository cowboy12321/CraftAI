import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/detection_provider.dart';
import '../widgets/app_drawer.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool isSingleImage = true;
  File? _selectedImage;
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickSingleImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _pickMultipleImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images.map((xfile) => File(xfile.path)).toList();
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DetectionProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('上传图片', style: TextStyle(fontSize: 20, color: Colors.white)),
        backgroundColor: theme.primaryColor,
        elevation: 4,
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 标题
                Text(
                  isSingleImage ? '单张图片检测' : '批量图片检测',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // 切换单张/批量
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('单张图片'),
                          selected: isSingleImage,
                          selectedColor: theme.primaryColor,
                          labelStyle: TextStyle(
                            color: isSingleImage ? Colors.white : Colors.black87,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              isSingleImage = true;
                              _selectedImages = [];
                            });
                          },
                        ),
                        const SizedBox(width: 16),
                        ChoiceChip(
                          label: const Text('批量图片'),
                          selected: !isSingleImage,
                          selectedColor: theme.primaryColor,
                          labelStyle: TextStyle(
                            color: !isSingleImage ? Colors.white : Colors.black87,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              isSingleImage = false;
                              _selectedImage = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 图片选择区域
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: isSingleImage ? _pickSingleImage : _pickMultipleImages,
                          icon: const Icon(Icons.image),
                          label: Text(isSingleImage ? '选择单张图片' : '选择多张图片'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (isSingleImage && _selectedImage != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        else if (!isSingleImage && _selectedImages.isNotEmpty)
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _selectedImages[index],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: IconButton(
                                          icon: const Icon(Icons.close, color: Colors.red, size: 20),
                                          onPressed: () => _removeImage(index),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        else
                          Container(
                            height: 100,
                            alignment: Alignment.center,
                            child: Text(
                              '未选择图片',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 上传按钮
                ElevatedButton(
                  onPressed: () async {
                    try {
                      if (isSingleImage && _selectedImage != null) {
                        await provider.uploadSingleImage(context, _selectedImage!);
                        Navigator.pushNamed(context, '/detection');
                      } else if (!isSingleImage && _selectedImages.isNotEmpty) {
                        await provider.uploadBatchImages(context, _selectedImages);
                        Navigator.pushNamed(context, '/detection');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('请先选择图片')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('上传失败: $e')),
                      );
                    }
                  },
                  child: const Text('开始检测'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}