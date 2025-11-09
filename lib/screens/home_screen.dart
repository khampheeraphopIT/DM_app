// lib/screens/home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../services/image_service.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/result_display.dart';
import '../models/prediction.dart';
import '../widgets/location_widget.dart';
import '../services/weather_service.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final ImageService _imageService = ImageService();

  File? _imageFile;
  File? _originalImageFile;
  File? _resizedImageFile;
  XFile? _selectedImage;
  PredictionResult? _result;
  String? _fileError;
  String? _generalError;
  bool _isLoading = true;

  String? _currentProvince;
  bool _isGettingLocation = false;
  bool _locationPermissionDenied = false;
  Map<String, String>? _preFetchedWeather;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // ดึงตำแหน่งจาก GPS + แสดง popup error ชัดเจน
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _isLoading = true;
      _generalError = null;
    });

    try {
      // 1. ตรวจสอบ Location Service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final errorMsg = 'กรุณาเปิด "บริการตำแหน่ง" ในตั้งค่าโทรศัพท์';
        _showErrorDialog(errorMsg);
        setState(() {
          _generalError = errorMsg;
          _isLoading = false;
        });
        return;
      }

      // 2. ขออนุญาต
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        final errorMsg = 'กรุณาอนุญาตตำแหน่งในการเข้าใช้งานแอป';
        _showErrorDialog(errorMsg);
        setState(() {
          _generalError = errorMsg;
          _isLoading = false;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        final errorMsg =
            'คุณปฏิเสธการเข้าถึงตำแหน่งแล้ว\nไปที่: ตั้งค่า > แอป > DM > สิทธิ์ > ตำแหน่ง > อนุญาต';
        _showErrorDialog(errorMsg, showSettings: true);
        setState(() {
          _locationPermissionDenied = true;
          _generalError = 'กรุณาเปิดตำแหน่งในตั้งค่า';
          _isLoading = false;
        });
        return;
      }

      // 3. ดึงพิกัด (มี timeout)
      Position position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          ).timeout(
            Duration(seconds: 15),
            onTimeout: () => throw TimeoutException('ดึงตำแหน่งช้าเกินไป'),
          );

      // 4. ดึงข้อมูลจาก OpenWeather
      final weatherData = await WeatherService.getWeatherAndProvince(
        position.latitude,
        position.longitude,
      );

      setState(() {
        if (weatherData != null) {
          _currentProvince = weatherData['province'];
          _preFetchedWeather = {
            'temp': weatherData['temperature']!,
            'hum': weatherData['humidity']!,
            'rain': weatherData['rainfall']!,
          };
        } else {
          final errorMsg =
              'ไม่สามารถระบุจังหวัดได้\nกรุณาเปิด GPS และลองอีกครั้ง';
          _showErrorDialog(errorMsg);
          _currentProvince = 'ไม่พบจังหวัด';
          _generalError = errorMsg;
        }
        _isGettingLocation = false;
        _isLoading = false;
      });
    } on TimeoutException catch (e) {
      final errorMsg = 'ดึงตำแหน่งช้าเกินไป\nกรุณาเปิด GPS และลองอีกครั้ง';
      _showErrorDialog(errorMsg);
      setState(() {
        _generalError = errorMsg;
        _isLoading = false;
      });
    } catch (e) {
      final errorMsg = 'เกิดข้อผิดพลาด: $e\nกรุณาลองอีกครั้ง';
      _showErrorDialog(errorMsg);
      setState(() {
        _generalError = errorMsg;
        _isLoading = false;
      });
    }
  }

  // แสดง popup error ชัดเจน
  void _showErrorDialog(String message, {bool showSettings = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  "ไม่สามารถดึงตำแหน่งได้",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxHeight: 200), // จำกัดความสูง
            child: SingleChildScrollView(
              child: Text(
                message,
                style: TextStyle(fontSize: 15), // ลดขนาดตัวอักษร
              ),
            ),
          ),
          actions: [
            if (showSettings)
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Geolocator.openAppSettings();
                },
                icon: Icon(Icons.settings, color: Colors.blue),
                label: Text(
                  "ไปที่ตั้งค่า",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _getCurrentLocation();
              },
              child: Text("ลองอีกครั้ง", style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      );
    });
  }

  // เลือกภาพ
  Future<void> _pickImage(bool fromCamera) async {
    try {
      final files = await _imageService.pickImage(fromCamera: fromCamera);
      if (files != null) {
        setState(() {
          _originalImageFile = files['original'];
          _resizedImageFile = files['resized'];
          _imageFile = _originalImageFile;
          _selectedImage = XFile(_originalImageFile!.path);
          _fileError = null;
          _result = null;
        });
      }
    } catch (e) {
      setState(() => _fileError = e.toString());
    }
  }

  // ส่งข้อมูล
  Future<void> _submit() async {
    setState(() {
      _result = null;
      _fileError = null;
      _generalError = null;
    });

    if (_currentProvince == null || _currentProvince == 'ไม่พบจังหวัด') {
      setState(() => _generalError = 'ไม่สามารถระบุจังหวัดได้');
      return;
    }

    if (_selectedImage == null) {
      setState(() => _fileError = 'กรุณาอัปโหลดภาพ');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _apiService.predictDisease(
        _currentProvince!,
        _resizedImageFile!,
      );
      print('ส่ง province ไป backend: $_currentProvince');
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _generalError = 'เกิดข้อผิดพลาด: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0), Color(0xFF212121)],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: _isLoading
            ? const Center(child: SpinKitFadingCircle(color: Colors.green))
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildStackedImages(),
                      const SizedBox(height: 30),
                      const Text(
                        'สแกนตรวจ\nโรคใบอ้อย',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildLocationCard(),
                      const SizedBox(height: 20),
                      ImagePickerWidget(
                        imageFile: _originalImageFile,
                        onCameraPressed: () => _pickImage(true),
                        onGalleryPressed: () => _pickImage(false),
                        errorText: _fileError,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                          ),
                          child: const Text(
                            'ดำเนินการต่อ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // แสดง error + ปุ่มลองใหม่
                      if (_generalError != null) ...[
                        Text(
                          _generalError!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _getCurrentLocation,
                          icon: Icon(Icons.refresh),
                          label: Text("ลองดึงตำแหน่งอีกครั้ง"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      ],
                      if (_result != null) ...[
                        ResultDisplay(result: _result!),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_selectedImage != null) {
                                setState(() => _result = null);
                                _submit();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 6,
                            ),
                            child: const Text(
                              'ลองอีกครั้ง',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStackedImages() {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 20,
            top: 30,
            child: Transform.rotate(
              angle: -0.15,
              child: Container(
                width: 140,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'S = ½bh',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'A = πr²',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'sin x',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 15,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/canediseaseone.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 20,
            child: Transform.rotate(
              angle: 0.12,
              child: Container(
                width: 140,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade400, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'สแกนอ้อย',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'ใบรายงานวิเคราะห์',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ผลการตรวจ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            'ความเสี่ยงของโรค',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: const [
                              Icon(
                                Icons.qr_code_2,
                                size: 20,
                                color: Colors.green,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Scan SugarCane',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.black54,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LocationWidget(
              province: _currentProvince,
              isLoading: _isGettingLocation,
              errorText: _locationPermissionDenied
                  ? 'กรุณาเปิดตำแหน่งในตั้งค่า'
                  : null,
              temperature: _preFetchedWeather?['temp'],
              humidity: _preFetchedWeather?['hum'],
              rainfall: _preFetchedWeather?['rain'],
            ),
          ],
        ),
      ),
    );
  }
}
