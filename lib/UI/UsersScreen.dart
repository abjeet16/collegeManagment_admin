import 'package:attendence_admin_fultter/UI/CoursesScreen.dart';
import 'package:flutter/material.dart';

import 'AdminsScreen.dart';
import 'TeachersScreen.dart';// Replace with actual Admins screen

class UsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Users")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UserCategoryCard(
              title: "Students",
              icon: Icons.school,
              color: Colors.blue,
              onTap: () {
                // Redirect to CoursesScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CoursesScreen(fromAssignTeacher: false,teacherId: null,)),
                );
              },
            ),
            SizedBox(height: 20),
            UserCategoryCard(
              title: "Teachers",
              icon: Icons.person,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeachersScreen()),
                );
              },
            ),
            SizedBox(height: 20),
            UserCategoryCard(
              title: "Admins",
              icon: Icons.admin_panel_settings,
              color: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UserCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  UserCategoryCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(width: 15),
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


