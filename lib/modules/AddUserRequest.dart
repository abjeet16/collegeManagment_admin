import 'dart:convert';
import '../enums/Role.dart'; // Import the Role enum

class AddUserRequest {
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;
  final Role role; // Use enum instead of string

  AddUserRequest({
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
  });

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      "userName": userName,
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "password": password,
      "phone": phone,
      "role": role.value, // Convert enum to string before sending
    };
  }

  // Convert JSON to object
  factory AddUserRequest.fromJson(Map<String, dynamic> json) {
    return AddUserRequest(
      userName: json["userName"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      email: json["email"],
      password: json["password"],
      phone: json["phone"],
      role: roleFromString(json["role"]) ?? Role.STUDENT, // Convert string to enum
    );
  }

  // Encode to JSON string
  String toJsonString() => jsonEncode(toJson());
}
