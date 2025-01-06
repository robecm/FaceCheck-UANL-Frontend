import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/api_service.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    final frontCamera = cameras!.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _capturePhoto() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        final XFile image = await _controller!.takePicture();
        final bytes = await image.readAsBytes();

        // Decode the image to get its dimensions
        img.Image originalImage = img.decodeImage(bytes)!;

        // Calculate the crop area to maintain a 9:16 aspect ratio
        int targetWidth = originalImage.width;
        int targetHeight = (originalImage.width * 16 / 9).round();
        if (targetHeight > originalImage.height) {
          targetHeight = originalImage.height;
          targetWidth = (originalImage.height * 9 / 16).round();
        }

        int offsetX = (originalImage.width - targetWidth) ~/ 2;
        int offsetY = (originalImage.height - targetHeight) ~/ 2;

        // Crop the image to the 9:16 aspect ratio
        img.Image croppedImage = img.copyCrop(
          originalImage,
          x: offsetX,
          y: offsetY,
          width: targetWidth,
          height: targetHeight,
        );

        final croppedBytes = img.encodeJpg(croppedImage);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Is this photo okay?'),
              content: Image.memory(Uint8List.fromList(croppedBytes)), // Show the cropped image
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();

                    // TODO - Delete the compression block, backend will handle it

                    // Compress the image
                    img.Image resizedImage = img.copyResize(croppedImage, width: 600); // Resize to a smaller width

                    int quality = 40;
                    List<int> compressedBytes = img.encodeJpg(resizedImage, quality: quality);

                    // Adjust quality and size to ensure the image size is below 8191 bytes
                    while (compressedBytes.length > 8191 && quality > 5) {
                      quality -= 3;
                      compressedBytes = img.encodeJpg(resizedImage, quality: quality);
                    }

                    final base64String = base64Encode(compressedBytes);

                    // Make the API request
                    final apiService = ApiService();
                    final response = await apiService.checkFace(base64String);

                    if (response.statusCode == 200 && response.success) {
                      if (response.data != null && response.data!['face_exists'] == true) {
                        // Face detected, make the signup request
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
                            SnackBar(content: Text('User registered successfully')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Registration failed: ${signupResponse.error}')),
                          );
                        }
                      } else {
                        // No face detected
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No face detected. Please retake the photo.')),
                        );
                        _restartCamera();
                      }
                    } else {
                      // Ask the user to retake the photo
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Face verification failed. Please retake the photo.')),
                      );
                      _restartCamera();
                    }
                  },
                  child: Text('Yes'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Handle the retake of the photo
                    _restartCamera();
                  },
                  child: Text('Retake'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        print('Error capturing photo: $e');
      }
    }
  }

  Future<void> _restartCamera() async {
    if (_controller != null) {
      await _controller!.dispose();
    }
    await _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera Preview')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _isCameraInitialized
                  ? Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.0),
                      child: AspectRatio(
                        aspectRatio: 9 / 16,
                        child: CameraPreview(_controller!),
                      ),
                    )
                  : CircularProgressIndicator(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              onPressed: _capturePhoto,
              child: Icon(Icons.camera),
            ),
          ),
        ],
      ),
    );
  }
}