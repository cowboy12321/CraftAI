import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../providers/detection_provider.dart';
import '../widgets/app_drawer.dart';
import '../utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'report_page.dart';
import '../models/detection.dart';

class DetectionPage extends StatelessWidget {
  const DetectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '检测结果分析',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: Consumer<DetectionProvider>(
        builder: (context, provider, child) {
          final detection = provider.currentDetection;
          if (detection == null) {
            return _buildEmptyState(context, textTheme);
          }

          List<dynamic> coordinates = [];
          try {
            coordinates = jsonDecode(detection.coordinates);
          } catch (e) {
            debugPrint('坐标解析失败: $e');
          }

          return Container(
            color: Colors.grey.shade50,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(context, detection, textTheme),
                  const SizedBox(height: 24),
                  _buildDetectionInfo(detection, textTheme),
                  const SizedBox(height: 24),
                  _buildCoordinateList(coordinates, textTheme),
                  const SizedBox(height: 32),
                  _buildActionButtons(context, detection),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '未选择检测记录',
            style: textTheme.titleLarge?.copyWith(
              fontSize: 20,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '返回上传页面',
              style: TextTheme().labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(
      BuildContext context, Detection detection, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '图片预览',
          style: textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageCard('原图', detection.imageUrl, context),
                  if (isWide)
                    const SizedBox(width: 16)
                  else
                    const SizedBox(height: 16),
                  _buildImageCard('标注图', detection.annotatedImageUrl, context),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildImageCard(String title, String? url, BuildContext context) {
    String? finalUrl;
    if (url != null && url.isNotEmpty) {
      final cleanedUrl = url.replaceFirst(RegExp(r'^file://'), '');
      if (Uri.tryParse(cleanedUrl)?.hasScheme == true &&
          (cleanedUrl.startsWith('http://') || cleanedUrl.startsWith('https://'))) {
        finalUrl = cleanedUrl;
      } else {
        finalUrl = '$BASE_URL${cleanedUrl.startsWith('/') ? cleanedUrl : '/$cleanedUrl'}';
      }
    }

    debugPrint('加载图片: $finalUrl');

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1,
                child: finalUrl != null
                    ? Image.network(
                        finalUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          return progress == null
                              ? child
                              : Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                        },
                        errorBuilder: (_, error, ___) {
                          debugPrint('图片加载失败: $error, URL: $finalUrl');
                          return _buildImageError(context);
                        },
                      )
                    : _buildImageError(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageError(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_rounded,
            size: 48,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 12),
          Text(
            '无法加载图片',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () async {
              try {
                await Provider.of<DetectionProvider>(context, listen: false)
                    .refreshCurrentDetection(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('刷新失败: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(
              '重试',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionInfo(Detection detection, TextTheme textTheme) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_rounded, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 12),
                Text(
                  '检测详情',
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
                '检测编号', '#${detection.id.toString().padLeft(8, '0')}'),
            const SizedBox(height: 12),
            _buildInfoRow('检测时间', detection.timestamp),
            const SizedBox(height: 12),
            _buildInfoRow('材料损失', detection.materialLost ? '是' : '否'),
            const SizedBox(height: 12),
            _buildInfoRow('严重程度', detection.severity),
            const SizedBox(height: 16),
            Text(
              '摘要',
              style: textTheme.titleSmall?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              detection.summary.isEmpty ? '无摘要' : detection.summary,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoordinateList(List<dynamic> coordinates, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on_rounded, color: Colors.blue.shade700, size: 24),
            const SizedBox(width: 12),
            Text(
              '检测坐标',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        coordinates.isEmpty
            ? _buildEmptyCoordinates()
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: coordinates.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final coord = coordinates[index];
                  return _buildCoordinateCard(coord);
                },
              ),
      ],
    );
  }

  Widget _buildCoordinateCard(Map<String, dynamic> coord) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coord['class']?.toString() ?? '未知类别',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '坐标: (${coord['x']?.toStringAsFixed(0) ?? '0'}, ${coord['y']?.toStringAsFixed(0) ?? '0'})',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                Text(
                  '尺寸: ${coord['w']?.toStringAsFixed(0) ?? '0'}×${coord['h']?.toStringAsFixed(0) ?? '0'}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            '置信度: ${(coord['confidence'] * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCoordinates() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.grey.shade500, size: 24),
          const SizedBox(width: 12),
          Text(
            '未检测到坐标数据',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Detection detection) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.file_download_rounded,
            label: '下载结果',
            color: Colors.pink.shade500,
            onPressed: () => _handleDownload(context, detection),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.description_rounded,
            label: '生成报告',
            color: Colors.blue.shade600,
            onPressed: () => _navigateToReport(context, detection),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTapDown: (_) {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDownload(BuildContext context, Detection detection) async {
    try {
      final provider = Provider.of<DetectionProvider>(context, listen: false);
      await provider.downloadResult(context, detection);
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/detection_${detection.id}.jpg';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('下载成功: $path'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('下载失败: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToReport(BuildContext context, Detection detection) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ReportPage(detection: detection),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.2),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}