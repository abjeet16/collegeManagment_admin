import 'package:flutter/material.dart';

import '../helper/api_service.dart';
import '../modules/AddAdminRequest.dart';
import '../modules/student.dart';
import 'AdminProfileScreen.dart';

class AdminsScreen extends StatefulWidget {
  @override
  _AdminsScreenState createState() => _AdminsScreenState();
}

class _AdminsScreenState extends State<AdminsScreen> {
  List<Student> admins = [];
  bool isLoading = true;
  String? error;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAdmins();
  }

  Future<void> fetchAdmins() async {
    setState(() {
      isLoading = true;
    });

    final result = await ApiService.getAdmins();
    setState(() {
      if (result.isNotEmpty && result[0] is Student) {
        admins = result.cast<Student>();
        error = null;
      } else {
        error = result[0]['error'] ?? "Unknown error";
      }
      isLoading = false;
    });
  }

  Future<void> addAdminManually() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Admin"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _userNameController,
                    decoration: InputDecoration(labelText: "Username"),
                    validator: (value) => value!.isEmpty ? "Enter username" : null,
                  ),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(labelText: "First Name"),
                    validator: (value) => value!.isEmpty ? "Enter first name" : null,
                  ),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(labelText: "Last Name"),
                    validator: (value) => value!.isEmpty ? "Enter last name" : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: "Email"),
                    validator: (value) => value!.isEmpty ? "Enter email" : null,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: "Password"),
                    obscureText: true,
                    validator: (value) => value!.length < 6 ? "Min 6 characters" : null,
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: "Phone"),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? "Enter phone number" : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Add"),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop();

                  AddAdminRequest newAdmin = AddAdminRequest(
                    userName: _userNameController.text.trim(),
                    firstName: _firstNameController.text.trim(),
                    lastName: _lastNameController.text.trim(),
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
                    phone: _phoneController.text.trim(),
                  );

                  final response = await ApiService.addAdmin(newAdmin);

                  if (response.containsKey('message')) {
                    clearFields();
                    await fetchAdmins();

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Success"),
                        content: Text(response['message']),
                        actions: [
                          TextButton(
                            child: Text("OK"),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Error"),
                        content: Text(response['error'] ?? "Something went wrong"),
                        actions: [
                          TextButton(
                            child: Text("OK"),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void clearFields() {
    _userNameController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _phoneController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admins")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text("Error: $error"))
          : ListView.builder(
        itemCount: admins.length,
        itemBuilder: (context, index) {
          final admin = admins[index];
          return ListTile(
            title: Text(admin.studentName),
            subtitle: Text("ID: ${admin.studentId}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminProfileScreen(adminId: admin.studentId),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addAdminManually,
        child: Icon(Icons.person_add),
        tooltip: "Add Admin",
      ),
    );
  }
}



