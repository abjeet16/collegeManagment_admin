import 'dart:convert';

class AddTeacherRequest {
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;
  final String department;

  AddTeacherRequest({
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    required this.department,
  });

  Map<String, dynamic> toJson() {
    return {
      "userName": userName,
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "password": password,
      "phone": phone,
      "department": department,
    };
  }

  String toJsonString() => jsonEncode(toJson());
}
