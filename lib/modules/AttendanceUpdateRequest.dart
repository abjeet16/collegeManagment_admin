class AttendanceUpdateRequest {
  final String studentId;
  final int subjectId;
  final String date;
  final bool status;

  AttendanceUpdateRequest({
    required this.studentId,
    required this.subjectId,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      "studentId": studentId,
      "subjectId": subjectId,
      "date": date,
      "status": status,
    };
  }
}
