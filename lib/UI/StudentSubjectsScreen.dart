import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/api_service.dart';
import '../modules/SubjectDTO.dart';
import '../modules/class_entity.dart';
import 'students_screen.dart'; // <== Import StudentsScreen

class StudentSubjectsScreen extends StatefulWidget {
  final ClassEntity classEntity;

  StudentSubjectsScreen({required this.classEntity});

  @override
  _StudentSubjectsScreenState createState() => _StudentSubjectsScreenState();
}

class _StudentSubjectsScreenState extends State<StudentSubjectsScreen> {
  List<SubjectDTO> subjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    setState(() {
      isLoading = true;
    });

    String? token = await _getToken();
    if (token != null) {
      List<SubjectDTO>? fetchedSubjects = await ApiService.getAllSubjects(
        token,
        widget.classEntity.course.id,
        widget.classEntity.id,
      );

      if (fetchedSubjects != null) {
        setState(() {
          subjects = fetchedSubjects;
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
      appBar: AppBar(title: Text("Select Subject")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : subjects.isEmpty
          ? Center(
        child: Text(
          "No subjects available",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          bool isTeacherAssigned = subject.assignedTeacher != null &&
              subject.assignedTeacher!.isNotEmpty;

          return GestureDetector(
            onTap: () {
              // 👉 Navigate to StudentsScreen with classEntity
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentsScreen(
                    classEntity: widget.classEntity,
                    subjectId: subject.subjectId,
                  ),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text(
                  subject.subjectName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Code: ${subject.subjectCode}"),
                    Text(
                      isTeacherAssigned
                          ? "Assigned Teacher: ${subject.assignedTeacher}"
                          : "No Teacher ASSIGNED",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isTeacherAssigned ? Colors.black : Colors.red,
                      ),
                    ),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          );
        },
      ),
    );
  }
}
