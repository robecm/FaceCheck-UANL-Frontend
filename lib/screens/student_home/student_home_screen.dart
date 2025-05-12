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
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
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
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.green.shade50, Colors.white],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: const Text('Estudiante'),
                accountEmail: Text('ID: $studentId'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: Colors.green.shade700),
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                ),
              ),
              ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.green.shade100,
                  child: Icon(Icons.person, size: 20, color: Colors.green.shade700),
                ),
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
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.green.shade100,
                  child: Icon(Icons.settings, size: 20, color: Colors.green.shade700),
                ),
                title: const Text('Configuración'),
                onTap: () {
                  print('Selected: Configuración');
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.green.shade100,
                  child: Icon(Icons.logout, size: 20, color: Colors.green.shade700),
                ),
                title: const Text('Cerrar sesión'),
                onTap: () {
                  print('Selected: Cerrar sesión');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade100, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome card
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.green.shade100,
                          child: Icon(
                            Icons.school,
                            size: 32,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¡Bienvenido!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Accede a tus recursos académicos',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                                'Clases',
                                Icons.class_outlined,
                                Colors.blue,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StudentClassesScreen(studentId: studentId),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildGridItem(
                                context,
                                'Profesores',
                                Icons.people_outline,
                                Colors.green,
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
                      const SizedBox(height: 16),
                      // Second row with EXÁMENES and TAREAS
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildGridItem(
                                context,
                                'Exámenes',
                                Icons.quiz_outlined,
                                Colors.deepOrange,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StudentExamsScreen(studentId: studentId),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildGridItem(
                                context,
                                'Tareas',
                                Icons.assignment_outlined,
                                Colors.amber,
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
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(
                  icon,
                  size: 45,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color.withOpacity(0.8),  // Fixed: using withOpacity instead of shade700
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