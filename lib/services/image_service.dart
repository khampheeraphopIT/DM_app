import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

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

  Future<XFile?> pickImage({required bool fromCamera}) async {
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
        imageQuality: 80,
      );

      if (xFile == null) return null;

      // ตรวจสอบนามสกุล
      final extension = xFile.path.split('.').last.toLowerCase();
      if (!_allowedExtensions.contains(extension)) {
        throw Exception('รองรับเฉพาะไฟล์ภาพ: JPG, PNG, GIF, BMP, WEBP');
      }

      return xFile;
    } catch (e) {
      throw Exception('ไม่สามารถเลือกภาพได้: $e');
    }
  }
}
