import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/api_service.dart';
import '../modules/TeacherDetailResponse.dart';
import 'TeacherProfileScreen.dart';
import 'AssignClassesScreen.dart'; // Placeholder screen

class TeacherOptionsScreen extends StatelessWidget {
  final String teacherId;

  TeacherOptionsScreen({required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Teacher Options")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Teacher ID: $teacherId",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Fetch teacher profile and navigate to profile screen
                String? token = await getToken();
                if (token != null) {
                  TeacherDetailResponse? teacher =
                  await ApiService.getTeacherDetails(token, teacherId);
                  if (teacher != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeacherProfileScreen(teacher: teacher),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to fetch teacher profile.")),
                    );
                  }
                }
              },
              child: Text("Teacher Profile"),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to Assign Classes screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignClassesScreen(teacherId: teacherId),
                  ),
                );
              },
              child: Text("Assign Classes"),
            ),
          ],
        ),
      ),
    );
  }

  // Retrieve auth token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }
}
