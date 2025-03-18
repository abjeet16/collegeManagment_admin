import 'package:flutter/material.dart';
import 'CoursesScreen.dart';// Import CoursesScreen

class AssignClassesScreen extends StatelessWidget {
  final String teacherId;

  AssignClassesScreen({required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Assign Classes")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Assign Classes to Teacher",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to CoursesScreen and pass `true`
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoursesScreen(fromAssignTeacher: true,teacherId: teacherId,),
                  ),
                );
              },
              child: Text("Select Course"),
            ),
          ],
        ),
      ),
    );
  }
}

