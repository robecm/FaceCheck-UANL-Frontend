import 'dart:convert';
import 'package:http/http.dart' as http;

class CreateClassRequest {
  final String className;
  final int teacherId;
  final int groupNum;
  final String semester;
  final String classRoom;
  final String startTime;
  final String endTime;
  final String weekDays;

  CreateClassRequest({
    required this.className,
    required this.teacherId,
    required this.groupNum,
    required this.semester,
    required this.classRoom,
    required this.startTime,
    required this.endTime,
    required this.weekDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'class_name': className,
      'teacher_id': teacherId,
      'group_num': groupNum,
      'semester': _mapSemester(semester),
      'class_room': classRoom,
      'start_time': startTime,
      'end_time': endTime,
      'week_days': _mapWeekDays(weekDays),
    };
  }

  String _mapWeekDays(String day) {
    switch (day) {
      case 'Lunes':
        return 'LUN';
      case 'Martes':
        return 'MAR';
      case 'Miércoles':
        return 'MIE';
      case 'Jueves':
        return 'JUE';
      case 'Viernes':
        return 'VIE';
      case 'Sábado':
        return 'SAB';
      default:
        return day;
    }
  }

  String _mapSemester(String semester) {
    switch (semester) {
      case 'Agosto - Diciembre':
        return 'agosto';
      case 'Enero - Junio':
        return 'enero';
      case 'Veranos':
        return 'verano';
      default:
        return semester;
    }
  }
}

Future<void> createClass(CreateClassRequest request) async {
  final url = Uri.parse('https://yourapi.com/api/class/register');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(request.toJson()),
  );

  if (response.statusCode == 201) {
    print('Class registered successfully');
  } else if (response.statusCode == 400) {
    print('Missing required fields');
  } else if (response.statusCode == 500) {
    print('Internal server error');
  } else {
    print('Failed to register class: ${response.statusCode}');
  }
}