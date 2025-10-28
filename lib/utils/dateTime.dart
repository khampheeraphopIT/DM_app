import 'package:intl/intl.dart';

String dateTimeTH(String timestamp) {
  try {
    final dateTime = DateTime.parse(
      timestamp,
    ).toUtc().add(const Duration(hours: 7));

    // ฟอร์แมตเป็นเวลาไทย เช่น 28/10/2025 10:45
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  } catch (e) {
    return timestamp; // ถ้า parse ไม่ได้ คืนค่าเดิม
  }
}
