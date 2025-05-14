import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/api_service.dart';
import '../modules/StudentDetails.dart';
import '../modules/UserDetailChangeReq.dart';

class StudentProfileScreen extends StatefulWidget {
  final String studentId;

  StudentProfileScreen({required this.studentId});

  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  StudentDetails? studentDetails;
  bool isLoading = true;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController adminPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStudentDetails();
  }

  Future<void> _fetchStudentDetails() async {
    setState(() {
      isLoading = true;
    });

    String? token = await _getToken();
    if (token != null) {
      StudentDetails? fetchedStudent = await ApiService.getStudentById(token, widget.studentId);
      setState(() {
        studentDetails = fetchedStudent;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  void _showEditDialog() {
    if (studentDetails == null) return;

    firstNameController.text = studentDetails!.firstName;
    lastNameController.text = studentDetails!.lastName;
    emailController.text = studentDetails!.email;
    phoneController.text = studentDetails!.phone.toString();
    adminPasswordController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Student Details"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField("First Name", firstNameController),
                _buildTextField("Last Name", lastNameController),
                _buildTextField("Email", emailController),
                _buildTextField("Phone", phoneController),
                _buildTextField("Admin Password", adminPasswordController, isPassword: true),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (adminPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Admin password is required")),
                  );
                  return;
                }

                final userDetails = UserDetailChangeReq(
                  universityId: widget.studentId,
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  email: emailController.text,
                  phone: int.tryParse(phoneController.text),
                  adminPassword: adminPasswordController.text,
                );

                try {
                  Map<String, dynamic> response = await ApiService.changeUserDetails(userDetails);
                  String message = response['message'] ?? response.toString();

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

                  _fetchStudentDetails(); // Refresh data
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("An error occurred: $e")),
                  );
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    TextEditingController newPasswordController = TextEditingController();
    adminPasswordController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Change Student Password"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField("New Password", newPasswordController, isPassword: true),
                _buildTextField("Admin Password", adminPasswordController, isPassword: true),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (adminPasswordController.text.isEmpty || newPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Both fields are required")),
                  );
                  return;
                }

                final userDetails = UserDetailChangeReq(
                  universityId: widget.studentId,
                  adminPassword: adminPasswordController.text,
                  password: newPasswordController.text,
                );

                try {
                  Map<String, dynamic> response = await ApiService.changeUserDetails(userDetails);
                  String message = response['message'] ?? response.toString();

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("An error occurred: $e")),
                  );
                }
              },
              child: Text("Change"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _showEditDialog,
            tooltip: "Edit Profile",
          ),
          IconButton(
            icon: Icon(Icons.lock_reset),
            onPressed: _showChangePasswordDialog,
            tooltip: "Change Password",
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : studentDetails == null
          ? Center(child: Text("Failed to load student details"))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("University Id: ${widget.studentId}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Name: ${studentDetails!.firstName} ${studentDetails!.lastName}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
            SizedBox(height: 8),
            Text("Email: ${studentDetails!.email}",
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            SizedBox(height: 8),
            Text("Phone: ${studentDetails!.phone}",
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            SizedBox(height: 8),
            Text("Section: ${studentDetails!.section}",
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            SizedBox(height: 8),
            Text("Course: ${studentDetails!.courseName}",
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}


