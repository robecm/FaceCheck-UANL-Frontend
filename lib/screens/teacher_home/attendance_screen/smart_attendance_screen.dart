import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../models/teacher/class/retrieve_class_students_response.dart';
import '../../../services/teacher_api_service.dart';
import '../../../services/config.dart';
import 'package:image/image.dart' as img;
import 'dart:math';

class SmartAttendanceScreen extends StatefulWidget {
  final int classId;
  final String className;
  final List<StudentData> students;
  final DateTime selectedDate;

  const SmartAttendanceScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.students,
    required this.selectedDate,
  });

  @override
  State<SmartAttendanceScreen> createState() => _SmartAttendanceScreenState();
}

class _SmartAttendanceScreenState extends State<SmartAttendanceScreen> {
  int _currentStudentIndex = 0;
  late Map<int, bool> attendanceMap = {};
  late CameraController _cameraController;
  List<CameraDescription> cameras = [];
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _isTakingPicture = false;
  int _attempts = 0;
  bool _isAllComplete = false;

  @override
  void initState() {
    super.initState();
    // Initialize attendance map with all students marked absent
    for (var student in widget.students) {
      attendanceMap[student.id] = false;
    }
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();

      // Select the front camera for face recognition (matching login screens)
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => throw StateError('No front camera found'),
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high, // Changed from medium to high
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg, // Changed to match login screens
      );

