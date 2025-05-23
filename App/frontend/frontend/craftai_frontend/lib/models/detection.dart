class Detection {
  final int id;
  final String imageUrl;
  final bool materialLost;
  final String severity;
  final String coordinates; // 后端返回 JSON 字符串
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

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      id: json['id'],
      imageUrl: json['image_url'],
      materialLost: json['material_lost'],
      severity: json['severity'],
      coordinates: json['coordinates'], // 保持字符串，UI 中解析
      summary: json['summary'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'material_lost': materialLost,
      'severity': severity,
      'coordinates': coordinates,
      'summary': summary,
      'timestamp': timestamp,
    };
  }
}