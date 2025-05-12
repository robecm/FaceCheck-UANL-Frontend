import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../services/user_api_service.dart';
import '../../models/session/session_manager.dart';
import '../../screens/student_home/student_home_screen.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class StudentFaceScreen extends StatefulWidget {
  final String name;
  final String username;
  final DateTime birthDate;
  final String faculty;
  final String matnum;
  final String email;
  final String password;

  const StudentFaceScreen({
    super.key,
    required this.name,
    required this.username,
    required this.birthDate,
    required this.faculty,
    required this.matnum,
    required this.email,
    required this.password,
  });

  @override
  StudentFaceScreenState createState() => StudentFaceScreenState();
}

class StudentFaceScreenState extends State<StudentFaceScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      final frontCamera = cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => throw StateError('No front camera found'),
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        final XFile image = await _controller!.takePicture();
        final bytes = await image.readAsBytes();

        img.Image originalImage = img.decodeImage(bytes)!;

        int targetWidth = originalImage.width;
        int targetHeight = (originalImage.width * 16 / 9).round();
        if (targetHeight > originalImage.height) {
          targetHeight = originalImage.height;
          targetWidth = (originalImage.height * 9 / 16).round();
        }

        int offsetX = (originalImage.width - targetWidth) ~/ 2;
        int offsetY = (originalImage.height - targetHeight) ~/ 2;

        img.Image croppedImage = img.copyCrop(
          originalImage,
          x: offsetX,
          y: offsetY,
          width: targetWidth,
          height: targetHeight,
        );

        final croppedBytes = img.encodeJpg(croppedImage);

        if (mounted) {
          _showConfirmationDialog(croppedBytes);
        }
      } catch (e) {
        print('Error capturing photo: $e');
      }
    }
  }

  void _showConfirmationDialog(Uint8List croppedBytes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Esta foto es correcta?'),
          content: RotatedBox(
            quarterTurns: 0,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
              child: Image.memory(croppedBytes),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = true;
                });
                await _processPhoto(croppedBytes);
                setState(() {
                  _isLoading = false;
                });
              },
              child: const Text('Sí'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restartCamera();
              },
              child: const Text('Tomar de nuevo'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processPhoto(Uint8List croppedBytes) async {
    final apiService = ApiService();
    final base64String = base64Encode(croppedBytes);
    final response = await apiService.checkFace(base64String);

    if (!mounted) return;

    if (response.statusCode == 200 && response.success) {
      if (response.data != null && response.data!['face_exists'] == true) {
        final signupResponse = await apiService.studentSignup(
          widget.name,
          widget.username,
          widget.birthDate,
          widget.faculty,
          widget.matnum,
          widget.password,
          base64String,
          widget.email,
        );

        if (signupResponse.success) {
          final int? studentId = signupResponse.studentId;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario registrado exitosamente')),
          );
          SessionManager().studentId = studentId;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentHomeScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registro fallido: ${signupResponse.error}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se detectó un rostro. Por favor, toma otra foto.')),
        );
        _restartCamera();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verificación facial fallida. Por favor, toma otra foto.')),
      );
      _restartCamera();
    }
  }

  Future<void> _restartCamera() async {
    if (_controller != null) {
      await _controller!.dispose();
    }
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Registro Facial'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade100, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Header with instructions
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.green.shade100,
                        child: Icon(
                          Icons.face,
                          size: 28,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Registro facial',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Coloca tu rostro frente a la cámara y toma una foto para registrarte',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Camera preview
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _isCameraInitialized
                      ? Builder(
                          builder: (context) {
                            final previewSize = _controller!.value.previewSize!;
                            return RotatedBox(
                              quarterTurns: 1,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: SizedBox(
                                  width: previewSize.width,
                                  height: previewSize.height,
                                  child: Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                                    child: CameraPreview(_controller!),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                'Iniciando cámara...',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Capture button
              SizedBox(
                width: 180,
                height: 56,
                child: _isLoading
                  ? Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.green.shade600,
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _isCameraInitialized ? _capturePhoto : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text(
                        'Tomar foto',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}