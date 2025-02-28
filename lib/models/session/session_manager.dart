class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  int? studentId;
  int? teacherId;
  factory SessionManager() => _instance;
  SessionManager._internal();
}