import 'package:flutter/material.dart';

class LocationWidget extends StatelessWidget {
  final String? province;
  final bool isLoading;
  final String? errorText;

  const LocationWidget({
    super.key,
    this.province,
    this.isLoading = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  'ตำแหน่งปัจจุบัน',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('กำลังค้นหาตำแหน่ง...'),
                ],
              )
            else if (province != null)
              Text(
                'จังหวัด: $province',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              const Text('ไม่สามารถระบุจังหวัดได้'),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
