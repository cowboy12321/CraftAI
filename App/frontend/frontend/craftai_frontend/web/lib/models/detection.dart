class Detection {
  final int id;
  final String imageUrl;
  final bool materialLost;
  final String severity;
  final String coordinates; // YOLOv11可能返回JSON字符串
  final String summary;
  final String timestamp;

  Detection({
    required this.id,
    required this.imageUrl,
    required this.materialLost,
    required this.severity,
    required this.coordinates,
    required this.summary,
    required this.timestamp,
  });
}