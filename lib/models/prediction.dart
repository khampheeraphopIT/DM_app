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
      timestamp: json['timestamp'] as String?,
      disease: json['disease'] as String?,
      confidence: json['confidence'] as String?,
      riskLevel: json['risk_level'] as String?,
      province: json['province'] as String?,
      temperature: json['temperature'] as String?,
      humidity: json['humidity'] as String?,
      rainfall: json['rainfall'] as String?,
      probabilities: (json['probabilities'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
      gradcamPath: json['gradcam_path'] as String?,
      error: json['error'] as String?,
    );
  }
}
