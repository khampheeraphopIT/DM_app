import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../constants//api_constants.dart';
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

  Future<PredictionResult> predictDisease(
    String province,
    String filePath,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.predictUrl}'),
    );
    request.fields['province'] = province;
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final data = jsonDecode(responseBody);

    if (response.statusCode == 200 || response.statusCode == 400) {
      return PredictionResult.fromJson(data);
    } else {
      throw Exception('Server Occured an Error');
    }
  }
}
