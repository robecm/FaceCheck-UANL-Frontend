import 'package:flutter/material.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  StudentHomeScreenState createState() => StudentHomeScreenState();
}

class StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
        centerTitle: true,
        automaticallyImplyLeading: true, // Show the drawer button
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Mi perfil'),
              onTap: () {
                // Handle menu item selection
                print('Selected: Mi perfil');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Configuración'),
              onTap: () {
                // Handle menu item selection
                print('Selected: Configuración');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Cerrar sesión'),
              onTap: () {
                // Handle menu item selection
                print('Selected: Cerrar sesión');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 360, // Adjust the height as needed
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button press
                      print('Clases button pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(8.0), // Reduce the padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Adjust the border radius
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end, // Align at the bottom
                      children: [
                        Flexible(
                          child: Image.asset(
                            'assets/images/buttons/class.png', // Local image asset
                            height: 280, // Limit the image size
                            width: 280,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'CLASES',
                          overflow: TextOverflow.ellipsis, // Handle long text
                          style: TextStyle(
                            fontWeight: FontWeight.bold, // Make the text bold
                            fontSize: 24, // Increase the font size
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20), // Add some space between the buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 360, // Adjust the height as needed
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button press
                      print('Profesores button pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(8.0), // Reduce the padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Adjust the border radius
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end, // Align at the bottom
                      children: [
                        Flexible(
                          child: Image.asset(
                            'assets/images/buttons/teacher.png', // Local image asset
                            height: 280, // Limit the image size
                            width: 280,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'PROFESORES',
                          overflow: TextOverflow.ellipsis, // Handle long text
                          style: TextStyle(
                            fontWeight: FontWeight.bold, // Make the text bold
                            fontSize: 24, // Increase the font size
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20), // Add some space between the buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 360, // Adjust the height as needed
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button press
                      print('Exámenes button pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(8.0), // Reduce the padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Adjust the border radius
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end, // Align at the bottom
                      children: [
                        Flexible(
                          child: Image.asset(
                            'assets/images/buttons/exam.png', // Local image asset
                            height: 280, // Limit the image size
                            width: 280,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'EXÁMENES',
                          overflow: TextOverflow.ellipsis, // Handle long text
                          style: TextStyle(
                            fontWeight: FontWeight.bold, // Make the text bold
                            fontSize: 24, // Increase the font size
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20), // Add some padding at the bottom
            ],
          ),
        ),
      ),
    );
  }
}