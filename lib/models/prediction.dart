class PredictionResult {
  final String? timestamp;
  final String? disease;
  final String? confidence;
  final String? riskLevel;
  final String? province;
  final String? temperature;
  final String? humidity;
  final String? rainfall;
  final Map<String, String>? probabilities;
  final String? gradcamPath;
  final String? error;

  PredictionResult({
    this.timestamp,
    this.disease,
    this.confidence,
    this.riskLevel,
    this.province,
    this.temperature,
    this.humidity,
    this.rainfall,
    this.probabilities,
    this.gradcamPath,
    this.error,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      timestamp: json['timestamp']?.toString(),
      disease: json['disease']?.toString(),
      confidence: json['confidence']?.toString(),
      riskLevel: json['risk_level']?.toString(),
      province: json['province']?.toString(),
      temperature: json['temperature']?.toString(),
      humidity: json['humidity']?.toString(),
      rainfall: json['rainfall']?.toString(),
      probabilities: (json['probabilities'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
      gradcamPath: json['gradcam_path']?.toString(),
      error: json['error']?.toString(),
    );
  }
}
