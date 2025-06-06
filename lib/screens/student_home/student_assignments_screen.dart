import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import '../../services/student_api_service.dart';
import '../../models/student/retrieve_student_assignments_response.dart';
import 'package:file_picker/file_picker.dart';

class StudentAssignmentsScreen extends StatefulWidget {
  final int studentId;

  const StudentAssignmentsScreen({super.key, required this.studentId});

  @override
  _StudentAssignmentsScreenState createState() => _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState extends State<StudentAssignmentsScreen> {
  late int studentId;
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  List<StudentAssignmentData> assignments = [];
  final StudentApiService _apiService = StudentApiService();
  String? evidenceFileName;
  String? evidenceFileExtension;
  String? evidenceBase64;

  @override
  void initState() {
    super.initState();
    studentId = widget.studentId;
    _fetchAssignments();
  }

  Future<void> _fetchAssignments() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await _apiService.retrieveStudentAssignments(studentId);

      if (response.success && response.data != null) {
        final List<StudentAssignmentData> fetchedAssignments = response.data!.map((assignment) {
          return assignment.toStudentAssignmentData();
        }).toList();

        setState(() {
          assignments = fetchedAssignments;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          errorMessage = response.error ?? 'Failed to load assignments';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Tareas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchAssignments,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchAssignments,
              child: Text('Intentar nuevamente'),
            ),
          ],
        ),
      );
    }

    if (assignments.isEmpty) {
      return Center(child: Text('No tienes tareas asignadas actualmente'));
    }

    return ListView.builder(
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        final bool isPastDue = assignment.isDueDatePassed();

        // Set card color based on status
        Color cardColor;
        if (isPastDue && !assignment.submitted) {
          cardColor = Colors.red.shade50; // Overdue without submission
        } else if (isPastDue && assignment.submitted) {
          cardColor = Colors.orange.shade50; // Submitted
        } else if (!isPastDue && assignment.submitted) {
          cardColor = Colors.green.shade50; // Submitted on time
        } else {
          cardColor = Colors.blue.shade50; // Pending
        }

        return Card(
          margin: EdgeInsets.all(10),
          color: cardColor,
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => _buildAssignmentDetail(assignment),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          assignment.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      _buildStatusChip(assignment, isPastDue),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Clase: ${assignment.className}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Fecha de entrega: ${assignment.dueDate}',
                    style: TextStyle(
                      color: isPastDue ? Colors.red : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('Profesor: ${assignment.teacherName}'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(StudentAssignmentData assignment, bool isPastDue) {
    String label;
    Color color;

    if (assignment.submitted) {
      label = 'Entregado';
      color = Colors.blue;
    } else {
      if (isPastDue) {
        label = 'Vencido';
        color = Colors.red;
      } else {
        label = 'Pendiente';
        color = Colors.orange;
      }
    }

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildAssignmentDetail(StudentAssignmentData assignment) {
    final bool isPastDue = assignment.isDueDatePassed();

    // Only initialize if not already set, don't reset on every rebuild
    if (evidenceFileName == null) {
      evidenceFileName = assignment.submitted ? "Evidencia actual.pdf" : null;
      evidenceFileExtension = assignment.submitted ? "pdf" : null;
    }

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  assignment.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Divider(),
          SizedBox(height: 8),
          Text(
            'Descripción:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(assignment.description),
          SizedBox(height: 16),
          Text(
            'Detalles:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          _buildDetailRow('Clase:', assignment.className),
          _buildDetailRow('Profesor:', assignment.teacherName),
          _buildDetailRow(
            'Fecha de entrega:',
            assignment.dueDate,
            isPastDue ? Colors.red : null,
          ),
          SizedBox(height: 16),

          // File selection section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Evidencia de Entrega',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              if (evidenceFileName != null)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.description, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          evidenceFileName!,
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            evidenceFileName = null;
                            evidenceFileExtension = null;
                            evidenceBase64 = null;
                          });
                          // Re-open the modal to update UI
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => _buildAssignmentDetail(assignment),
                          );
                        },
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.file_upload_outlined, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('No se ha seleccionado ningún archivo'),
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: 16),
          if (!isPastDue || assignment.submitted)
            SizedBox(
              width: double.infinity,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: Icon(evidenceFileName == null ? Icons.upload_file : Icons.check),
                      label: Text(evidenceFileName == null
                          ? 'Seleccionar archivo'
                          : (assignment.submitted ? 'Actualizar entrega' : 'Entregar tarea')),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        if (evidenceFileName == null) {
                          try {
                            // File selection code
                            FilePickerResult? result = await FilePicker.platform.pickFiles();

                            if (result != null) {
                              File file = File(result.files.single.path!);
                              String fileName = result.files.single.name;

                              // Extract file extension
                              String fileExtension = '';
                              if (fileName.contains('.')) {
                                fileExtension = fileName.split('.').last.toLowerCase();
                              }
                              // No need for complex file type detection that could cause errors

                              // Check file size - limit to 20 MB
                              int fileSizeInBytes = await file.length();
                              double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

                              if (fileSizeInMB > 20) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('El archivo es demasiado grande. El tamaño máximo es 20 MB.')),
                                );
                                return;
                              }

                              print("Converting file to base64: $fileName (${fileSizeInMB.toStringAsFixed(2)} MB) - Extension: $fileExtension");

                              try {
                                List<int> fileBytes = await file.readAsBytes();
                                String base64Data = base64Encode(fileBytes);
                                print("File conversion complete: ${DateTime.now()}");

                                // Store the data with extension
                                setState(() {
                                  evidenceFileName = fileName;
                                  evidenceFileExtension = fileExtension;
                                  evidenceBase64 = base64Data;
                                });
                                print("UI variables updated - filename: $evidenceFileName, extension: $evidenceFileExtension");

                                // Force rebuild of bottom sheet to show selected file
                                Navigator.pop(context);
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => _buildAssignmentDetail(assignment),
                                );
                              } catch (e) {
                                print("Base64 conversion error: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al convertir el archivo a base64')),
                                );
                              }
                            }
                          } catch (e) {
                            print("File picker error: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error al seleccionar archivo')),
                            );
                          }
                        } else {
                          // Upload evidence
                          try {
                            setState(() {
                              isLoading = true;
                            });
                            print("Starting upload of file: $evidenceFileName (extension: $evidenceFileExtension)");

                            final response = await _apiService.uploadAssignmentEvidence(
                              assignmentId: assignment.id,
                              studentId: widget.studentId,
                              classId: assignment.classId,
                              fileName: evidenceFileName!,
                              base64FileData: evidenceBase64!,
                            );

                            setState(() {
                              isLoading = false;
                            });

                            if (response.success) {
                              print("Upload successful, updating local state");

                              // Update assignment status locally
                              setState(() {
                                final int index = assignments.indexWhere((a) => a.id == assignment.id);
                                if (index != -1) {
                                  assignments[index] = assignments[index].copyWith(submitted: true);
                                }
                              });

                              // Close the modal and show success message
                              Navigator.pop(context);

                              // Refresh assignments from server to ensure UI is up-to-date
                              _fetchAssignments();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Evidencia registrada correctamente')),
                              );
                            } else {
                              print("Upload failed: ${response.error}");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${response.error ?? "No se pudo subir la evidencia"}')),
                              );
                            }
                          } catch (e) {
                            print("Upload exception: $e");
                            setState(() {
                              isLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error al subir la evidencia: $e')),
                            );
                          }
                        }
                      },
                    ),
              ),
          ],
        ),
      );
    }

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}