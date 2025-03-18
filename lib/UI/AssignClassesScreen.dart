import 'package:flutter/material.dart';

class AssignClassesScreen extends StatelessWidget {
  final String teacherId;

  AssignClassesScreen({required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Assign Classes")),
      body: Center(
        child: Text(
          "Feature not implemented yet!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
