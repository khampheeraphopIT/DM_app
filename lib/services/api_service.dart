// services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../constants/api_constants.dart';
import '../models/prediction.dart';

class ApiService {
  Future<List<String>> getProvinces() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.provincesUrl}'),
    );
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load provinces');
    }
  }

  /// รับ File แทน XFile
  Future<PredictionResult> predictDisease(
    String province,
    File imageFile, // เปลี่ยนจาก XFile → File
  ) async {
    final bytes = await imageFile.readAsBytes();
    print('Sending image: ${imageFile.path}, size: ${bytes.length} bytes');

    if (bytes.isEmpty) {
      throw Exception('ไฟล์ภาพว่าง!');
    }

    final fileName = imageFile.path.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();
    final mimeType = extension == 'png' ? 'png' : 'jpeg';

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.predictUrl}'),
    );

    request.fields['province'] = province;
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
        contentType: MediaType('image', mimeType),
      ),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    print('--- Server Response ---');
    print('Status: ${response.statusCode}');
    print('Body: $responseBody');

    if (response.statusCode == 200 || response.statusCode == 400) {
      final data = jsonDecode(responseBody);
      return PredictionResult.fromJson(data);
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }
}
