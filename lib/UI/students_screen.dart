import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'StudentOptionsScreen.dart';
import '../helper/api_service.dart';
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
        filteredStudents = students
            .where((student) => student.studentName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Students - ${widget.classEntity.section}")),
      body: Column(
        children: [
          // Search bar
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

          // Student list
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredStudents.isEmpty
                ? Center(
              child: Text(
                "No students found",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Navigate to StudentOptionsScreen with studentId (String) and classEntity
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentOptionsScreen(
                          studentId: filteredStudents[index].studentId, // String ID
                          classEntity: widget.classEntity,
                        ),
                      ),
                    );
                  },
                  child: StudentCard(student: filteredStudents[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final Student student;

  StudentCard({required this.student});

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
            student.studentName[0], // First letter as avatar
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          student.studentName,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text("ID: ${student.studentId}"), // Display string ID
      ),
    );
  }
}
