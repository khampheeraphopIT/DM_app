import 'package:flutter/material.dart';
import '../models/prediction.dart';
import '../utils/dateTime.dart';

const Map<String, String> diseaseNameMap = {
  'Healthy': 'ปกติ',
  'Yellow': 'โรคใบเหลือง',
  'Rust': 'โรคราสนิม',
  'Redrot': 'โรคเน่าแดง',
  'Mosaic': 'โรคใบด่าง',
  'Notsugarcane': 'ไม่ใช่ใบอ้อย',
};

const Map<String, String> diseaseDescriptionMap = {
  'Healthy': 'ใบอ้อยอยู่ในสภาพปกติ ไม่พบอาการของโรค',
  'Yellow': 'พบอาการใบเหลือง อาจเกิดจากเชื้อไวรัสหรือขาดธาตุอาหาร',
  'Rust': 'พบจุดสนิมบนใบ อาจเกิดจากเชื้อราสนิม (Rust disease)',
  'Redrot': 'พบอาการเน่าแดงในใบหรือบริเวณโคนต้น',
  'Mosaic': 'พบลวดลายด่างบนใบ อาจเกิดจากไวรัสใบด่าง',
  'Notsugarcane':
      'ภาพที่อัปโหลดไม่ใช่ใบอ้อย กรุณาอัปโหลดภาพใบอ้อยที่ชัดเจนอีกครั้ง',
};

class ResultDisplay extends StatelessWidget {
  final PredictionResult result;

  const ResultDisplay({super.key, required this.result});

  String getDiseaseName(String? disease) {
    if (disease == null) return '-';
    return diseaseNameMap[disease] ?? disease;
  }

  String getDiseaseDescription(String? disease) {
    if (disease == null) return '';
    return diseaseDescriptionMap[disease] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final diseaseName = getDiseaseName(result.disease);
    final description = getDiseaseDescription(result.disease);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ผลการวิเคราะห์',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (result.error != null)
              Text(
                result.error!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ผลการตรวจ: $diseaseName',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                      child: Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  if (result.confidence != null)
                    Text('ระดับความมั่นใจของโมเดล: ${result.confidence}'),
                  if (result.riskLevel != null)
                    Text('ระดับความเสี่ยงในการเกิดโรค: ${result.riskLevel}'),
                  if (result.province != null)
                    Text('จังหวัด: ${result.province}'),
                  Text('เวลาที่ตรวจ: ${dateTimeTH(result.timestamp ?? '')}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
