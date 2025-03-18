import 'package:flutter/material.dart';
import '../modules/TeacherDetailResponse.dart';

class TeacherProfileScreen extends StatelessWidget {
  final TeacherDetailResponse teacher;

  TeacherProfileScreen({required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Teacher Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${teacher.firstName} ${teacher.lastName}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Email: ${teacher.email}", style: TextStyle(fontSize: 16)),
            Text("Phone: ${teacher.phone}", style: TextStyle(fontSize: 16)),
            Text("Department: ${teacher.department}", style: TextStyle(fontSize: 16)),
            Text("Teacher ID: ${teacher.teacherId}", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
