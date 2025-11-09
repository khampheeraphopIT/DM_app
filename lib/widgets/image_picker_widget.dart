import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final String? errorText;
  final bool isProcessing;
  final double progress;

  const ImagePickerWidget({
    Key? key,
    this.imageFile,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    this.errorText,
    this.isProcessing = false,
    this.progress = 0.0,
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
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // รูปจริง
                      Image.file(imageFile!, fit: BoxFit.cover),

                      // Loading overlay
                      if (isProcessing)
                        Container(
                          color: Colors.black.withOpacity(0.7),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ใช้ flutter_spinkit ที่มีอยู่แล้ว
                                const SpinKitFadingCircle(
                                  color: Colors.green,
                                  size: 50,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'กำลังวิเคราะห์โรค...',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
