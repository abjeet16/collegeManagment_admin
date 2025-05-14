class SubjectDTO {
  final int subjectId;
  final String subjectName;
  final String subjectCode;
  final String? assignedTeacher;
  final int semester;

  SubjectDTO({
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    this.assignedTeacher,
    required this.semester
  });

  factory SubjectDTO.fromJson(Map<String, dynamic> json) {
    return SubjectDTO(
      subjectId: json['subjectId'],
      subjectName: json['subjectName'],
      subjectCode: json['subjectCode'],
      assignedTeacher: json['assignedTeacher'],
      semester : json['semester']
    );
  }
}


