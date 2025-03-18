class TeacherDetailResponse {
  final String teacherId;
  final String firstName;
  final String lastName;
  final String email;
  final String department;
  final int phone;

  TeacherDetailResponse({
    required this.teacherId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.department,
    required this.phone,
  });

  factory TeacherDetailResponse.fromJson(Map<String, dynamic> json) {
    return TeacherDetailResponse(
      teacherId: json['teacherId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      department: json['department'],
      phone: json['phone'],
    );
  }
}
