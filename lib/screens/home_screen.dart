import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/api_service.dart';
import '../services/image_service.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/result_display.dart';
import '../models/prediction.dart';
import '../widgets/location_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final ImageService _imageService = ImageService();

  File? _imageFile;
  XFile? _selectedImage;
  PredictionResult? _result;
  String? _fileError;
  String? _generalError;
  bool _isLoading = true;

  // ตำแหน่ง
  String? _currentProvince;
  bool _isGettingLocation = false;
  bool _locationPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // ดึงตำแหน่งจาก GPS
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _generalError = 'กรุณาเปิด Location Services';
          _isLoading = false;
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _locationPermissionDenied = true;
          _generalError = 'กรุณาเปิดตำแหน่งในตั้งค่า';
          _isGettingLocation = false;
          _isLoading = false;
        });
        return;
      }

      // 2. ดึงตำแหน่ง
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. แปลงเป็นจังหวัด
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String? province = placemarks.first.administrativeArea;
      if (province != null) {
        province = province
            .replaceAll('จ.', '')
            .replaceAll('จังหวัด', '')
            .trim();
      }

      setState(() {
        _currentProvince = province ?? 'ไม่พบจังหวัด';
        _isGettingLocation = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _generalError = 'ไม่สามารถดึงตำแหน่งได้: $e';
        _isGettingLocation = false;
        _isLoading = false;
      });
    }
  }

  // เลือกภาพ
  Future<void> _pickImage(bool fromCamera) async {
    try {
      final pickedFile = await _imageService.pickImage(fromCamera: fromCamera);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
          _imageFile = File(pickedFile.path);
          _fileError = null;
        });
      }
    } catch (e) {
      setState(() {
        _fileError = e.toString();
      });
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
        _selectedImage!,
      );
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

                      // แสดงตำแหน่งปัจจุบัน
                      _buildLocationCard(),

                      const SizedBox(height: 20),

                      // อัปโหลดภาพ
                      ImagePickerWidget(
                        imageFile: _imageFile,
                        onCameraPressed: () => _pickImage(true),
                        onGalleryPressed: () => _pickImage(false),
                        errorText: _fileError,
                      ),

                      const SizedBox(height: 30),

                      // ปุ่มส่ง
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

                      // ข้อผิดพลาด
                      if (_generalError != null)
                        Text(
                          _generalError!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),

                      // ผลลัพธ์
                      if (_result != null) ResultDisplay(result: _result!),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ภาพซ้อนกันด้านบน
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
                width: 200,
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
                width: 130,
                height: 160,
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
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 20,
                            color: Colors.red,
                            alignment: Alignment.center,
                            child: const Text(
                              'PDF',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'W-8BEN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Certificate of...',
                            style: TextStyle(fontSize: 8, color: Colors.grey),
                          ),
                          Text(
                            'Foreign Status...',
                            style: TextStyle(fontSize: 8, color: Colors.grey),
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

  // การ์ดแสดงตำแหน่ง
  Widget _buildLocationCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // แสดงจังหวัดจาก GPS
            LocationWidget(
              province: _currentProvince,
              isLoading: _isGettingLocation,
              errorText: _locationPermissionDenied
                  ? 'กรุณาเปิดตำแหน่งในตั้งค่า'
                  : null,
            ),
            const SizedBox(height: 16),
            ImagePickerWidget(
              imageFile: _imageFile,
              onCameraPressed: () => _pickImage(true),
              onGalleryPressed: () => _pickImage(false),
              errorText: _fileError,
            ),
          ],
        ),
      ),
    );
  }
}
