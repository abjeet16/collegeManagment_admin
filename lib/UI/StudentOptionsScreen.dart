import 'package:flutter/material.dart';
import '../modules/class_entity.dart';
import 'AttendanceScreen.dart';
import 'StudentProfileScreen.dart';

class StudentOptionsScreen extends StatelessWidget {
  final String studentId;
  final ClassEntity classEntity;
  final int subjectId;

  StudentOptionsScreen({
    required this.studentId,
    required this.classEntity,
    required this.subjectId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Options"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.check),
            title: Text("View Attendance"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceScreen(
                    studentId: studentId,
                    classEntity: classEntity,
                    subjectId: subjectId,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("View Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentProfileScreen(
                    studentId: studentId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