      await _cameraController.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al inicializar la cámara: $e')),
        );
      }
    }
  }

  void _nextStudent() {
    if (_currentStudentIndex < widget.students.length - 1) {
      setState(() {
        _currentStudentIndex++;
        _attempts = 0;
      });
    } else {
      setState(() {
        _isAllComplete = true;
      });
    }
  }

  void _previousStudent() {
    if (_currentStudentIndex > 0) {
      setState(() {
        _currentStudentIndex--;
        _attempts = 0;
      });
    }
  }

  Future<void> _takePicture() async {
    if (_isProcessing || _isTakingPicture) return;

    setState(() {
      _isTakingPicture = true;
    });

    try {
      final XFile photo = await _cameraController.takePicture();

      // Process the image for face verification
      await _processImage(photo);
    } catch (e) {
      debugPrint('Error taking picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error tomando la foto: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  Future<void> _processImage(XFile photo) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    final student = widget.students[_currentStudentIndex];
    debugPrint('Processing image for student ID: ${student.id}, name: ${student.name}');

    try {
      debugPrint('Reading image bytes from XFile: ${photo.path}');
      final bytes = await photo.readAsBytes();
      debugPrint('Image bytes read: ${bytes.length} bytes');

      // Image processing
      debugPrint('Beginning image transformation...');
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        debugPrint('ERROR: Failed to decode image');
        throw Exception('No se pudo decodificar la imagen');
      }
      debugPrint('Original image size: ${originalImage.width}x${originalImage.height}');

      img.Image transformedImage = img.copyRotate(originalImage, angle: 0);
      debugPrint('Image rotated');

      transformedImage = img.flipHorizontal(transformedImage);
      debugPrint('Image flipped horizontally');
      debugPrint('Transformed image size: ${transformedImage.width}x${transformedImage.height}');

      final transformedBytes = img.encodeJpg(transformedImage);
      debugPrint('Image encoded to JPG: ${transformedBytes.length} bytes');

      final base64Image = base64Encode(transformedBytes);
      debugPrint('Image encoded to base64: ${base64Image.length} characters');
      debugPrint('Captured base64 (first 100 chars): ${base64Image.substring(0, min(100, base64Image.length))}');

      // Prepare and log request body
      final requestBody = json.encode({
        'student_id': student.id,
        'cap_frame': base64Image,
      });
      debugPrint('Request body structure: ${json.encode({'student_id': student.id, 'face_image': '[BASE64_STRING]'})}');
      debugPrint('Request body length: ${requestBody.length} characters');

      // Make a direct API call for student verification
      final url = Uri.parse('${AppConfig.baseUrl}/api/face/verify');
      debugPrint('Sending request to: $url');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final jsonResponse = json.decode(response.body);
      debugPrint('Parsed response: $jsonResponse');

      // In the _processImage method, replace the if condition:
      if (jsonResponse['success'] == true && jsonResponse['data']['match'] == true) {
        debugPrint('FACE MATCH SUCCESSFUL');
        // Face match successful
        setState(() {
          attendanceMap[student.id] = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verificación exitosa'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        // Move to next student
        Future.delayed(const Duration(seconds: 1), () {
          _nextStudent();
        });
      } else {
        debugPrint('FACE MATCH FAILED: ${jsonResponse['error'] ?? 'No error message provided'}');
        // Face match failed
        setState(() {
          _attempts++;
        });

        if (_attempts >= 2) {
          debugPrint('Maximum attempts reached, showing attendance prompt');
          _showAttendancePrompt(student);
        } else {
          debugPrint('Attempt ${_attempts}/2 failed');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Verificación fallida. Intente de nuevo.'),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('ERROR processing the image: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error procesando la imagen: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        debugPrint('Image processing completed');
      }
    }
  }

  void _showAttendancePrompt(StudentData student) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text('Marcar a ${student.name} como presente'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    attendanceMap[student.id] = true;
                  });
                  _nextStudent();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: Text('Marcar a ${student.name} como ausente'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    attendanceMap[student.id] = false;
                  });
                  _nextStudent();
                },
              ),
              ListTile(
                leading: const Icon(Icons.replay, color: Colors.blue),
                title: const Text('Intentar de nuevo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _attempts = 0;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitAttendance() async {
    final formattedDate = "${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}";

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Registrando asistencia..."),
              ],
            ),
          ),
        );
      },
    );

    try {
      final apiService = TeacherApiService();

      // Group students by attendance status
      List<int> presentStudentIds = [];
      List<int> absentStudentIds = [];

      attendanceMap.forEach((studentId, isPresent) {
        if (isPresent) {
          presentStudentIds.add(studentId);
        } else {
          absentStudentIds.add(studentId);
        }
      });

      bool success = true;
      String errorMessage = '';

      // Register present students
      if (presentStudentIds.isNotEmpty) {
        final presentResponse = await apiService.modifyAttendance(
          widget.classId,
          presentStudentIds,
          true,
          attendanceDate: formattedDate,
        );

        if (!presentResponse.success) {
          success = false;
          errorMessage = presentResponse.error ?? 'Error al registrar estudiantes presentes';
        }
      }

      // Register absent students
      if (absentStudentIds.isNotEmpty) {
        final absentResponse = await apiService.modifyAttendance(
          widget.classId,
          absentStudentIds,
          false,
          attendanceDate: formattedDate,
        );

        if (!absentResponse.success) {
          success = false;
          errorMessage = errorMessage.isEmpty
              ? (absentResponse.error ?? 'Error al registrar estudiantes ausentes')
              : '$errorMessage y también hubo error con ausentes';
        }
      }

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Asistencia registrada correctamente'),
              backgroundColor: Colors.green,
            ),
          );

          // Return to previous screen with attendance data
          Navigator.pop(context, attendanceMap);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAllComplete) {
      return _buildCompletionScreen();
    }

    if (!_isCameraInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Asistencia Inteligente - ${widget.className}'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentStudent = widget.students[_currentStudentIndex];
    final progress = "${_currentStudentIndex + 1}/${widget.students.length}";

    return Scaffold(
      appBar: AppBar(
        title: Text('Asistencia Inteligente - ${widget.className}'),
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                progress,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Student navigation and info
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left arrow
                _currentStudentIndex > 0
                    ? IconButton(
                        onPressed: _previousStudent,
                        icon: const Icon(Icons.arrow_back_ios),
                        iconSize: 30,
                      )
                    : const SizedBox(width: 48), // Placeholder to maintain layout

                // Student name
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        currentStudent.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentStudent.matnum,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Right arrow
                _currentStudentIndex < widget.students.length - 1
                    ? IconButton(
                        onPressed: _nextStudent,
                        icon: const Icon(Icons.arrow_forward_ios),
                        iconSize: 30,
                      )
                    : const SizedBox(width: 48), // Placeholder to maintain layout
              ],
            ),
          ),

          // Camera preview
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20), // Keep the rounded corners
                child: Builder(
                  builder: (context) {
                    final previewSize = _cameraController.value.previewSize!;
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
                            child: CameraPreview(_cameraController),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _attempts > 0
                ? Text(
                    'Intento ${_attempts}/2',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  )
                : const SizedBox(), // Empty widget when _attempts is 0
          ),

          // Camera controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Capture button
                GestureDetector(
                  onTap: _isProcessing || _isTakingPicture ? null : _takePicture,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      color: _isProcessing || _isTakingPicture
                          ? Colors.grey
                          : Colors.blue,
                    ),
                    child: _isProcessing || _isTakingPicture
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Manual verification buttons
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      attendanceMap[currentStudent.id] = true;
                    });
                    _nextStudent();
                  },
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('Presente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 44),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      attendanceMap[currentStudent.id] = false;
                    });
                    _nextStudent();
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: const Text('Ausente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 44),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    final presentCount = attendanceMap.values.where((present) => present).length;
    final absentCount = attendanceMap.values.length - presentCount;

    return Scaffold(
      appBar: AppBar(
        title: Text('Asistencia Inteligente - ${widget.className}'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 100,
                color: Colors.green,
              ),
              const SizedBox(height: 20),
              const Text(
                '¡Asistencia completada!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Text(
                'Estudiantes presentes: $presentCount',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Estudiantes ausentes: $absentCount',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _submitAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                ),
                child: const Text(
                  'Guardar Asistencia',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, attendanceMap);
                },
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}