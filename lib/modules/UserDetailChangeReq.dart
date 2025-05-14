class UserDetailChangeReq {
  String universityId;
  String? firstName;
  String? lastName;
  int? phone;
  String? email;
  String? password;
  String adminPassword;
  String? department;

  UserDetailChangeReq({
    required this.universityId,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.password,
    required this.adminPassword,
    this.department,
  });

  factory UserDetailChangeReq.fromJson(Map<String, dynamic> json) {
    return UserDetailChangeReq(
      universityId: json['universityId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'] != null ? json['phone'] as int : null,
      email: json['email'],
      password: json['password'],
      adminPassword: json['adminPassword'],
      department: json['department'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'universityId': universityId,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'password': password,
      'adminPassword': adminPassword,
      'department': department,
    };
  }
}
