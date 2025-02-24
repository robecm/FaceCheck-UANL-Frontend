import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../services/user_api_service.dart';
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
          title: const Text('Is this photo okay?'),
          content: RotatedBox(
            // Changed quarterTurns to 1 to match the main preview orientation.
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
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restartCamera();
              },
              child: const Text('Retake'),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User registered successfully')),
          );
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: ${signupResponse.error}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No face detected. Please retake the photo.')),
        );
        _restartCamera();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Face verification failed. Please retake the photo.')),
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
      appBar: AppBar(title: const Text('Camera Preview')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _isCameraInitialized
                  ? Builder(
                builder: (context) {
                  final previewSize = _controller!.value.previewSize!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: RotatedBox(
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
                    ),
                  );
                },
              )
                  : const CircularProgressIndicator(),
            ),
          ),
          if (_isLoading)
            const CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              onPressed: _capturePhoto,
              child: const Icon(Icons.camera),
            ),
          ),
        ],
      ),
    );
  }
}
