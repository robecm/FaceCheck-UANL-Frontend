import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class StudentFaceScreen extends StatefulWidget {
  final String name;
  final String username;
  final DateTime birthDate;
  final String faculty;
  final String matnum;
  final String email;

  const StudentFaceScreen({
    super.key,
    required this.name,
    required this.username,
    required this.birthDate,
    required this.faculty,
    required this.matnum,
    required this.email,
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
    );

    await _controller!.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  // TODO CHECK IF THERE'S A FACE
  // TODO IF TRUE, THEN UPLOAD THE USER INFO INTO THE DATABASE

  Future<void> _capturePhoto() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        final XFile image = await _controller!.takePicture();
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Is this photo okay?'),
              content: Image.memory(bytes),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Handle the confirmation of the photo
                    print('Name: ${widget.name}');
                    print('Username: ${widget.username}');
                    print('Birth Date: ${widget.birthDate}');
                    print('Faculty: ${widget.faculty}');
                    print('Matriculation Number: ${widget.matnum}');
                    print('Email: ${widget.email}');
                    print('Base64 Image: $base64String');
                  },
                  child: Text('Yes'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Handle the retake of the photo
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