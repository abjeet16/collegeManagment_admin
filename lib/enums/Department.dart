enum Department {
  BCA,
  BBA,
  MCA,
  MBA,
  BA,
  BCom,
}

// Extension to convert enum to string
extension DepartmentExtension on Department {
  String get value {
    return this.toString().split('.').last;
  }
}

// Function to convert a string to a Department enum
Department? departmentFromString(String departmentString) {
  for (Department department in Department.values) {
    if (department.value.toUpperCase() == departmentString.toUpperCase()) {
      return department;
    }
  }
  return null; // Return null if no match
}
