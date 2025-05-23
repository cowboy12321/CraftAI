class ModelConfig {
  final String name;
  final String path;

  ModelConfig({required this.name, required this.path});

  // 实现 == 和 hashCode
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelConfig && runtimeType == other.runtimeType && name == other.name && path == other.path;

  @override
  int get hashCode => name.hashCode ^ path.hashCode;

  static List<ModelConfig> getAvailableModels() {
    return [
      ModelConfig(name: 'yolov11s-seg', path: 'path/to/yolov11s'),
      ModelConfig(name: 'yolov11m-seg', path: 'path/to/yolov11m'),
      ModelConfig(name: 'yolov11l-seg', path: 'path/to/yolov11l'),
    ];
  }
}