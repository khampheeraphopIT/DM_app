import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage({required bool fromCamera}) async {
    try {
      // ขอ permission ตามประเภท
      final permisssion = fromCamera ? Permission.camera : Permission.photos;
      final status = await permisssion.request();

      if (!status.isGranted) {
        throw Exception(
          fromCamera ? 'Camera permission denied' : 'Gallery permission denied',
        );
      }

      return await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
      );
    } catch (e) {
      throw Exception('Error picking image: $e');
    }
  }
}
