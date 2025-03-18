import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/api_service.dart';
import '../modules/SubjectDTO.dart';
import '../modules/class_entity.dart';

class AssignSubjectsScreen extends StatefulWidget {
  final ClassEntity classEntity;
  final String? teacherId;

  AssignSubjectsScreen({required this.classEntity, required this.teacherId});

  @override
  _AssignSubjectsScreenState createState() => _AssignSubjectsScreenState();
}

class _AssignSubjectsScreenState extends State<AssignSubjectsScreen> {
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

  void _confirmAssignTeacher(SubjectDTO subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Assignment"),
        content: Text("Are you sure you want to assign this teacher to ${subject.subjectName}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _assignTeacherToSubject(subject);
            },
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  }

  void _assignTeacherToSubject(SubjectDTO subject) async {
    if (widget.teacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Teacher ID is missing"), backgroundColor: Colors.red),
      );
      return;
    }

    String? token = await _getToken();
    if (token != null) {
      bool success = await ApiService.assignTeacherToSubject(
        token,
        subject.subjectCode,
        widget.teacherId!,
        widget.classEntity.id,
      );

      if (success) {
        _fetchSubjects(); // Refresh subjects after assignment
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Teacher assigned successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to assign teacher"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _changeTeacher(SubjectDTO subject) {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Change Assigned Teacher"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Enter Admin Password to Confirm Change"),
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
            onPressed: () {
              String password = passwordController.text.trim();
              if (password.isNotEmpty) {
                Navigator.pop(context);
                _updateTeacher(subject, password);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Password cannot be empty"), backgroundColor: Colors.red),
                );
              }
            },
            child: Text("Change Teacher"),
          ),
        ],
      ),
    );
  }

  void _updateTeacher(SubjectDTO subject, String password) async {
    if (widget.teacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Teacher ID is missing"), backgroundColor: Colors.red),
      );
      return;
    }

    String? token = await _getToken();
    if (token != null) {
      bool success = await ApiService.updateAssignedTeacher(
        token,
        subject.subjectCode,
        widget.teacherId!,
        widget.classEntity.id,
        password, // Pass admin password
      );

      if (success) {
        _fetchSubjects(); // Refresh subjects after update
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Teacher changed successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to change teacher"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Assign Subjects - ${widget.classEntity.section}")),
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
          bool isTeacherAssigned =
              subjects[index].assignedTeacher != null &&
                  subjects[index].assignedTeacher!.isNotEmpty;

          return Card(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                      Row(
                        children: [
                          if (!isTeacherAssigned)
                            IconButton(
                              icon: Icon(Icons.person_add, color: Colors.blue),
                              onPressed: () {
                                _confirmAssignTeacher(subjects[index]);
                              },
                            ),
                          if (isTeacherAssigned)
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.orange),
                              onPressed: () {
                                _changeTeacher(subjects[index]);
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}



