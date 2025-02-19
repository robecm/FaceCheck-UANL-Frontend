class ModifyExamResultsRequest {
  final List<ExamResultModification> results;

  ModifyExamResultsRequest({required this.results});

  Map<String, dynamic> toJson() {
    return {
      'results': results.map((result) => result.toJson()).toList(),
    };
  }
}

class ExamResultModification {
  final int? resultId;
  final double? score;
  final int? studentId;
  final int? examId;
  final int? classId;

  ExamResultModification({
    this.resultId,
    this.score,
    this.studentId,
    this.examId,
    this.classId,
  });

  Map<String, dynamic> toJson() {
    return {
      'result_id': resultId,
      'score': score,
      'student_id': studentId,
      'exam_id': examId,
      'class_id': classId,
    };
  }
}