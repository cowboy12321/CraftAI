import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<File?> pickImage() async {
  final result = await FilePicker.platform.pickFiles(type: FileType.image);
  if (result != null && result.files.single.path != null) {
    return File(result.files.single.path!);
  }
  return null;
}

Future<List<File>> pickImages() async {
  final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true);
  if (result != null) {
    return result.paths.map((path) => File(path!)).toList();
  }
  return [];
}