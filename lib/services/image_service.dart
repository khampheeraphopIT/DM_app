// services/image_service.dart

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

Future<Map<String, File>> preprocessImagePair(XFile xFile) async {
  final bytes = await xFile.readAsBytes();
  if (bytes.isEmpty) throw Exception('ภาพว่าง');

  final originalImage = img.decodeImage(bytes);
  if (originalImage == null) throw Exception('ไม่สามารถ decode ภาพได้');

  // 1. ภาพต้นฉบับ → บันทึกเป็น File
  final tempDir = await getTemporaryDirectory();
  final originalFileName =
      'original_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final originalFile = File('${tempDir.path}/$originalFileName');
  await originalFile.writeAsBytes(bytes);

  final resizedImage = img.copyResize(
    originalImage,
    width: 128,
    height: 128,
    interpolation: img.Interpolation.cubic,
  );

  final jpegBytes = img.encodeJpg(resizedImage, quality: 90);

  final resizedFileName =
      'resized_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final resizedFile = File('${tempDir.path}/$resizedFileName');
  await resizedFile.writeAsBytes(jpegBytes);

  return {'original': originalFile, 'resized': resizedFile};
}

class ImageService {
  final ImagePicker _picker = ImagePicker();

  static const List<String> _allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
  ];

  /// แปลง XFile → File (ใช้ได้ทุกที่)
  Future<File> _xFileToFile(XFile xfile) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = xfile.name;
    final filePath = '${tempDir.path}/$fileName';

    final file = File(filePath);
    final bytes = await xfile.readAsBytes();

    if (bytes.isEmpty) {
      throw Exception('ภาพว่าง! ไม่สามารถอ่านได้');
    }

    await file.writeAsBytes(bytes);
    return file;
  }

  /// คืน `File` พร้อมกัน (สะดวกสุด)
  Future<Map<String, File>?> pickImage({required bool fromCamera}) async {
    try {
      final permission = fromCamera ? Permission.camera : Permission.photos;
      final status = await permission.request();

      if (!status.isGranted) {
        throw Exception(
          fromCamera ? 'ไม่อนุญาตให้ใช้กล้อง' : 'ไม่อนุญาตให้เข้าถึงคลังภาพ',
        );
      }

      final XFile? xFile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 100,
      );

      if (xFile == null) return null;

      final extension = xFile.path.split('.').last.toLowerCase();
      if (!_allowedExtensions.contains(extension)) {
        throw Exception('รองรับเฉพาะไฟล์ภาพ: JPG, PNG, GIF, BMP, WEBP');
      }

      return await preprocessImagePair(xFile);
    } catch (e) {
      throw Exception('ไม่สามารถเลือกภาพได้: $e');
    }
  }
}
