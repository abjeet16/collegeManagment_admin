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

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(_getIconForField(title), color: Colors.blue),
          SizedBox(width: 10),
          Text(
            "$title: ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForField(String field) {
    switch (field) {
      case "Email":
        return Icons.email;
      case "Phone":
        return Icons.phone;
      case "Department":
        return Icons.school;
      case "Teacher ID":
        return Icons.badge;
      default:
        return Icons.info_outline;
    }
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
        child: SingleChildScrollView(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      child: Text(
                        teacher.firstName[0] + teacher.lastName[0],
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      "${teacher.firstName} ${teacher.lastName}",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(height: 30, thickness: 1),
                  _infoRow("Teacher ID", teacher.teacherId),
                  _infoRow("Email", teacher.email),
                  _infoRow("Phone", teacher.phone),
                  _infoRow("Department", teacher.department),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


