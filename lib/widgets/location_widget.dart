import 'package:flutter/material.dart';

class LocationWidget extends StatelessWidget {
  final String? province;
  final bool isLoading;
  final String? errorText;
  final String? temperature;
  final String? humidity;
  final String? rainfall;

  const LocationWidget({
    super.key,
    this.province,
    this.isLoading = false,
    this.errorText,
    this.temperature,
    this.humidity,
    this.rainfall,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'จังหวัด: $province',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (temperature != null &&
                      humidity != null &&
                      rainfall != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.thermostat, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'อุณหภูมิ: $temperature °C',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.opacity, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'ความชื้น: $humidity %',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.cloud, color: Colors.indigo),
                            SizedBox(width: 8),
                            Text(
                              'ปริมาณฝน: $rainfall mm',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
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
