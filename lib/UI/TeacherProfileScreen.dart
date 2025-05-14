import 'package:flutter/material.dart';
import '../modules/TeacherDetailResponse.dart';
import '../modules/UserDetailChangeReq.dart';
import '../helper/api_service.dart';

class TeacherProfileScreen extends StatefulWidget {
  final TeacherDetailResponse teacher;

  TeacherProfileScreen({required this.teacher});

  @override
  _TeacherProfileScreenState createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  late TeacherDetailResponse teacher;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController adminPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    teacher = widget.teacher;
  }

  void _showEditDialog() {
    firstNameController.text = teacher.firstName;
    lastNameController.text = teacher.lastName;
    emailController.text = teacher.email;
    phoneController.text = teacher.phone.toString();
    departmentController.text = teacher.department;
    adminPasswordController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit Teacher Details"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("First Name", firstNameController),
              _buildTextField("Last Name", lastNameController),
              _buildTextField("Email", emailController),
              _buildTextField("Phone", phoneController),
              _buildTextField("Department", departmentController),
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

              final updateReq = UserDetailChangeReq(
                universityId: teacher.teacherId,
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                email: emailController.text,
                phone: int.tryParse(phoneController.text),
                department: departmentController.text,
                adminPassword: adminPasswordController.text,
              );

              try {
                final result = await ApiService.changeUserDetails(updateReq);
                final message = result['message'] ?? 'Update complete';

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

                // ✅ Only update local teacher object if backend confirms update
                if (message.toLowerCase().contains("success")) {
                  setState(() {
                    teacher = teacher.copyWith(
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                      department: departmentController.text,
                    );
                  });
                }
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
    TextEditingController newPasswordController = TextEditingController();
    adminPasswordController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
              if (adminPasswordController.text.isEmpty || newPasswordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Both fields are required")),
                );
                return;
              }

              final updateReq = UserDetailChangeReq(
                universityId: teacher.teacherId,
                password: newPasswordController.text,
                adminPassword: adminPasswordController.text,
              );

              try {
                final result = await ApiService.changeUserDetails(updateReq);
                final message = result['message'] ?? 'Password updated';

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

                // ✅ no local teacher update needed for password
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
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Teacher Profile"),
        actions: [
          IconButton(icon: Icon(Icons.edit), onPressed: _showEditDialog, tooltip: "Edit"),
          IconButton(icon: Icon(Icons.lock_reset), onPressed: _showChangePasswordDialog, tooltip: "Change Password"),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${teacher.firstName} ${teacher.lastName}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Email: ${teacher.email}", style: TextStyle(fontSize: 16)),
            Text("Phone: ${teacher.phone}", style: TextStyle(fontSize: 16)),
            Text("Department: ${teacher.department}", style: TextStyle(fontSize: 16)),
            Text("Teacher ID: ${teacher.teacherId}", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}




