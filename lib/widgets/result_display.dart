import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/prediction.dart';

class ResultDisplay extends StatelessWidget {
  final PredictionResult result;

  const ResultDisplay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
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
            else ...[
              Text('โรค: ${result.disease}'),
              Text('ระดับความมั่นใจของโมเดล: ${result.confidence}'),
              Text('ระดับความเสี่ยงในการเกิดโรค: ${result.riskLevel}'),
              Text('จังหวัด: ${result.province}'),
              Text('อุณหภูมิ: ${result.temperature}'),
              Text('ความชื้น: ${result.humidity}'),
              Text('ปริมาณน้ำฝน: ${result.rainfall}'),
              Text('เวลาที่ตรวจ: ${result.timestamp}'),
              if (result.gradcamPath != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Grad-CAM Visualization',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                CachedNetworkImage(
                  imageUrl: 'http://localhost:8000/${result.gradcamPath}',
                  width: 300,
                  height: 200,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const Text('Failed to load image'),
                ),
              ],
            ],
            if (result.probabilities != null) ...[
              const SizedBox(height: 16),
              const Text(
                'ความน่าจะเป็นของแต่ละคลาส',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ...result.probabilities!.entries.map(
                (entry) => Text('${entry.key}: ${entry.value}'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
