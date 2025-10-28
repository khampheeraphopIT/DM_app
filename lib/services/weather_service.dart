import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // ใส่ API Key ของคุณตรงนี้
  static const String apiWeatherKey = '77b66e88815ead140b47301470f23127';
  static const String baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  /// ดึงชื่อจังหวัด (ภาษาไทย) + สภาพอากาศ จากพิกัด
  static Future<Map<String, String>?> getWeatherAndProvince(
    double lat,
    double lon,
  ) async {
    final url = Uri.parse(
      '$baseUrl?lat=$lat&lon=$lon&appid=$apiWeatherKey&units=metric&lang=th',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // ชื่อจังหวัดภาษาไทย (เช่น "ลพบุรี", "กรุงเทพมหานคร")
        String province = data['name'] ?? 'ไม่พบจังหวัด';
        province = province
            .replaceAll('อำเภอ', '')
            .replaceAll('เมือง', '')
            .replaceAll('จ.', '')
            .replaceAll('จังหวัด', '')
            .trim();

        return {
          'province': province,
          'temperature': data['main']['temp'].toString(),
          'humidity': data['main']['humidity'].toString(),
          'rainfall': (data['rain']?['1h'] ?? 0.0).toString(),
        };
      }
    } catch (e) {
      print('OpenWeather Error: $e');
    }
    return null;
  }
}
