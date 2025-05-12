import 'package:flutter/material.dart';
import '../../../services/teacher_api_service.dart';
import '../../../models/teacher/retrieve_teacher_assignments_response.dart';
import 'modify_assignment_screen.dart';
import 'create_assignment_screen.dart';
import 'assignment_submissions_screen.dart';
import 'package:intl/intl.dart';

class TeacherAssignmentsScreen extends StatefulWidget {
  final int teacherId;

  const TeacherAssignmentsScreen({super.key, required this.teacherId});

  @override
  _TeacherAssignmentsScreenState createState() => _TeacherAssignmentsScreenState();
}

class _TeacherAssignmentsScreenState extends State<TeacherAssignmentsScreen> {
  late int teacherId;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  List<TeacherAssignmentData> assignments = [];
  final TeacherApiService _apiService = TeacherApiService();

  @override
  void initState() {
    super.initState();
    teacherId = widget.teacherId;
    _fetchAssignments();
  }

  Future<void> _fetchAssignments() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await _apiService.retrieveTeacherAssignments(teacherId);

      if (response.success && response.data != null) {
        final List<TeacherAssignmentData> fetchedAssignments = response.data!.map((assignment) {
          // Use the utility method from AssignmentData
          return assignment.toTeacherAssignmentData();
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

  String _formatDueDate(String dateStr) {
    try {
      final DateTime parsedDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss").parse(dateStr, true);
      return DateFormat("dd/MM/yyyy, HH:mm").format(parsedDate.toLocal());
    } catch (e) {
      // In case of parsing error, return original string
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Tareas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchAssignments,
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateAssignmentDialog();
        },
        label: Text('Nueva Tarea'),
        icon: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
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
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error al cargar las tareas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(errorMessage),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchAssignments,
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No has creado tareas aún',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Pulsa el botón + para crear una nueva tarea'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: assignments.length,
      padding: EdgeInsets.only(bottom: 80), // Add padding for FAB
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        final bool isPastDue = assignment.isDueDatePassed();

        // Set card color based on submission and grading status
        Color cardColor;
        if (isPastDue && assignment.submissionCount == 0) {
          cardColor = Colors.red.shade50; // Past due with no submissions
        } else if (assignment.submissionCount > 0 && assignment.gradedCount < assignment.submissionCount) {
          cardColor = Colors.orange.shade50; // Has ungraded submissions
        } else if (assignment.submissionCount > 0 && assignment.gradedCount == assignment.submissionCount) {
          cardColor = Colors.green.shade50; // All submissions graded
        } else {
          cardColor = Colors.blue.shade50; // Active assignment
        }

        return Card(
          margin: EdgeInsets.all(10),
          color: cardColor,
          child: InkWell(
            onTap: () {
              _showAssignmentOptions(assignment);
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
                    'Fecha de entrega: ${_formatDueDate(assignment.dueDate)}',
                    style: TextStyle(
                      color: isPastDue ? Colors.red : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(TeacherAssignmentData assignment) {
    double submissionRate = assignment.totalStudents > 0
        ? assignment.submissionCount / assignment.totalStudents
        : 0;

    double gradingRate = assignment.submissionCount > 0
        ? assignment.gradedCount / assignment.submissionCount
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Entregados:', style: TextStyle(fontSize: 12)),
                  SizedBox(height: 2),
                  LinearProgressIndicator(
                    value: submissionRate,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calificados:', style: TextStyle(fontSize: 12)),
                  SizedBox(height: 2),
                  LinearProgressIndicator(
                    value: gradingRate,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(TeacherAssignmentData assignment, bool isPastDue) {
    String label;
    Color color;

    if (isPastDue) {
      if (assignment.submissionCount == 0) {
        label = 'Sin entregas';
        color = Colors.red;
      } else if (assignment.gradedCount < assignment.submissionCount) {
        label = 'Sin calificar';
        color = Colors.orange;
      } else {
        label = 'Completado';
        color = Colors.green;
      }
    } else {
      label = 'Activo';
      color = Colors.blue;
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

  void _showAssignmentOptions(TeacherAssignmentData assignment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                assignment.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Text(
                assignment.className,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              Divider(height: 30),
              _buildOptionTile(
                icon: Icons.assignment_turned_in,
                title: 'Ver entregas',
                onTap: () {
                  Navigator.pop(context);
                  _navigateToSubmissions(assignment);
                },
              ),
              _buildOptionTile(
                icon: Icons.edit,
                title: 'Editar tarea',
                onTap: () {
                  Navigator.pop(context);
                  _editAssignment(assignment);
                },
              ),
              _buildOptionTile(
                icon: Icons.delete_outline,
                title: 'Eliminar tarea',
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteAssignment(assignment);
                },
                isDestructive: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool enabled = true,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : Colors.blue;

    return ListTile(
      leading: Icon(icon, color: enabled ? color : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? (isDestructive ? Colors.red : Colors.black) : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,  // Show subtitle only if provided
      enabled: enabled,
      onTap: enabled ? onTap : null,
    );
  }

  void _navigateToSubmissions(TeacherAssignmentData assignment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignmentSubmissionsScreen(
          assignmentId: assignment.id,
          assignmentTitle: assignment.title,
        ),
      ),
    ).then((_) {
      // Refresh to update grading statistics
      _fetchAssignments();
    });
  }

  void _editAssignment(TeacherAssignmentData assignment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModifyAssignmentScreen(assignment: assignment),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh assignments if changes were made
        _fetchAssignments();
      }
    });
  }

  void _confirmDeleteAssignment(TeacherAssignmentData assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar tarea?'),
        content: Text('Esta acción eliminará la tarea "${assignment.title}" y no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tarea eliminada (a implementar)')),
              );
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCreateAssignmentDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateAssignmentScreen(teacherId: teacherId),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh assignments if a new assignment was created
        _fetchAssignments();
      }
    });
  }
}