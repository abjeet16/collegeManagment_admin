import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/api_service.dart';
import 'TeacherOptionsScreen.dart';

class TeachersScreen extends StatefulWidget {
  @override
  _TeachersScreenState createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  List<Map<String, dynamic>> teachers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    setState(() {
      isLoading = true;
    });

    String? token = await _getToken();
    if (token != null) {
      List<Map<String, dynamic>>? fetchedTeachers = await ApiService.getAllTeachers(token);
      if (fetchedTeachers != null) {
        setState(() {
          teachers = fetchedTeachers;
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Teachers")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : teachers.isEmpty
          ? Center(
        child: Text(
          "No teachers available",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        itemCount: teachers.length,
        itemBuilder: (context, index) {
          return TeacherCard(
            teacher: teachers[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeacherOptionsScreen(
                    teacherId: teachers[index]['teacherId'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TeacherCard extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final VoidCallback onTap;

  TeacherCard({required this.teacher, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Navigate to TeacherOptionsScreen on tap
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          leading: CircleAvatar(
            child: Text(teacher['teacherName'][0]), // First letter of name
            backgroundColor: Colors.blueAccent,
          ),
          title: Text(
            teacher['teacherName'],
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text("Department: ${teacher['department']}"),
          trailing: Text(
            teacher['teacherId'],
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

