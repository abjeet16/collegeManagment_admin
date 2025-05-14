import 'course.dart'; // Import the Course model

class ClassEntity {
  final int id;
  final Course course;
  final int batchYear;
  final String section;
  final int currentSemester;

  ClassEntity({
    required this.id,
    required this.course,
    required this.batchYear,
    required this.section,
    required this.currentSemester
  });

  factory ClassEntity.fromJson(Map<String, dynamic> json) {
    return ClassEntity(
      id: json['id'],
      course: Course.fromJson(json['course']), // Parse Course object
      batchYear: json['batchYear'],
      section: json['section'],
      currentSemester:json['currentSemester']
    );
  }
}
