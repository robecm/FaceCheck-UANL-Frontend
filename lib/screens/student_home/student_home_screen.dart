import 'package:flutter/material.dart';
import '../../models/session/session_manager.dart';
import 'student_classes_screen.dart';
import 'student_teachers_screen.dart';
import 'student_exams_screen.dart';
import '../user_info/user_info_screen.dart';
import 'student_assignments_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  StudentHomeScreenState createState() => StudentHomeScreenState();
}

class StudentHomeScreenState extends State<StudentHomeScreen> {
  late int studentId;

  @override
  void initState() {
    super.initState();
    studentId = SessionManager().studentId ?? 0;
    print('Student ID: $studentId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal Estudiantil'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Mi Perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserInfoScreen(
                    userId: studentId,
                    userType: 'student',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: const Text('Estudiante'),
              accountEmail: Text('ID: $studentId'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Colors.blue),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mi perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserInfoScreen(
                      userId: studentId,
                      userType: 'student',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                print('Selected: Configuración');
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                print('Selected: Cerrar sesión');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¡Bienvenido!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Accede a tus recursos académicos',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Column(
                  children: [
                    // First row with CLASES and PROFESORES
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildGridItem(
                              context,
                              'CLASES',
                              'assets/images/buttons/class.png',
                              Colors.blue.shade50,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentClassesScreen(studentId: studentId),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildGridItem(
                              context,
                              'PROFESORES',
                              'assets/images/buttons/teacher.png',
                              Colors.green.shade50,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentTeachersScreen(studentId: studentId),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    // Second row with EXÁMENES and TAREAS
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildGridItem(
                              context,
                              'EXÁMENES',
                              'assets/images/buttons/exam.png',
                              Colors.red.shade50,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentExamsScreen(studentId: studentId),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildGridItem(
                              context,
                              'TAREAS',
                              'assets/images/buttons/assignments.png',
                              Colors.amber.shade50,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentAssignmentsScreen(studentId: studentId),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    String title,
    String imagePath,
    Color backgroundColor,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}