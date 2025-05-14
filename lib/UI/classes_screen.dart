import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/api_service.dart';
import '../modules/course.dart';
import '../modules/class_entity.dart';
import 'AssignSubjectsScreen.dart';
import 'students_screen.dart';

class ClassesScreen extends StatefulWidget {
  final Course course;
  final bool fromAssignTeacher;
  final String? teacherId;

  ClassesScreen({
    required this.course,
    required this.fromAssignTeacher,
    required this.teacherId,
  });

  @override
  _ClassesScreenState createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  List<ClassEntity> classes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    setState(() {
      isLoading = true;
    });

    String? token = await _getToken();
    if (token != null) {
      List<ClassEntity>? fetchedClasses =
      await ApiService.getAllClasses(token, widget.course.id);
      if (fetchedClasses != null) {
        setState(() {
          classes = fetchedClasses;
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");  // Ensure token is string or null
  }

  void _showAddClassDialog() {
    TextEditingController batchYearController = TextEditingController();
    TextEditingController sectionController = TextEditingController();
    TextEditingController currentSemController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Class"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Course: ${widget.course.courseName}",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(
                controller: batchYearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Batch Year"),
              ),
              TextField(
                controller: sectionController,
                decoration: InputDecoration(labelText: "Section"),
              ),
              TextField(
                controller: currentSemController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Current Sem"),
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
                String? token = await _getToken();
                if (token != null) {
                  bool success = await ApiService.addClass(
                    token,
                    widget.course.courseName,
                    int.tryParse(batchYearController.text) ?? 0,
                    sectionController.text,
                    int.tryParse(currentSemController.text) ?? 0,
                  );

                  if (success) {
                    Navigator.pop(context);
                    _fetchClasses();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to add class")),
                    );
                  }
                }
              },
              child: Text("Add Class"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteClass(int classId) async {
    TextEditingController passwordController = TextEditingController();

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Enter Admin Password"),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(labelText: "Password"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Confirm Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true && passwordController.text.isNotEmpty) {
      String? token = await _getToken();
      if (token != null) {
        final response = await ApiService.deleteStudentsByClassIdWithPassword(
          classId,
          passwordController.text,
          token,
        );

        print("Delete Response: $response");

        if (response != null && response.contains("deleted successfully")) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Class deleted successfully")),
          );
          _fetchClasses();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to delete class")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Classes - ${widget.course.courseName}")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: classes.isEmpty
            ? Center(
          child: Text(
            "No classes available",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        )
            : GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: classes.length,
          itemBuilder: (context, index) {
            final classEntity = classes[index];

            return ClassCard(
              classEntity: classEntity,
              onTap: () {
                if (widget.fromAssignTeacher) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssignSubjectsScreen(
                        classEntity: classEntity,
                        teacherId: widget.teacherId,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentsScreen(
                        classEntity: classEntity,
                      ),
                    ),
                  );
                }
              },
              onDelete: () => _deleteClass(classEntity.id),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClassDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class ClassCard extends StatelessWidget {
  final ClassEntity classEntity;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  ClassCard({
    required this.classEntity,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ),
              Text(
                classEntity.section,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                "Batch: ${classEntity.batchYear}",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                "Current Sem: ${classEntity.currentSemester}",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}








