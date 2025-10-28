import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class WeatherService {
  static const String apiWeatherKey = '77b66e88815ead140b47301470f23127';
  static const String baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  /// ดึงชื่อจังหวัด + สภาพอากาศจากพิกัด
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
      } else {
        debugPrint(
          'OpenWeather API error, status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('OpenWeather Error: $e');
    }
    return null;
  }
}
