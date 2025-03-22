enum Role {
  ADMIN,
  TEACHER,
  STUDENT,
}

// Extension to convert enum to string
extension RoleExtension on Role {
  String get value {
    return this.toString().split('.').last;
  }
}

// Function to convert a string to a Role enum
Role? roleFromString(String roleString) {
  for (Role role in Role.values) {
    if (role.value.toUpperCase() == roleString.toUpperCase()) {
      return role;
    }
  }
  return null; // Return null if the role doesn't match
}
