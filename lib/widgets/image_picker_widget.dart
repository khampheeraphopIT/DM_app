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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('อัปโหลดรูปภาพ', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onCameraPressed,
                icon: const Icon(Icons.camera_alt, size: 20),
                label: const Text('Photo', style: TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onGalleryPressed,
                icon: const Icon(Icons.photo_library, size: 20),
                label: const Text('Gallery', style: TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(errorText!, style: const TextStyle(color: Colors.red)),
          ),
        if (imageFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Image.file(
              imageFile!,
              width: 300,
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
      ],
    );
  }
}
