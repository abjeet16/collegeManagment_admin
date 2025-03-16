class StudentsSubjectAttendance {
  int id;
  String attendanceDate;
  int schedulePeriod;
  bool present;
  bool _modified = false; // Tracks modification

  StudentsSubjectAttendance({
    required this.id,
    required this.attendanceDate,
    required this.schedulePeriod,
    required this.present,
  });

  // Factory method to convert JSON into an object
  factory StudentsSubjectAttendance.fromJson(Map<String, dynamic> json) {
    return StudentsSubjectAttendance(
      id: json['id'],
      attendanceDate: json['attendanceDate'],
      schedulePeriod: json['schedulePeriod'],
      present: json['present'],
    );
  }

  // Converts object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attendanceDate': attendanceDate,
      'schedulePeriod': schedulePeriod,
      'present': present,
    };
  }

  // Getter to check if object is modified
  bool get isModified => _modified;

  // Method to update present status and mark as modified
  void togglePresent() {
    present = !present;
    _modified = true; // Mark as modified
  }
}

