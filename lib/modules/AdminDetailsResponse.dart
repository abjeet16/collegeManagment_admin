class AdminDetailResponse {
  final String adminId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  AdminDetailResponse({
    required this.adminId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  factory AdminDetailResponse.fromJson(Map<String, dynamic> json) {
    return AdminDetailResponse(
      adminId: json['universityId'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'universityId': adminId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
    };
  }

  AdminDetailResponse copyWith({
    String? teacherId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) {
    return AdminDetailResponse(
      adminId: teacherId ?? this.adminId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}