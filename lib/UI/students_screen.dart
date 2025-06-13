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
  final int subjectId;

  StudentsScreen({required this.classEntity,required this.subjectId});

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
      List<Student>? fetchedStudents =
      await ApiService.getStudentsByClassId(token, widget.classEntity.id);
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
        filteredStudents = students
            .where((student) => student.studentName
            .toLowerCase()
            .contains(query.toLowerCase()))
            .toList();
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
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (adminPassController.text.isEmpty ||
                    confirmPassController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter both passwords.")));
                  return;
                }
                if (adminPassController.text != confirmPassController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Passwords do not match.")));
                  return;
                }

                String? token = await _getToken();
                if (token == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Not authorized.")));
                  return;
                }

                final result = await ApiService.deleteStudentById(
                  studentId: student.studentId,
                  adminPassword: adminPassController.text,
                  token: token,
                );

                Navigator.pop(context);

                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Student deleted successfully.")));
                  await _fetchStudents();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to delete student.")));
                }
              },
              child: Text("Delete"),
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndUploadExcel() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result == null) return;

      setState(() {
        isUploading = true;
      });

      final fileBytes = result.files.single.bytes;
      final filePath = result.files.single.path;
      List<int>? excelBytes;

      if (fileBytes != null) {
        excelBytes = fileBytes;
      } else if (filePath != null) {
        final file = File(filePath);
        excelBytes = await file.readAsBytes();
      }

      if (excelBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("❌ Unable to read the selected Excel file.")));
        setState(() {
          isUploading = false;
        });
        return;
      }

      final excel = Excel.decodeBytes(excelBytes);
      final sheet = excel.tables[excel.tables.keys.first];

      if (sheet == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Excel sheet is empty.")));
        setState(() {
          isUploading = false;
        });
        return;
      }

      List<StudentRegistrationDTO> studentsToRegister = [];

      for (int rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
        final row = sheet.row(rowIndex);

        if (row.length < 6) continue;

        final student = StudentRegistrationDTO(
          userName: row[0]?.value.toString() ?? "",
          firstName: row[1]?.value.toString() ?? "",
          lastName: row[2]?.value.toString() ?? "",
          email: row[3]?.value.toString() ?? "",
          phone: row[4]?.value.toString() ?? "",
          password: row[5]?.value.toString() ?? "",
        );

        if (student.userName.isNotEmpty &&
            student.firstName.isNotEmpty &&
            student.lastName.isNotEmpty &&
            student.email.isNotEmpty &&
            student.phone.isNotEmpty &&
            student.password.isNotEmpty) {
          studentsToRegister.add(student);
        }
      }

      if (studentsToRegister.isNotEmpty) {
        final result = await ApiService.addStudentsBulk(
          classEntity: widget.classEntity,
          students: studentsToRegister,
        );

        final count = result["successCount"] ?? 0;
        final errors = result["failedEntries"] ?? [];

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Uploaded $count students. Errors: ${errors.length}"),
          duration: Duration(seconds: 4),
        ));

        await _fetchStudents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("No valid student data found in the Excel file.")));
      }
    } catch (e) {
      print("❌ Excel upload error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Students - ${widget.classEntity.section}"),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            tooltip: "Upload Students Excel",
            onPressed: isUploading ? null : _pickAndUploadExcel,
          ),
        ],
      ),
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
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredStudents.isEmpty
                    ? Center(
                    child: Text("No students found",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)))
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
                            builder: (context) =>
                                StudentOptionsScreen(
                                  studentId:
                                  filteredStudents[index].studentId,
                                  classEntity: widget.classEntity,
                                  subjectId: widget.subjectId,
                                ),
                          ),
                        );
                      },
                      onDelete: () {
                        _showDeleteConfirmationDialog(
                            filteredStudents[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          if (isUploading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      "Adding students...",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
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

  StudentCard(
      {required this.student, required this.onTap, required this.onDelete});

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
        title: Text(student.studentName,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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










