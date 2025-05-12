import 'package:flutter/material.dart';
import 'class_screen/teacher_classes_screen.dart';
import 'exam_screen/teacher_exams_screen.dart';
import '../user_info/user_info_screen.dart';
import 'assignment_screen/teacher_assignments_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  final int teacherId;

  const TeacherHomeScreen({super.key, this.teacherId = 124}); // Default value for debugging

  @override
  TeacherHomeScreenState createState() => TeacherHomeScreenState();
}

class TeacherHomeScreenState extends State<TeacherHomeScreen> {
  late int teacherId;

  @override
  void initState() {
    super.initState();
    teacherId = widget.teacherId;
    print('Teacher ID: $teacherId'); // For debugging
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal Docente'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
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
                    userId: teacherId,
                    userType: 'teacher',
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
              colors: [Colors.blue.shade50, Colors.white],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: const Text('Profesor'),
                accountEmail: Text('ID: $teacherId'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: Colors.blue.shade700),
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.person, size: 20, color: Colors.blue.shade700),
                ),
                title: const Text('Mi perfil'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserInfoScreen(
                        userId: teacherId,
                        userType: 'teacher',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.settings, size: 20, color: Colors.blue.shade700),
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
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.logout, size: 20, color: Colors.blue.shade700),
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
            colors: [Colors.blue.shade100, Colors.white],
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
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(
                            Icons.school,
                            size: 32,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¡Bienvenido, Profesor!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Gestiona tus recursos académicos',
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
                      // First row with CLASES and EXÁMENES
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
                                    builder: (context) => TeacherClassesScreen(teacherId: teacherId),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildGridItem(
                                context,
                                'Exámenes',
                                Icons.quiz_outlined,
                                Colors.red,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TeacherExamsScreen(teacherId: teacherId),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Second row with centered TAREAS button
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            width: (MediaQuery.of(context).size.width - 48) / 2,
                            child: _buildGridItem(
                              context,
                              'Tareas',
                              Icons.assignment_outlined,
                              Colors.amber,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeacherAssignmentsScreen(teacherId: teacherId),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
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
                  color: color.withOpacity(0.8),
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