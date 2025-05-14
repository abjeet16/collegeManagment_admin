class TeacherDetailResponse {
  final String teacherId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String department;

  TeacherDetailResponse({
    required this.teacherId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.department,
  });

  factory TeacherDetailResponse.fromJson(Map<String, dynamic> json) {
    return TeacherDetailResponse(
      teacherId: json['teacherId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'].toString(),
      department: json['department'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'department': department,
    };
  }

  TeacherDetailResponse copyWith({
    String? teacherId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? department,
  }) {
    return TeacherDetailResponse(
      teacherId: teacherId ?? this.teacherId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
    );
  }
}
