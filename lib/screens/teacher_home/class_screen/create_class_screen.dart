import 'package:flutter/material.dart';
import '../../../models/teacher/class/create_class_request.dart';
import '../../../services/teacher_api_service.dart';

class CreateClassScreen extends StatefulWidget {
  final int teacherId;

  const CreateClassScreen({super.key, required this.teacherId});

  @override
  _CreateClassScreenState createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  late TextEditingController classNameController;
  late TextEditingController classRoomController;
  late TextEditingController groupNumController;
  bool isLoading = false;
  String? selectedSemester;
  String? selectedWeekDays;
  String? selectedStartTime;
  String? selectedEndTime;

  final List<String> timeOptions = [
    'M1', 'M2', 'M3', 'M4', 'M5', 'M6',
    'V1', 'V2', 'V3', 'V4', 'V5', 'V6',
    'N1', 'N2', 'N3', 'N4', 'N5', 'N6',
  ];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    classNameController = TextEditingController();
    classRoomController = TextEditingController();
    groupNumController = TextEditingController();
  }

  @override
  void dispose() {
    classNameController.dispose();
    classRoomController.dispose();
    groupNumController.dispose();
    super.dispose();
  }

  List<String> getFilteredEndTimeOptions() {
    if (selectedStartTime == null) return timeOptions;

    final startTimePrefix = selectedStartTime![0];
    final startTimeIndex = timeOptions.indexOf(selectedStartTime!);

    return timeOptions.where((time) {
      final timePrefix = time[0];
      final timeIndex = timeOptions.indexOf(time);

      if (startTimePrefix == 'M') {
        return timeIndex >= startTimeIndex;
      } else if (startTimePrefix == 'V') {
        return timePrefix != 'M' && timeIndex >= startTimeIndex;
      } else if (startTimePrefix == 'N') {
        return timePrefix == 'N' && timeIndex >= startTimeIndex;
      }
      return true;
    }).toList();
  }

  Future<void> _createClass() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final request = CreateClassRequest(
      className: classNameController.text,
      classRoom: classRoomController.text,
      endTime: selectedEndTime!,
      groupNum: int.parse(groupNumController.text),
      semester: selectedSemester!,
      startTime: selectedStartTime!,
      weekDays: selectedWeekDays!,
      teacherId: widget.teacherId,
    );

    try {
      final apiService = TeacherApiService();
      final response = await apiService.createClass(request);

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Class created successfully')),
        );
        Navigator.pop(context, true); // Pass true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create class: ${response.error}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Clase'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: classNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la Clase',
                ),
              ),
              TextFormField(
                controller: classRoomController,
                decoration: InputDecoration(
                  labelText: 'Salón',
                ),
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El salón no puede estar vacío';
                  }
                  if (value.length > 6) {
                    return 'El salón no puede tener más de 6 caracteres';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: groupNumController,
                decoration: InputDecoration(
                  labelText: 'Número de Grupo',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El número de grupo no puede estar vacío';
                  }
                  if (value.length != 3 || value == '000') {
                    return 'Ingrese un número de grupo válido';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedSemester,
                decoration: InputDecoration(
                  labelText: 'Semestre',
                ),
                items: [
                  'Agosto - Diciembre',
                  'Enero - Junio',
                  'Veranos',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedSemester = newValue;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedStartTime,
                decoration: InputDecoration(
                  labelText: 'Hora de Inicio',
                ),
                items: timeOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedStartTime = newValue;
                    selectedEndTime = null; // Reset end time when start time changes
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedEndTime,
                decoration: InputDecoration(
                  labelText: 'Hora de Fin',
                ),
                items: getFilteredEndTimeOptions().map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedEndTime = newValue;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedWeekDays,
                decoration: InputDecoration(
                  labelText: 'Días de la Semana',
                ),
                items: [
                  'Lunes',
                  'Martes',
                  'Miércoles',
                  'Jueves',
                  'Viernes',
                  'Sábado',
                  'LMV',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedWeekDays = newValue;
                  });
                },
              ),
              SizedBox(height: 20),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _createClass,
                      child: Text('Guardar Cambios'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}