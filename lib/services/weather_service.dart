// services/weather_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class WeatherService {
  static const String apiWeatherKey = '77b66e88815ead140b47301470f23127';
  static const String weatherBaseUrl =
      'https://api.openweathermap.org/data/2.5/weather';
  static const String geoBaseUrl =
      'https://api.openweathermap.org/geo/1.0/reverse';

  // เพิ่มแค่ map นี้
  static const Map<String, String> _englishToThai = {
    'Bangkok': 'กรุงเทพมหานคร',
    'Krung Thep Maha Nakhon': 'กรุงเทพมหานคร',
    'Krabi': 'กระบี่',
    'Kanchanaburi': 'กาญจนบุรี',
    'Kalasin': 'กาฬสินธุ์',
    'Kamphaeng Phet': 'กำแพงเพชร',
    'Khon Kaen': 'ขอนแก่น',
    'Chanthaburi': 'จันทบุรี',
    'Chachoengsao': 'ฉะเชิงเทรา',
    'Chonburi': 'ชลบุรี',
    'Chai Nat': 'ชัยนาท',
    'Chaiyaphum': 'ชัยภูมิ',
    'Chumphon': 'ชุมพร',
    'Trang': 'ตรัง',
    'Trat': 'ตราด',
    'Tak': 'ตาก',
    'Nakhon Nayok': 'นครนายก',
    'Nakhon Pathom': 'นครปฐม',
    'Nakhon Phanom': 'นครพนม',
    'Nakhon Ratchasima': 'นครราชสีมา',
    'Nakhon Si Thammarat': 'นครศรีธรรมราช',
    'Nakhon Sawan': 'นครสวรรค์',
    'Nonthaburi': 'นนทบุรี',
    'Narathiwat': 'นราธิวาส',
    'Nan': 'น่าน',
    'Bueng Kan': 'บึงกาฬ',
    'Buriram': 'บุรีรัมย์',
    'Pathum Thani': 'ปทุมธานี',
    'Prachuap Khiri Khan': 'ประจวบคีรีขันธ์',
    'Prachinburi': 'ปราจีนบุรี',
    'Pattani': 'ปัตตานี',
    'Phra Nakhon Si Ayutthaya': 'พระนครศรีอยุธยา',
    'Phayao': 'พะเยา',
    'Phangnga': 'พังงา',
    'Phatthalung': 'พัทลุง',
    'Phichit': 'พิจิตร',
    'Phitsanulok': 'พิษณุโลก',
    'Phuket': 'ภูเก็ต',
    'Maha Sarakham': 'มหาสารคาม',
    'Mukdahan': 'มุกดาหาร',
    'Yala': 'ยะลา',
    'Yasothon': 'ยโสธร',
    'Ranong': 'ระนอง',
    'Rayong': 'ระยอง',
    'Ratchaburi': 'ราชบุรี',
    'Roi Et': 'ร้อยเอ็ด',
    'Lopburi': 'ลพบุรี',
    'Lampang': 'ลำปาง',
    'Lamphun': 'ลำพูน',
    'Sisaket': 'ศรีสะเกษ',
    'Sakon Nakhon': 'สกลนคร',
    'Songkhla': 'สงขลา',
    'Satun': 'สตูล',
    'Samut Prakan': 'สมุทรปราการ',
    'Samut Songkhram': 'สมุทรสงคราม',
    'Samut Sakhon': 'สมุทรสาคร',
    'Saraburi': 'สระบุรี',
    'Sa Kaeo': 'สระแก้ว',
    'Sing Buri': 'สิงห์บุรี',
    'Suphan Buri': 'สุพรรณบุรี',
    'Surat Thani': 'สุราษฎร์ธานี',
    'Surin': 'สุรินทร์',
    'Sukhothai': 'สุโขทัย',
    'Nong Khai': 'หนองคาย',
    'Nong Bua Lamphu': 'หนองบัวลำภู',
    'Amnat Charoen': 'อำนาจเจริญ',
    'Udon Thani': 'อุดรธานี',
    'Uttaradit': 'อุตรดิตถ์',
    'Uthai Thani': 'อุทัยธานี',
    'Ubon Ratchathani': 'อุบลราชธานี',
    'Ang Thong': 'อ่างทอง',
    'Chiang Rai': 'เชียงราย',
    'Chiang Mai': 'เชียงใหม่',
    'Phetchaburi': 'เพชรบุรี',
    'Phetchabun': 'เพชรบูรณ์',
    'Loei': 'เลย',
    'Phrae': 'แพร่',
    'Mae Hong Son': 'แม่ฮ่องสอน',
  };

  static Future<Map<String, String>?> getWeatherAndProvince(
    double lat,
    double lon,
  ) async {
    try {
      // 1. ดึงจังหวัดจาก geocoding (เหมือนเดิม)
      final rawProvince = await _getProvinceFromCoords(lat, lon);
      if (rawProvince == null) return null;

      // 2. แปลงเป็นไทย
      final thaiProvince = _englishToThai[rawProvince];
      if (thaiProvince == null) {
        debugPrint('ไม่พบจังหวัดใน map: $rawProvince');
        return null;
      }

      print('จังหวัด: $rawProvince → $thaiProvince');

      // 3. ดึงสภาพอากาศ
      final weatherUrl = Uri.parse(
        '$weatherBaseUrl?lat=$lat&lon=$lon&appid=$apiWeatherKey&units=metric&lang=th',
      );
      final response = await http.get(weatherUrl);
      if (response.statusCode != 200) {
        debugPrint('Weather API error: ${response.statusCode}');
        return null;
      }

      final data = json.decode(response.body);

      return {
        'province': thaiProvince,
        'temperature': data['main']['temp'].toString(),
        'humidity': data['main']['humidity'].toString(),
        'rainfall': (data['rain']?['1h'] ?? 0.0).toString(),
      };
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }

  // เหมือนเดิมทุกอย่าง
  static Future<String?> _getProvinceFromCoords(double lat, double lon) async {
    final url = Uri.parse(
      '$geoBaseUrl?lat=$lat&lon=$lon&limit=1&appid=$apiWeatherKey',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final state =
              data[0]['state']?.toString() ?? data[0]['name']?.toString();
          if (state != null && state.isNotEmpty) {
            print('Raw state: $state');
            return _cleanProvinceName(state);
          }
        }
      }
    } catch (e) {
      debugPrint('Geocoding Error: $e');
    }
    return null;
  }

  static String _cleanProvinceName(String name) {
    return name
        .replaceAll(' Province', '')
        .replaceAll(' จ.', '')
        .replaceAll('จังหวัด', '')
        .trim();
  }
}
