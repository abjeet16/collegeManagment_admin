import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/api_service.dart';
import '../modules/SubjectDTO.dart';
import '../modules/course.dart';

class SubjectsScreen extends StatefulWidget {
  final Course course;

  SubjectsScreen({required this.course});

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
      List<SubjectDTO>? fetchedSubjects =
      await ApiService.getAllSubjects(token, widget.course.id,-1);
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

  void _showAddSubjectDialog() {
    TextEditingController subjectIdController = TextEditingController();
    TextEditingController subjectNameController = TextEditingController();
    TextEditingController SemController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Subject"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Course: ${widget.course.courseName}",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(
                controller: subjectIdController,
                decoration: InputDecoration(labelText: "Subject ID"),
              ),
              TextField(
                controller: subjectNameController,
                decoration: InputDecoration(labelText: "Subject Name"),
              ),
              TextField(
                controller: SemController,
                decoration: InputDecoration(labelText: "Semester"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String? token = await _getToken();
                if (token != null) {
                  bool success = await ApiService.addSubject(
                    token,
                    subjectIdController.text,
                    subjectNameController.text,
                    widget.course.courseName,
                    int.tryParse(SemController.text)?? 0
                  );

                  if (success) {
                    Navigator.pop(context); // Close dialog on success
                    _fetchSubjects(); // Refresh the list
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to add subject")),
                    );
                  }
                }
              },
              child: Text("Add Subject"),
            ),
          ],
        );
      },
    );
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSubjectDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
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
            Text(
              "Sem : ${subject.semester}",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}


