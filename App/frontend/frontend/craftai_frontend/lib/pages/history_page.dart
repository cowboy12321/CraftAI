import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/detection_provider.dart';
import '../widgets/app_drawer.dart';
import '../utils/constants.dart'; // 确保这里定义了 BASE_URL

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 页面加载完毕后自动获取最新数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DetectionProvider>(context, listen: false).loadHistory(context);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 辅助函数：处理图片URL，兼容 http/https 和相对路径
  String _resolveImageUrl(String url) {
    if (url.startsWith('http')) return url;
    // 移除可能存在的 file:// 前缀
    final cleanPath = url.replaceFirst(RegExp(r'^file://'), '');
    // 拼接 BASE_URL (例如 http://localhost:5000/Uploads/xxx.jpg)
    return '$BASE_URL${cleanPath.startsWith('/') ? cleanPath : '/$cleanPath'}';
  }

  @override
  Widget build(BuildContext context) {
    final detectionProvider = Provider.of<DetectionProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('检测历史档案'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => detectionProvider.loadHistory(context),
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // 搜索栏
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索检测编号或日期 (YYYY-MM-DD)',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          detectionProvider.filterHistory('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              onChanged: (query) => detectionProvider.filterHistory(query),
            ),
          ),
          
          // 列表区域
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => detectionProvider.loadHistory(context),
              child: detectionProvider.filteredHistory.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: 400,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              '暂无相关记录',
                              style: TextStyle(color: Colors.grey[500], fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: detectionProvider.filteredHistory.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = detectionProvider.filteredHistory[index];
                        
                        // 动态颜色：根据严重程度
                        Color statusColor = Colors.green;
                        String statusText = item.severity;
                        if (item.severity == '严重') {
                          statusColor = const Color(0xFFC0392B); // 深红
                        } else if (item.severity == '中度') {
                          statusColor = const Color(0xFFD35400); // 橘色
                        } else if (item.severity == '轻微') {
                          statusColor = const Color(0xFFF39C12); // 黄色
                        }

                        return Card(
                          elevation: 2,
                          shadowColor: Colors.black.withOpacity(0.1),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade100),
                          ),
                          child: InkWell(
                            onTap: () {
                              detectionProvider.setCurrentDetection(item);
                              Navigator.pushNamed(context, '/detection');
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  // 图片缩略图
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[200],
                                      child: Image.network(
                                        _resolveImageUrl(item.imageUrl),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(Icons.broken_image, color: Colors.grey[400]);
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // 文本信息
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '编号 #${item.id}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Color(0xFF2C3E50),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: statusColor.withOpacity(0.5)),
                                              ),
                                              child: Text(
                                                statusText,
                                                style: TextStyle(
                                                  color: statusColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              item.timestamp.split('T')[0], // 简化日期显示
                                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item.summary.isNotEmpty ? item.summary : '暂无智能摘要',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.grey[800], fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}