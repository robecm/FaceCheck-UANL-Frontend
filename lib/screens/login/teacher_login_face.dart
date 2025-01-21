import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../services/user_api_service.dart';
import '../../models/verify_face_response.dart';

class TeacherLoginFaceScreen extends StatefulWidget {
  final String faceCode;

  const TeacherLoginFaceScreen({
    super.key,
    required this.faceCode,
  });

  @override
  TeacherLoginFaceScreenState createState() => TeacherLoginFaceScreenState();
}

class TeacherLoginFaceScreenState extends State<TeacherLoginFaceScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  bool _isLoading = false;
  final ApiService apiService = ApiService();

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

  Future<void> _captureAndVerifyFace() async {
    if (_controller != null && _controller!.value.isInitialized) {
      setState(() {
        _isLoading = true;
      });

      try {
        final XFile image = await _controller!.takePicture();
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);

        // Print the first 100 characters of the base64 strings
        print('Registered base64 (first 100 chars): ${widget.faceCode.substring(0, 100)}');
        print('Captured base64 (first 100 chars): ${base64String.substring(0, 100)}');

        VerifyFaceResponse response = await apiService.verifyFace(base64String, widget.faceCode);

        if (response.success) {
          final match = response.match;
          if (match == true) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (match == 'VALUE ERROR') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No se detectó una cara en la foto proporcionada')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('La cara registrada no coincide con la proporcionada')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error en la verificación de la cara')),
          );
        }
      } catch (e) {
        print('Error capturing photo: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al capturar la foto: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                  ? Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: AspectRatio(
                        aspectRatio: 9 / 16,
                        child: CameraPreview(_controller!),
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? CircularProgressIndicator()
                : FloatingActionButton(
                    onPressed: _captureAndVerifyFace,
                    child: const Icon(Icons.camera),
                  ),
          ),
        ],
      ),
    );
  }
}