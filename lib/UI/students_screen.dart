import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

import '../helper/api_service.dart';
import '../modules/StudentRegistrationDTO.dart';
import 'StudentOptionsScreen.dart';
import '../modules/student.dart';
import '../modules/class_entity.dart';

class StudentsScreen extends StatefulWidget {
  final ClassEntity classEntity;

  StudentsScreen({required this.classEntity});

  @override
  _StudentsScreenState createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student> students = [];
  List<Student> filteredStudents = [];
  bool isLoading = true;
  bool isUploading = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() {
      isLoading = true;
    });

    String? token = await _getToken();
    if (token != null) {
      List<Student>? fetchedStudents = await ApiService.getStudentsByClassId(token, widget.classEntity.id);
      if (fetchedStudents != null) {
        setState(() {
          students = fetchedStudents;
          filteredStudents = fetchedStudents;
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

  void _filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredStudents = students;
      } else {
        filteredStudents = students.where((student) => student.studentName.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  void _showDeleteConfirmationDialog(Student student) {
    final adminPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Student"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Are you sure you want to delete student '${student.studentName}' (ID: ${student.studentId})?\n\n⚠️ This will permanently delete all related data including attendance.",
              ),
              SizedBox(height: 16),
              TextField(
                controller: adminPassController,
                decoration: InputDecoration(labelText: "Admin Password"),
                obscureText: true,
              ),
              TextField(
                controller: confirmPassController,
                decoration: InputDecoration(labelText: "Confirm Password"),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (adminPassController.text.isEmpty || confirmPassController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter both passwords.")));
                  return;
                }
                if (adminPassController.text != confirmPassController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Passwords do not match.")));
                  return;
                }

                String? token = await _getToken();
                if (token == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not authorized.")));
                  return;
                }

                final result = await ApiService.deleteStudentById(
                  studentId: student.studentId,
                  adminPassword: adminPassController.text,
                  token: token,
                );

                Navigator.pop(context);

                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Student deleted successfully.")));
                  await _fetchStudents();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete student.")));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Students - ${widget.classEntity.section}")),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: _filterStudents,
                  decoration: InputDecoration(
                    labelText: "Search by name",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredStudents.isEmpty
                    ? Center(child: Text("No students found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                    : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    return StudentCard(
                      student: filteredStudents[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentOptionsScreen(
                              studentId: filteredStudents[index].studentId,
                              classEntity: widget.classEntity,
                            ),
                          ),
                        );
                      },
                      onDelete: () {
                        _showDeleteConfirmationDialog(filteredStudents[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  StudentCard({required this.student, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Text(
            student.studentName[0].toUpperCase(),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(student.studentName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        subtitle: Text("ID: ${student.studentId}"),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}








