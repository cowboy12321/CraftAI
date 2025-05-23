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
  final ImagePicker _picker = ImagePicker();
  final Set<String> _selectedTypes = {};

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择图片')),
      );
      return;
    }
    if (_selectedTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少选择一种检测类型')),
      );
      return;
    }
    
    try {
      final provider = Provider.of<DetectionProvider>(context, listen: false);
      await provider.uploadSingleImage(context, _selectedImage!);
      Navigator.pushNamed(context, '/detection');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('处理失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('图片检测', style: TextStyle(fontSize: 20, color: Colors.white)),
        backgroundColor: theme.primaryColor,
        elevation: 4,
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 第一行：标题
                Text(
                  isSingleImage ? '单张图片检测' : '批量图片检测',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // 第二行：单张/批量选择
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('单张'),
                      selected: isSingleImage,
                      selectedColor: theme.primaryColor,
                      labelStyle: TextStyle(
                        color: isSingleImage ? Colors.white : Colors.black87,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          isSingleImage = true;
                          _selectedImage = null;
                        });
                      },
                    ),
                    const SizedBox(width: 20),
                    ChoiceChip(
                      label: const Text('批量'),
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
                const SizedBox(height: 30),

                // 第三行：检测类型
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    _buildDetectionTypeCard('裂缝', Icons.crop_square),
                    _buildDetectionTypeCard('变色与沉积物', Icons.color_lens),
                    _buildDetectionTypeCard('表面剥落', Icons.texture),
                    _buildDetectionTypeCard('泛碱', Icons.water_damage),
                    _buildDetectionTypeCard('不当修补', Icons.build),
                    _buildDetectionTypeCard('生物入侵', Icons.grass),
                    _buildDetectionTypeCard('砖缝失效', Icons.border_clear),
                    _buildDetectionTypeCard('其他', Icons.more_horiz),
                  ],
                ),
                const SizedBox(height: 30),

                // 第四行：图片显示区域
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(8),
                        child: Column(
                          children: [
                            const Text('原始图像', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _selectedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    )
                                  : const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                                          Text('点击上传图片', style: TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: InkWell(
                        onTap: _processImage,
                        borderRadius: BorderRadius.circular(8),
                        child: Column(
                          children: [
                            const Text('处理图像', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _selectedImage != null
                                  ? const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.image_search, size: 50, color: Colors.grey),
                                          Text('点击处理图片', style: TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                    )
                                  : const Center(
                                      child: Text('请先上传图片', style: TextStyle(color: Colors.grey)),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

Widget _buildDetectionTypeCard(String title, IconData icon) {
  final isSelected = _selectedTypes.contains(title);
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    color: isSelected ? Colors.brown : null,
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTypes.remove(title);
          } else {
            _selectedTypes.add(title);
          }
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: isSelected ? Colors.white : Colors.brown),
          const SizedBox(height: 8),
          Text(
            title, 
            textAlign: TextAlign.center, 
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : Colors.black, // 关键修改：根据选中状态设置文字颜色
            ),
          ),
        ],
      ),
    ),
  );
}
}