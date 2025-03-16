import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/api_service.dart';
import '../modules/SubjectDTO.dart';
import '../modules/course.dart';

class SubjectsScreen extends StatefulWidget {
  final Course course; // ✅ Only courseId is needed

  SubjectsScreen({required this.course, required int classId});

  @override
  _SubjectsScreenState createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
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
      List<SubjectDTO>? fetchedSubjects = await ApiService.getAllSubjects(token, widget.course.id);
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
      appBar: AppBar(title: Text("Subjects - ${widget.course.courseName}")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: subjects.isEmpty
            ? Center(
          child: Text(
            "No subjects available",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        )
            : GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 subjects per row
            childAspectRatio: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            return SubjectCard(subject: subjects[index]);
          },
        ),
      ),
    );
  }
}

class SubjectCard extends StatelessWidget {
  final SubjectDTO subject;

  SubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              subject.subjectName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
            Text(
              "Code: ${subject.subjectCode}",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
