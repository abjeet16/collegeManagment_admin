import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/api_service.dart';
import '../modules/SubjectDTO.dart';
import '../modules/class_entity.dart';
import 'AttendanceScreen.dart';

class StudentSubjectsScreen extends StatefulWidget {
  final String studentId;
  final ClassEntity classEntity;

  StudentSubjectsScreen({required this.studentId, required this.classEntity});

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
      List<SubjectDTO>? fetchedSubjects =
      await ApiService.getAllSubjects(token, widget.classEntity.course.id,widget.classEntity.id);
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
          // Check if assignedTeacher is null or empty
          bool isTeacherAssigned = subjects[index].assignedTeacher != null &&
              subjects[index].assignedTeacher!.isNotEmpty;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceScreen(
                    studentId: widget.studentId,
                    classEntity: widget.classEntity,
                    subjectId: subjects[index].subjectId, // Pass subjectId
                  ),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text(
                  subjects[index].subjectName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Code: ${subjects[index].subjectCode}"),
                    Text(
                      isTeacherAssigned
                          ? "Assigned Teacher: ${subjects[index].assignedTeacher}"
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

