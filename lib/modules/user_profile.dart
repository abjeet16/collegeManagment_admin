class UserProfile {
  final String universityId;
  final String firstName;
  final String lastName;
  final String email;
  final int phone; // or String if the API returns a phone number as a string

  UserProfile({
    required this.universityId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      universityId: json['universityId'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'], // adjust type if needed
    );
  }
}
