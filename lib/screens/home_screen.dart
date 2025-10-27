import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

  Future<void> _submit() async {
    setState(() {
      _result = null;
      _provinceError = null;
      _fileError = null;
      _generalError = null;
    });

    if (_selectedProvince == null) {
      setState(() {
        _provinceError = 'กรุณาเลือกจังหวัด';
      });
      return;
    }

    if (_imageFile == null) {
      setState(() {
        _fileError = 'กรุณาอัปโหลดภาพ';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.predictDisease(
        _selectedProvince!,
        _imageFile!.path,
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
      appBar: AppBar(title: const Text('ตรวจโรคใบอ้อย'), centerTitle: true),
      body: _isLoading
          ? const Center(child: SpinKitFadingCircle(color: Colors.green))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProvinceDropdown(
                    provinces: _provinces,
                    selectedProvince: _selectedProvince,
                    onChanged: (value) =>
                        setState(() => _selectedProvince = value),
                    errorText: _provinceError,
                  ),
                  const SizedBox(height: 16),
                  ImagePickerWidget(
                    imageFile: _imageFile,
                    onCameraPressed: () => _pickImage(true),
                    onGalleryPressed: () => _pickImage(false),
                    errorText: _fileError,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text('ส่งข้อมูล'),
                    ),
                  ),
                  if (_generalError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _generalError!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  if (_result != null) ResultDisplay(result: _result!),
                ],
              ),
            ),
    );
  }
}
