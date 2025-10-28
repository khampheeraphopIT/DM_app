import 'package:flutter/material.dart';
import '../models/prediction.dart';
import '../utils/dateTime.dart';

class ResultDisplay extends StatelessWidget {
  final PredictionResult result;

  const ResultDisplay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
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
              'Result',
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
                  Text('โรค: ${result.disease}'),
                  Text('ระดับความมั่นใจของโมเดล: ${result.confidence}'),
                  Text('ระดับความเสี่ยงในการเกิดโรค: ${result.riskLevel}'),
                  Text('จังหวัด: ${result.province}'),
                  Text('อุณหภูมิ: ${result.temperature}'),
                  Text('ความชื้น: ${result.humidity}'),
                  Text('ปริมาณน้ำฝน: ${result.rainfall}'),
                  Text('เวลาที่ตรวจ: ${dateTimeTH(result.timestamp ?? '')}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
