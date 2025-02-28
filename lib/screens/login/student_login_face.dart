import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import '../../services/user_api_service.dart';
import '../../models/face/verify_face_response.dart';
import '../../screens/student_home/student_home_screen.dart';
import '../../models/session/session_manager.dart';

class StudentLoginFaceScreen extends StatefulWidget {
  final String faceCode;
  final int studentId;

  const StudentLoginFaceScreen({
    super.key,
    required this.faceCode,
    required this.studentId,
  });

  @override
  StudentLoginFaceScreenState createState() => StudentLoginFaceScreenState();
}

class StudentLoginFaceScreenState extends State<StudentLoginFaceScreen> {
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

        final originalImage = img.decodeImage(bytes);
        if (originalImage == null) {
          throw Exception('No se pudo decodificar la imagen');
        }
        img.Image transformedImage = img.copyRotate(originalImage, angle: 0);
        transformedImage = img.flipHorizontal(transformedImage);

        final transformedBytes = img.encodeJpg(transformedImage);
        final base64String = base64Encode(transformedBytes);

        print('Registered base64 (first 100 chars): ${widget.faceCode.substring(0, 100)}');
        print('Captured base64 (first 100 chars): ${base64String.substring(0, 100)}');

        VerifyFaceResponse response = await apiService.verifyFace(base64String, widget.faceCode);

        if (response.success) {
          final match = response.match;
          if (match == true) {
            // Set the session studentId
            SessionManager().studentId = widget.studentId;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentHomeScreen(),
              ),
            );
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
                  ? Builder(
                      builder: (context) {
                        final previewSize = _controller!.value.previewSize!;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const CircularProgressIndicator()
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