import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AssignmentData {
  final int id;
  final String title;
  final String className;
  final String description;
  final String dueDate;
  final String teacherName;
  final bool hasEvidence;
  final double? score;

  AssignmentData({
    required this.id,
    required this.title,
    required this.className,
    required this.description,
    required this.dueDate,
    required this.teacherName,
    required this.hasEvidence,
    this.score,
  });

  bool isDueDatePassed() {
    final due = DateFormat('yyyy-MM-dd').parse(dueDate);
    return due.isBefore(DateTime.now());
  }
}

class StudentAssignmentsScreen extends StatefulWidget {
  final int studentId;

  const StudentAssignmentsScreen({super.key, required this.studentId});

  @override
  _StudentAssignmentsScreenState createState() => _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState extends State<StudentAssignmentsScreen> {
  late int studentId;
  bool isLoading = true;
  List<AssignmentData> assignments = [];

  @override
  void initState() {
    super.initState();
    studentId = widget.studentId;
    // Simulate API call
    Future.delayed(Duration(seconds: 1), () {
      loadMockData();
      setState(() {
        isLoading = false;
      });
    });
  }

  void loadMockData() {
    assignments = [
      AssignmentData(
        id: 1,
        title: 'Investigación sobre Algoritmos',
        className: 'Programación',
        description: 'Realizar una investigación sobre algoritmos de ordenamiento.',
        dueDate: '2023-12-01', // Past date
        teacherName: 'Prof. García',
        hasEvidence: true,
        score: 85,
      ),
      AssignmentData(
        id: 2,
        title: 'Ejercicios de Ecuaciones',
        className: 'Matemáticas',
        description: 'Resolver los ejercicios 1-10 del capítulo 3.',
        dueDate: '2023-12-15', // Past date
        teacherName: 'Prof. Martínez',
        hasEvidence: true,
        score: null, // Not graded yet
      ),
      AssignmentData(
        id: 3,
        title: 'Ensayo de Literatura',
        className: 'Literatura',
        description: 'Escribir un ensayo sobre Gabriel García Márquez.',
        dueDate: '2024-01-20', // Future date
        teacherName: 'Prof. López',
        hasEvidence: false,
        score: null,
      ),
      AssignmentData(
        id: 4,
        title: 'Proyecto Final',
        className: 'Bases de Datos',
        description: 'Diseñar e implementar una base de datos para un sistema escolar.',
        dueDate: '2024-01-15', // Future date
        teacherName: 'Prof. Rodríguez',
        hasEvidence: false,
        score: null,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Tareas'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : assignments.isEmpty
              ? Center(child: Text('No tienes tareas asignadas actualmente'))
              : ListView.builder(
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = assignments[index];
                    final bool isPastDue = assignment.isDueDatePassed();

                    // Set card color based on status
                    Color cardColor;
                    if (isPastDue && !assignment.hasEvidence) {
                      cardColor = Colors.red.shade50; // Overdue without evidence
                    } else if (isPastDue && assignment.hasEvidence) {
                      cardColor = Colors.orange.shade50; // Submitted late
                    } else if (!isPastDue && assignment.hasEvidence) {
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Profesor: ${assignment.teacherName}'),
                                  if (assignment.score != null)
                                    Text(
                                      'Calificación: ${assignment.score}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildStatusChip(AssignmentData assignment, bool isPastDue) {
    String label;
    Color color;

    if (assignment.hasEvidence) {
      if (assignment.score != null) {
        label = 'Calificado';
        color = Colors.green;
      } else {
        label = 'Entregado';
        color = Colors.blue;
      }
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

  Widget _buildAssignmentDetail(AssignmentData assignment) {
    final bool isPastDue = assignment.isDueDatePassed();

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
          SizedBox(height: 8),
          _buildEvidenceSection(assignment),
          SizedBox(height: 16),
          if (assignment.score != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calificación:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${assignment.score}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 16),
          if (!assignment.hasEvidence || (assignment.hasEvidence && !isPastDue))
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.upload_file),
                label: Text(assignment.hasEvidence ? 'Reemplazar evidencia' : 'Subir evidencia'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  // Future upload implementation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Funcionalidad de carga en desarrollo')),
                  );
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

  Widget _buildEvidenceSection(AssignmentData assignment) {
    if (!assignment.hasEvidence) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 8),
            Text('No se ha subido evidencia para esta tarea.'),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Evidencia subida',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('archivo_tarea_${assignment.id}.pdf', style: TextStyle(color: Colors.blue)),
          SizedBox(height: 4),
          Text('Subido el 2023-11-30', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}