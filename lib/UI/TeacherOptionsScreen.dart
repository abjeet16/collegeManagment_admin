import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/api_service.dart';
import '../modules/TeacherDetailResponse.dart';
import 'CoursesScreen.dart';
import 'TeacherProfileScreen.dart';

class TeacherOptionsScreen extends StatelessWidget {
  final String teacherId;

  TeacherOptionsScreen({required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Teacher Options")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Teacher ID: $teacherId",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 30),
              _buildButton(
                context,
                label: "View Profile",
                onPressed: () => _navigateToTeacherProfile(context),
              ),
              SizedBox(height: 16),
              _buildButton(
                context,
                label: "Assign Classes",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CoursesScreen(fromAssignTeacher: true,teacherId: teacherId,),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, {required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(label, style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Future<void> _navigateToTeacherProfile(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    try {
      String? token = await getToken();
      if (token != null) {
        TeacherDetailResponse? teacher = await ApiService.getTeacherDetails(token, teacherId);
        Navigator.pop(context); // Close loader

        if (teacher != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherProfileScreen(teacher: teacher),
            ),
          );
        } else {
          _showError(context, "Failed to fetch teacher profile.");
        }
      } else {
        Navigator.pop(context);
        _showError(context, "Authentication token missing.");
      }
    } catch (e) {
      Navigator.pop(context);
      _showError(context, "Error: $e");
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }
}
