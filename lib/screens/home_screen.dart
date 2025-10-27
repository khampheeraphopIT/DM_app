import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart'; // เพิ่ม import
import '../services/api_service.dart';
import '../services/image_service.dart';
import '../widgets/province_dropdown.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/result_display.dart';
import '../models/prediction.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final ImageService _imageService = ImageService();
  List<String> _provinces = [];
  String? _selectedProvince;
  File? _imageFile;
  XFile? _selectedImage; // เพิ่มแค่ตัวนี้
  PredictionResult? _result;
  String? _provinceError;
  String? _fileError;
  String? _generalError;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    try {
      final provinces = await _apiService.getProvinces();
      setState(() {
        _provinces = provinces;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _generalError = 'ไม่สามารถโหลดรายการจังหวัดได้';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(bool fromCamera) async {
    try {
      final pickedFile = await _imageService.pickImage(fromCamera: fromCamera);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile; // เก็บ XFile
          _imageFile = File(pickedFile.path); // แปลงเป็น File เพื่อแสดง
          _fileError = null;
        });
      }
    } catch (e) {
      setState(() {
        _fileError = e.toString();
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _result = null;
      _provinceError = null;
      _fileError = null;
      _generalError = null;
    });

    if (_selectedProvince == null) {
      setState(() => _provinceError = 'กรุณาเลือกจังหวัด');
      return;
    }

    if (_selectedImage == null) {
      // ตรวจสอบจาก _selectedImage
      setState(() => _fileError = 'กรุณาอัปโหลดภาพ');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _apiService.predictDisease(
        _selectedProvince!,
        _selectedImage!, // ส่ง XFile โดยตรง
      );
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _generalError = 'เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์';
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

                      _buildFormCard(),

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

                      if (_generalError != null)
                        Text(
                          _generalError!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),

                      if (_result != null) ResultDisplay(result: _result!),
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

  Widget _buildFormCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ProvinceDropdown(
              provinces: _provinces,
              selectedProvince: _selectedProvince,
              onChanged: (value) => setState(() => _selectedProvince = value),
              errorText: _provinceError,
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
