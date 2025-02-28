import 'package:flutter/material.dart';
import '../../models/user_info/retrieve_user_info_response.dart';
import '../../services/user_info_api_service.dart';
import '../../models/user_info/modify_user_info_request.dart';
import 'package:intl/intl.dart';

class UserInfoScreen extends StatefulWidget {
  final int userId;
  final String userType;

  const UserInfoScreen({
    super.key,
    required this.userId,
    required this.userType,
  });

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final UserInfoApiService _apiService = UserInfoApiService();
  late Future<RetrieveUserInfoResponse> _userInfoFuture;
  bool _isEditing = false;
  final List<String> _faculties = ['FIME', 'FACPYA', 'FOD', 'FACDyC', 'FARQ', 'FIC', 'FCB', 'FFYL'];

  // Controllers for editable fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _facultyController = TextEditingController();
  final TextEditingController _matnumController = TextEditingController();
  final TextEditingController _worknumController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint('UserInfoScreen initState');
    _loadUserInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _birthdateController.dispose();
    _facultyController.dispose();
    _matnumController.dispose();
    _worknumController.dispose();
    super.dispose();
  }

  void _loadUserInfo() {
    debugPrint('Loading user info for userId: ${widget.userId}, userType: ${widget.userType}');
    _userInfoFuture = _apiService.getUserInfo(
      userId: widget.userId,
      userType: widget.userType,
    );
  }

  void _toggleEditMode(UserInfoData? userInfo) {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing && userInfo != null) {
        // Initialize controllers with current values
        _nameController.text = userInfo.name;
        _usernameController.text = userInfo.username;
        _emailController.text = userInfo.email;
        _birthdateController.text = userInfo.birthdate ?? '';
        _facultyController.text = userInfo.faculty ?? '';
        _matnumController.text = userInfo.matnum ?? '';
        _worknumController.text = userInfo.worknum ?? '';
      }
    });
  }

  void _saveChanges() async {
    try {
      // Create request object with current form values
      final request = ModifyUserInfoRequest(
        userId: widget.userId,
        userType: widget.userType,
        name: _nameController.text,
        username: _usernameController.text,
        email: _emailController.text,
        birthdate: _birthdateController.text,
        // Only include user type specific fields
        matnum: widget.userType == 'student' ? _matnumController.text : null,
        worknum: widget.userType == 'teacher' ? _worknumController.text : null,
        faculty: widget.userType == 'student' ? _facultyController.text : null,
      );

      debugPrint('Sending modify user info request: ${request.toJson()}');
      final response = await _apiService.modifyUserInfo(request);

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cambios guardados correctamente')),
        );
        setState(() {
          _isEditing = false;
          _loadUserInfo(); // Refresh data
        });
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.error ?? "No se pudieron guardar los cambios"}')),
        );
      }
    } catch (e) {
      debugPrint('Error saving changes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building UserInfoScreen');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          FutureBuilder<RetrieveUserInfoResponse>(
            future: _userInfoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData && snapshot.data!.data != null) {
                return _isEditing
                    ? IconButton(
                        icon: const Icon(Icons.save, color: Colors.white),
                        onPressed: _saveChanges,
                      )
                    : IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () => _toggleEditMode(snapshot.data!.data),
                      );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: FutureBuilder<RetrieveUserInfoResponse>(
        future: _userInfoFuture,
        builder: (context, snapshot) {
          debugPrint('FutureBuilder state: ${snapshot.connectionState}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            debugPrint('Error loading user info: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      debugPrint('Retrying to load user info');
                      setState(() {
                        _loadUserInfo();
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.data == null) {
            debugPrint('No user info data available');
            return const Center(
              child: Text('No se pudo cargar la información del usuario'),
            );
          }

          final userInfo = snapshot.data!.data!;
          debugPrint('User info loaded: ${userInfo.toJson()}');
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          _isEditing && _nameController.text.isNotEmpty
                              ? _nameController.text[0].toUpperCase()
                              : userInfo.name.isNotEmpty
                                  ? userInfo.name[0].toUpperCase()
                                  : '?',
                          style: const TextStyle(fontSize: 40, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _isEditing
                          ? TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                              ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Text(
                              userInfo.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      Text(
                        userInfo.userType == 'student' ? 'Estudiante' : 'Profesor',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                _buildInfoTile('Usuario', userInfo.username),
                _buildInfoTile('Correo electrónico', userInfo.email),
                _buildInfoTile('Fecha de nacimiento', userInfo.birthdate ?? 'No especificado'),

                if (userInfo.userType == 'student') ...[
                  _buildInfoTile('Facultad', userInfo.faculty ?? 'No especificado'),
                  _buildInfoTile('Número de matrícula', userInfo.matnum ?? 'No especificado'),
                ] else ...[
                  _buildInfoTile('Número de trabajador', userInfo.worknum ?? 'No especificado'),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    debugPrint('Building info tile for $title: $value');

    // Format birthdate for display when not in edit mode
    String displayValue = value;
    if (title == 'Fecha de nacimiento' && value != 'No especificado' && !_isEditing) {
      try {
        // More robust date parsing
        final parsedDate = DateTime.parse(value);
        displayValue = DateFormat('dd/MM/yy').format(parsedDate);
      } catch (e) {
        debugPrint('Error parsing date: $e');
      }
    }

    if (_isEditing) {
      // Special handling for date field
      if (title == 'Fecha de nacimiento') {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _birthdateController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _birthdateController.text.isNotEmpty
                            ? DateTime.tryParse(_birthdateController.text) ?? DateTime.now()
                            : DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _birthdateController.text = DateFormat('dd/MM/yy').format(pickedDate);
                        });
                      }
                    },
                  ),
                ),
                readOnly: true,
              ),
              const Divider(),
            ],
          ),
        );
      }

      // Special handling for faculty field
      else if (title == 'Facultad') {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _faculties.contains(_facultyController.text) ? _facultyController.text : null,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  border: OutlineInputBorder(),
                ),
                items: _faculties.map((String faculty) {
                  return DropdownMenuItem<String>(
                    value: faculty,
                    child: Text(faculty),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _facultyController.text = value;
                    });
                  }
                },
              ),
              const Divider(),
            ],
          ),
        );
      }

      // Handle other fields with regular TextFormField
      TextEditingController controller;
      switch (title) {
        case 'Usuario':
          controller = _usernameController;
          break;
        case 'Correo electrónico':
          controller = _emailController;
          break;
        case 'Número de matrícula':
          controller = _matnumController;
          break;
        case 'Número de trabajador':
          controller = _worknumController;
          break;
        default:
          controller = TextEditingController(text: value);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                border: OutlineInputBorder(),
              ),
            ),
            const Divider(),
          ],
        ),
      );
    } else {
      // Non-editable display with formatted date
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              displayValue,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Divider(),
          ],
        ),
      );
    }
  }
}