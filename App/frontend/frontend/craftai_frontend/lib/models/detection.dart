import 'dart:convert';

class Detection {
  final int id;
  final String imageUrl;
  final String? annotatedImageUrl;
  final bool materialLost;
  final String severity;
  final String coordinates;
  final String summary;
  final String timestamp;

  Detection({
    required this.id,
    required this.imageUrl,
    this.annotatedImageUrl,
    required this.materialLost,
    required this.severity,
    required this.coordinates,
    required this.summary,
    required this.timestamp,
  });

  static const Map<String, String> _typeMap = {
    'EG': '裂缝',
    'WS': '表面剥落',
    'DS': '变色与沉积物',
    'EF': '泛碱',
    'IR': '不当修补',
    'BI': '生物入侵',
    'MS': '砖缝失效',
  };

  factory Detection.fromJson(Map<String, dynamic> json) {
    String coordinates = json['coordinates'] ?? '[]';
    try {
      List<dynamic> coords = jsonDecode(coordinates);
      for (var coord in coords) {
        if (coord['class'] != null) {
          coord['class'] = _typeMap[coord['class']] ?? coord['class'];
        }
      }
      coordinates = jsonEncode(coords);
    } catch (e) {
      print('解析 coordinates 失败: $e');
    }

    return Detection(
      id: json['id'],
      imageUrl: json['image_url'],
      annotatedImageUrl: json['annotated_image_url'],
      materialLost: json['material_lost'],
      severity: json['severity'],
      coordinates: coordinates,
      summary: json['summary'] ?? '',
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'annotated_image_url': annotatedImageUrl,
      'material_lost': materialLost,
      'severity': severity,
      'coordinates': coordinates,
      'summary': summary,
      'timestamp': timestamp,
    };
  }
}