import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/detection_provider.dart';
import '../widgets/app_drawer.dart';
import 'package:flutter/foundation.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  XFile? _selectedImage;
  XFile? _processedImage;
  final ImagePicker _picker = ImagePicker();
  // 默认全选，避免用户忘记选
  final Set<String> _selectedTypes = {'色差', '表面剥落', '过大缝隙', '水渍'};
  bool _isProcessing = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _processedImage = null;
      });
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先选择图片')));
      return;
    }
    if (_selectedTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请至少选择一种检测类型')));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final provider = Provider.of<DetectionProvider>(context, listen: false);
      provider.setCategories(_selectedTypes.toList());
      await provider.uploadSingleImage(context, _selectedImage!);
      setState(() {
        _processedImage = provider.processedImage;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('错误: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('智能病害检测')),
      drawer: const AppDrawer(),
      body: Container(
        color: Colors.grey[100], // 浅灰背景
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 响应式断点：宽度大于 900 则使用左右分栏
            bool isWide = constraints.maxWidth > 900;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 左侧：图片预览区 (占 65%)
                  Expanded(
                    flex: 65,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: _buildImageArea(theme),
                    ),
                  ),
                  // 右侧：控制面板区 (占 35%)
                  Expanded(
                    flex: 35,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(-5, 0))
                        ],
                      ),
                      padding: const EdgeInsets.all(32.0),
                      child: _buildControlPanel(theme),
                    ),
                  ),
                ],
              );
            } else {
              // 窄屏：上下滚动布局
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildImageArea(theme),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: _buildControlPanel(theme),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // 构建图片展示区域
  Widget _buildImageArea(ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // 原图
              Expanded(child: _buildImageBox("原始图像", _selectedImage, false)),
              if (_processedImage != null) ...[
                const SizedBox(width: 20),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                const SizedBox(width: 20),
                // 结果图
                Expanded(child: _buildImageBox("AI 标注结果", _processedImage, true)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageBox(String title, XFile? file, bool isResult) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 12),
        Expanded(
          child: InkWell(
            onTap: isResult ? null : _pickImage, // 点击原图框也可上传
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isResult ? Colors.green.withOpacity(0.5) : Colors.grey.withOpacity(0.3), width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
              ),
              child: file == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('点击上传图片', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: kIsWeb
                          ? Image.network(
                              file.path, // 在 Web 上，XFile.path 是一个 blob:http://... 的网络地址
                              fit: BoxFit.contain,
                            )
                          : Image.file(
                              File(file.path), // 只有在移动端才转为 File
                              fit: BoxFit.contain,
                            ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // 构建右侧控制面板
  Widget _buildControlPanel(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("参数配置", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor)),
        const SizedBox(height: 32),
        
        const Text("1. 选择检测病害类型", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ['色差', '表面剥落', '过大缝隙', '水渍'].map((type) {
            final isSelected = _selectedTypes.contains(type);
            return FilterChip(
              label: Text(type),
              selected: isSelected,
              showCheckmark: false,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.grey[100],
              selectedColor: theme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // 加大触控区
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedTypes.add(type);
                  } else {
                    _selectedTypes.remove(type);
                  }
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 40),
        
        const Text("2. 执行操作", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        
        // 按钮组 - 垂直排列，大尺寸
        SizedBox(
          width: double.infinity,
          height: 56, // 加高按钮
          child: ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.upload_file),
            label: const Text("重新上传图片"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black87,
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _processImage,
            icon: _isProcessing 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
              : const Icon(Icons.analytics_outlined),
            label: Text(_isProcessing ? "正在智能分析..." : "开始检测"),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: theme.primaryColor.withOpacity(0.4),
            ),
          ),
        ),

        const Spacer(), // 将详情按钮顶到底部
        
        if (_processedImage != null)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/detection'),
              icon: const Icon(Icons.visibility),
              label: const Text("查看完整报告"),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.primaryColor, width: 2),
                foregroundColor: theme.primaryColor,
              ),
            ),
          ),
      ],
    );
  }
}