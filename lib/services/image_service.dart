import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageService {
  final ImagePicker _picker;

  ImageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 2400,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  Future<String?> saveImagePermanently(XFile pickedFile) async {
    try {
      if (kIsWeb) {
        return pickedFile.path;
      }
      final documentsDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(documentsDir.path, 'quran_pages'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = 'quran_${DateTime.now().millisecondsSinceEpoch}${p.extension(pickedFile.path)}';
      final savedPath = p.join(imagesDir.path, fileName);
      final File savedFile = await File(pickedFile.path).copy(savedPath);
      return savedFile.path;
    } catch (e) {
      debugPrint('Error saving image permanently: $e');
      return pickedFile.path;
    }
  }

  Future<void> deleteImageFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }

  Future<Uint8List?> readBytes(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      debugPrint('Error reading bytes from $path: $e');
      return null;
    }
  }
}
