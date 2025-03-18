import 'package:flutter/material.dart';
import '../modules/course.dart';
import 'classes_screen.dart';
import 'subjects_screen.dart';

class CourseOptionsScreen extends StatelessWidget {
  final Course course;
  final int classId;
  final bool fromAssignTeacher;
  final String? teacherId;

  CourseOptionsScreen({required this.course,required this.fromAssignTeacher,required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(course.courseName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Course Name Heading
            Text(
              course.courseName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),

            // Classes Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassesScreen(course: course,fromAssignTeacher:fromAssignTeacher,teacherId: teacherId,),
                  ),
                );
              },
              child: Text("Classes"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 20),

            // Subjects Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubjectsScreen(course: course),
                  ),
                );
              },
              child: Text("Subjects"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


