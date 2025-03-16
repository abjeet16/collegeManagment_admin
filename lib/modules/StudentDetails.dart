class StudentDetails {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String section;
  final String courseName;

  StudentDetails({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.section,
    required this.courseName,
  });

  factory StudentDetails.fromJson(Map<String, dynamic> json) {
    return StudentDetails(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'].toString(), // Convert phone to String
      section: json['section'] ?? '',
      courseName: json['courseName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'section': section,
      'courseName': courseName,
    };
  }
}

