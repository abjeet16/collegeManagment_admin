class UserLoginResponse {
  final String token;
  final String lastName;
  final String firstName;
  final String username;

  UserLoginResponse({
    required this.token,
    required this.lastName,
    required this.firstName,
    required this.username,
  });

  // Factory method to convert JSON response to Dart object
  factory UserLoginResponse.fromJson(Map<String, dynamic> json) {
    return UserLoginResponse(
      token: json['token'],
      lastName: json['lastName'],
      firstName: json['firstName'],
      username: json['username'],
    );
  }
}
