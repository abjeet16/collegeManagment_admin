class UserLoginRequest {
  final String uucmsId;
  final String password;

  UserLoginRequest({required this.uucmsId, required this.password});

  // Convert Dart object to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      "uucms_id": uucmsId,
      "password": password,
    };
  }
}
