class SubjectDTO {
  final int subjectId;
  final String subjectName;
  final String subjectCode;
  final String? assignedTeacher;

  SubjectDTO({
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    this.assignedTeacher,
  });

  factory SubjectDTO.fromJson(Map<String, dynamic> json) {
    return SubjectDTO(
      subjectId: json['subjectId'],
      subjectName: json['subjectName'],
      subjectCode: json['subjectCode'],
      assignedTeacher: json['assignedTeacher'],
    );
  }
}


