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
    setState(() => isLoading = true);
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
                  _buildInput(_userNameController, "Username"),
                  _buildInput(_firstNameController, "First Name"),
                  _buildInput(_lastNameController, "Last Name"),
                  _buildInput(_emailController, "Email", inputType: TextInputType.emailAddress),
                  _buildInput(_passwordController, "Password", obscure: true),
                  _buildInput(_phoneController, "Phone", inputType: TextInputType.phone),
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

                  clearFields();
                  await fetchAdmins();

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(response.containsKey('message') ? "Success" : "Error"),
                      content: Text(response['message'] ?? response['error'] ?? "Something went wrong"),
                      actions: [
                        TextButton(
                          child: Text("OK"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInput(TextEditingController controller, String label,
      {bool obscure = false, TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Enter $label' : null,
      ),
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
      appBar: AppBar(
        title: Text("Admins"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchAdmins,
            tooltip: "Refresh",
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text("Error: $error"))
          : ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: admins.length,
        itemBuilder: (context, index) {
          final admin = admins[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(
                admin.studentName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("ID: ${admin.studentId}"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminProfileScreen(adminId: admin.studentId),
                  ),
                );
              },
            ),
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

