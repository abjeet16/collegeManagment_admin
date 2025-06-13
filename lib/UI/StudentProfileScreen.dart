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

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final adminPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStudentDetails();
  }

  Future<void> _fetchStudentDetails() async {
    setState(() => isLoading = true);
    String? token = await _getToken();
    if (token != null) {
      StudentDetails? fetchedStudent = await ApiService.getStudentById(token, widget.studentId);
      setState(() {
        studentDetails = fetchedStudent;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
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
      builder: (context) => AlertDialog(
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
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Admin password is required")));
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
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? "Success")));
                _fetchStudentDetails(); // refresh
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final newPasswordController = TextEditingController();
    adminPasswordController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField("New Password", newPasswordController, isPassword: true),
            _buildTextField("Admin Password", adminPasswordController, isPassword: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text.isEmpty || adminPasswordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("All fields are required")));
                return;
              }

              final userDetails = UserDetailChangeReq(
                universityId: widget.studentId,
                password: newPasswordController.text,
                adminPassword: adminPasswordController.text,
              );

              try {
                Map<String, dynamic> response = await ApiService.changeUserDetails(userDetails);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? "Success")));
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: Text("Change"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, required String value}) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(value, style: TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Profile"),
        actions: [
          IconButton(icon: Icon(Icons.edit), onPressed: _showEditDialog),
          IconButton(icon: Icon(Icons.lock), onPressed: _showChangePasswordDialog),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : studentDetails == null
          ? Center(child: Text("Failed to load student details"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoTile(
              icon: Icons.account_box,
              title: "University ID",
              value: widget.studentId,
            ),
            _buildInfoTile(
              icon: Icons.person,
              title: "Name",
              value: "${studentDetails!.firstName} ${studentDetails!.lastName}",
            ),
            _buildInfoTile(
              icon: Icons.email,
              title: "Email",
              value: studentDetails!.email,
            ),
            _buildInfoTile(
              icon: Icons.phone,
              title: "Phone",
              value: studentDetails!.phone.toString(),
            ),
            _buildInfoTile(
              icon: Icons.class_,
              title: "Section",
              value: studentDetails!.section,
            ),
            _buildInfoTile(
              icon: Icons.school,
              title: "Course",
              value: studentDetails!.courseName,
            ),
          ],
        ),
      ),
    );
  }
}

