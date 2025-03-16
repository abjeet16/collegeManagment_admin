class SubjectDTO {
  final int subjectId;
  final String subjectName;
  final String subjectCode;

  SubjectDTO({required this.subjectId, required this.subjectName, required this.subjectCode});

  factory SubjectDTO.fromJson(Map<String, dynamic> json) {
    return SubjectDTO(
      subjectId: json['subjectId'],
      subjectName: json['subjectName'],
      subjectCode: json['subjectCode'],
    );
  }
}
