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
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: const Text('Profesor'),
              accountEmail: Text('ID: $teacherId'),
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
                      userId: teacherId,
                      userType: 'teacher',
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
                '¡Bienvenido, Profesor!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Gestiona tus recursos académicos',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
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
                              'CLASES',
                              'assets/images/buttons/class.png',
                              Colors.blue.shade50,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeacherClassesScreen(teacherId: teacherId),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildGridItem(
                              context,
                              'EXÁMENES',
                              'assets/images/buttons/exam.png',
                              Colors.red.shade50,
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
                    SizedBox(height: 16),
                    // Second row with centered TAREAS button
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: (MediaQuery.of(context).size.width - 48) / 2,
                          child: _buildGridItem(
                            context,
                            'TAREAS',
                            'assets/images/buttons/assignments.png',
                            Colors.amber.shade50,
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