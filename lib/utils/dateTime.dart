import 'package:intl/intl.dart';

String dateTimeTH(String timestamp) {
  try {
    final dateTime = DateTime.parse(timestamp).toLocal();
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  } catch (e) {
    return timestamp;
  }
}
