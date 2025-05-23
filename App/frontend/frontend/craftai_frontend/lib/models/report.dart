class Report {
  final String id;
  final String detectionId;
  final String content;
  final String timestamp;

  Report({
    required this.id,
    required this.detectionId,
    required this.content,
    required this.timestamp,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      detectionId: json['detection_id'],
      content: json['content'],
      timestamp: json['timestamp'],
    );
  }
}