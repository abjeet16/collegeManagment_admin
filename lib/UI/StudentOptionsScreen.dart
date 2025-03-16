import 'package:flutter/material.dart';
import '../modules/class_entity.dart';
import 'StudentProfileScreen.dart';
import 'StudentSubjectsScreen.dart';

class StudentOptionsScreen extends StatelessWidget {
  final String studentId; // Student ID as a string
  final ClassEntity classEntity;

  StudentOptionsScreen({required this.studentId, required this.classEntity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Student Options")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentSubjectsScreen(
                      studentId: studentId,
                      classEntity: classEntity,
                    ),
                  ),
                );
              },
              child: Text("Attendance"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentProfileScreen(studentId: studentId),
                  ),
                );
              },
              child: Text("Student Profile"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
