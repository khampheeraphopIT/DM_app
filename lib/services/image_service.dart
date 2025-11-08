// services/image_service.dart

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

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
  Future<File?> pickImage({required bool fromCamera}) async {
    try {
      // ขอ permission
      final permission = fromCamera ? Permission.camera : Permission.photos;
      final status = await permission.request();

      if (!status.isGranted) {
        throw Exception(
          fromCamera ? 'ไม่อนุญาตให้ใช้กล้อง' : 'ไม่อนุญาตให้เข้าถึงคลังภาพ',
        );
      }

      final XFile? xFile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85, // 100 อาจใหญ่เกิน
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (xFile == null) return null;

      // ตรวจสอบนามสกุล
      final extension = xFile.path.split('.').last.toLowerCase();
      if (!_allowedExtensions.contains(extension)) {
        throw Exception('รองรับเฉพาะไฟล์ภาพ: JPG, PNG, GIF, BMP, WEBP');
      }

      // แปลงเป็น File แล้วคืน
      return await _xFileToFile(xFile);
    } catch (e) {
      throw Exception('ไม่สามารถเลือกภาพได้: $e');
    }
  }
}
