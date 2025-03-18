import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/api_service.dart';
import '../modules/course.dart';
import '../modules/class_entity.dart';
import 'students_screen.dart';

class ClassesScreen extends StatefulWidget {
  final Course course;
  final bool fromAssignTeacher;

  ClassesScreen({required this.course,required this.fromAssignTeacher});

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
      List<ClassEntity>? fetchedClasses = await ApiService.getAllClasses(token, widget.course.id);
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
    return prefs.getString("auth_token");
  }

  void _showAddClassDialog() {
    TextEditingController batchYearController = TextEditingController();
    TextEditingController sectionController = TextEditingController();

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
                  bool success = await ApiService.addClass(
                    token,
                    widget.course.courseName, // Use the course name
                    int.tryParse(batchYearController.text) ?? 0,
                    sectionController.text,
                  );

                  if (success) {
                    Navigator.pop(context); // Close dialog on success
                    _fetchClasses(); // Refresh the list
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
            crossAxisCount: 2, // 2 classes per row
            childAspectRatio: 2.5, // Adjusted ratio for better UI
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: classes.length,
          itemBuilder: (context, index) {
            return ClassCard(
              classEntity: classes[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentsScreen(
                      classEntity: classes[index], // Pass class details
                    ),
                  ),
                );
              },
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

  ClassCard({required this.classEntity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Navigate when the class is clicked
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                classEntity.section,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                "Batch: ${classEntity.batchYear}",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





