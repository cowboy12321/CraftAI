class Report {
  final int id; // 改为 int，与后端一致
  final int detectionId;
  final String reportUrl; // 报告文件 URL
  final String content; // GPT 生成内容
  final String timestamp;

  Report({
    required this.id,
    required this.detectionId,
    required this.reportUrl,
    required this.content,
    required this.timestamp,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['report_id'] ?? json['id'],
      detectionId: json['detection_id'] ?? 0,
      reportUrl: json['report_url'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }
}