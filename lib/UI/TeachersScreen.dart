import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/api_service.dart';
import '../modules/AddTeacherRequest.dart';
import 'TeacherOptionsScreen.dart';
import '../enums/Department.dart';

class TeachersScreen extends StatefulWidget {
  @override
  _TeachersScreenState createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  List<Map<String, dynamic>> teachers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    setState(() {
      isLoading = true;
    });

    String? token = await _getToken();
    if (token != null) {
      List<Map<String, dynamic>>? fetchedTeachers =
      await ApiService.getAllTeachers(token);
      if (fetchedTeachers != null) {
        setState(() {
          teachers = fetchedTeachers;
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

  void _showDeleteConfirmationDialog(BuildContext context, String teacherId) {
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Teacher"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("⚠️ This will delete all records for Teacher ID: $teacherId"),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Admin Password"),
              ),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Confirm Password"),
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
                if (passwordController.text.isEmpty ||
                    confirmPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Both fields are required")),
                  );
                  return;
                }

                if (passwordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Passwords do not match")),
                  );
                  return;
                }

                String? token = await _getToken();
                if (token != null) {
                  String? result = await ApiService.deleteTeacherById(
                    teacherId: teacherId,
                    adminPassword: passwordController.text,
                    token: token,
                  );

                  Navigator.pop(context); // Close dialog

                  if (result != null) {
                    _fetchTeachers(); // Refresh
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Teacher deleted successfully")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to delete teacher")),
                    );
                  }
                }
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _showAddTeacherDialog() {
    TextEditingController emailController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController userNameController = TextEditingController();
    TextEditingController firstNameController = TextEditingController();
    TextEditingController lastNameController = TextEditingController();
    Department? selectedDepartment;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Add New Teacher"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: userNameController,
                      decoration: InputDecoration(labelText: "Username"),
                    ),
                    TextField(
                      controller: firstNameController,
                      decoration: InputDecoration(labelText: "First Name"),
                    ),
                    TextField(
                      controller: lastNameController,
                      decoration: InputDecoration(labelText: "Last Name"),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: "Email"),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: "Password"),
                      obscureText: true,
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(labelText: "Phone"),
                      keyboardType: TextInputType.phone,
                    ),
                    DropdownButtonFormField<Department>(
                      value: selectedDepartment,
                      decoration: InputDecoration(labelText: "Department"),
                      items: Department.values.map((Department department) {
                        return DropdownMenuItem<Department>(
                          value: department,
                          child: Text(department.value),
                        );
                      }).toList(),
                      onChanged: (Department? newValue) {
                        setDialogState(() {
                          selectedDepartment = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    isSubmitting
                        ? CircularProgressIndicator()
                        : SizedBox.shrink(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (userNameController.text.isEmpty ||
                        firstNameController.text.isEmpty ||
                        lastNameController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        passwordController.text.isEmpty ||
                        phoneController.text.isEmpty ||
                        selectedDepartment == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("All fields are required")),
                      );
                      return;
                    }

                    setDialogState(() {
                      isSubmitting = true;
                    });

                    final request = AddTeacherRequest(
                      userName: userNameController.text,
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      phone: phoneController.text,
                      department: selectedDepartment!.value,
                    );

                    bool success = await ApiService.addTeacher(request);

                    setDialogState(() {
                      isSubmitting = false;
                    });

                    if (success) {
                      Navigator.pop(context); // Close dialog
                      _fetchTeachers(); // Refresh teacher list
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Teacher added successfully!")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to add teacher")),
                      );
                    }
                  },
                  child: Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Teachers")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : teachers.isEmpty
          ? Center(
        child: Text(
          "No teachers available",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        itemCount: teachers.length,
        itemBuilder: (context, index) {
          return TeacherCard(
            teacher: teachers[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeacherOptionsScreen(
                    teacherId: teachers[index]['teacherId'],
                  ),
                ),
              );
            },
            onDeletePressed: () {
              _showDeleteConfirmationDialog(
                  context, teachers[index]['teacherId']);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTeacherDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
        tooltip: "Add New Teacher",
      ),
    );
  }
}

class TeacherCard extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final VoidCallback onTap;
  final VoidCallback onDeletePressed;

  TeacherCard({
    required this.teacher,
    required this.onTap,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          leading: CircleAvatar(
            child: Text(teacher['teacherName'][0]),
            backgroundColor: Colors.blueAccent,
          ),
          title: Text(
            teacher['teacherName'],
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text("Department: ${teacher['department']}"),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: onDeletePressed,
          ),
        ),
      ),
    );
  }
}



