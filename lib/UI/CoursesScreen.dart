import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oktoast/oktoast.dart';
import 'package:http/http.dart' as http;
import '../helper/api_service.dart';
import '../modules/course.dart';
import 'course_options_screen.dart';

class CoursesScreen extends StatefulWidget {
  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<Course> courses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() {
      isLoading = true;
    });

    String? token = await _getToken();
    if (token != null) {
      List<Course>? fetchedCourses = await ApiService.getAllCourses(token);
      if (fetchedCourses != null) {
        setState(() {
          courses = fetchedCourses;
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _showDeleteConfirmationDialog(Course course) async {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Course"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter password to confirm deletion of '${course.courseName}'"),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(hintText: "Enter Password"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String password = passwordController.text.trim();
                if (password.isNotEmpty) {
                  String? token = await _getToken();
                  if (token != null) {
                    bool success = await ApiService.deleteCourse(token, course.id, password);
                    Navigator.pop(context); // Close dialog

                    if (success) {
                      _fetchCourses(); // Refresh list after deletion
                      showToast("Course deleted successfully!", position: ToastPosition.bottom);
                    } else {
                      showToast("Incorrect password. Try again!", position: ToastPosition.bottom, backgroundColor: Colors.red);
                    }
                  }
                }
              },
              child: Text("Delete"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddCourseDialog() async {
    TextEditingController courseNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Course"),
          content: TextField(
            controller: courseNameController,
            decoration: InputDecoration(hintText: "Enter Course Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String courseName = courseNameController.text.trim();
                if (courseName.isNotEmpty) {
                  String? token = await _getToken();
                  if (token != null) {
                    bool success = await ApiService.addCourse(token, courseName);
                    Navigator.pop(context); // Close dialog

                    if (success) {
                      _fetchCourses(); // Refresh course list
                      showToast("Course added successfully!", position: ToastPosition.bottom);
                    } else {
                      showToast("Failed to add course!", position: ToastPosition.bottom, backgroundColor: Colors.red);
                    }
                  }
                }
              },
              child: Text("Add"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Courses"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddCourseDialog, // Add Course Function
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            return CourseCard(
              course: courses[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseOptionsScreen(course: courses[index]),
                  ),
                );
              },
              onDelete: () => _showDeleteConfirmationDialog(courses[index]), // Delete action
            );
          },
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  CourseCard({required this.course, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Navigate when tapped anywhere on the card
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  course.courseName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete, // Delete function
              ),
            ],
          ),
        ),
      ),
    );
  }
}








