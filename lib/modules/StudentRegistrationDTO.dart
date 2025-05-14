class StudentRegistrationDTO {
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;

  StudentRegistrationDTO({
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "userName": userName,
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "phone": phone,
      "password": password,
    };
  }
}

