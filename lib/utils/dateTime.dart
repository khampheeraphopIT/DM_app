// lib/utils/dateTime.dart
import 'package:intl/intl.dart';

String dateTimeTH(String timestamp) {
  if (timestamp.isEmpty) return 'ไม่มีข้อมูล';

  try {
    // เพิ่ม Z ปลอม → บังคับให้เป็น UTC
    String utcTimestamp = timestamp.endsWith('Z') ? timestamp : '${timestamp}Z';

    DateTime utcTime = DateTime.parse(utcTimestamp); // ตอนนี้รู้ว่าเป็น UTC
    DateTime thTime = utcTime.add(const Duration(hours: 7));

    return DateFormat('dd/MM/yyyy HH:mm น.').format(thTime);
  } catch (e) {
    print('Error: $e');
    return timestamp;
  }
}
