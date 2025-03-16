class Course {
  final int id;
  final String courseName;

  Course({required this.id, required this.courseName});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      courseName: json['courseName'],
    );
  }
}
