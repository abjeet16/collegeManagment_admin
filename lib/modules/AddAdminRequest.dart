class AddAdminRequest {
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;

  AddAdminRequest({
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'phone': phone,
    };
  }

  factory AddAdminRequest.fromJson(Map<String, dynamic> json) {
    return AddAdminRequest(
      userName: json['userName'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      phone: json['phone'],
    );
  }
}
