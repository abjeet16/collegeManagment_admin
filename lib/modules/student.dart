class Student {
  final String studentName;
  final String studentId;

  Student({
    required this.studentName,
    required this.studentId,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentName: json['studentName'],
      studentId: json['studentId'],
    );
  }
}
