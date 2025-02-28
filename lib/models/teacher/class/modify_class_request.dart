import 'dart:convert';
import 'package:http/http.dart' as http;

class ModifyClassRequest {
  final int classId;
  final String className;
  final int teacherId;
  final int groupNum;
  final String semester;
  final String classRoom;
  final String startTime;
  final String endTime;
  final String weekDays;

  ModifyClassRequest({
    required this.classId,
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
      'class_id': classId,
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

Future<void> updateClass(ModifyClassRequest request) async {
  final url = Uri.parse('https://yourapi.com/api/class/update');
  final response = await http.put(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(request.toJson()),
  );

  if (response.statusCode == 200) {
    print('Class updated successfully');
  } else if (response.statusCode == 400) {
    print('Missing required fields');
  } else if (response.statusCode == 500) {
    print('Internal server error');
  } else {
    print('Failed to update class: ${response.statusCode}');
  }
}