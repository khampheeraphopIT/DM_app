import 'dart:io';
import 'package:flutter/material.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final String? errorText;

  const ImagePickerWidget({
    Key? key,
    this.imageFile,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'อัปโหลดภาพใบอ้อย',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onCameraPressed,
                icon: const Icon(Icons.camera_alt, size: 22),
                label: const Text(
                  'ถ่ายภาพ',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onGalleryPressed,
                icon: const Icon(Icons.photo_library, size: 22),
                label: const Text(
                  'เลือกจากคลัง',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                ),
              ),
            ),
          ],
        ),

        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        if (imageFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 400,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Image.file(imageFile!, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
