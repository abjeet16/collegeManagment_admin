import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/api_service.dart';
import '../modules/UserDetailChangeReq.dart';
import '../modules/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String firstName = "Error";
  String lastName = "Error";
  String email = "Error";
  String phone = "Error";
  String universityId = "N/A";
  TextEditingController adminPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("auth_token");

    if (token != null) {
      UserProfile? profile = await ApiService.getUserProfile(token);
      if (profile != null) {
        setState(() {
          universityId = profile.universityId;
          firstName = profile.firstName;
          lastName = profile.lastName;
          email = profile.email;
          phone = profile.phone.toString();
        });
      }
    }
  }

  Future<void> _saveUpdatedUserData() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Admin Authentication"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Enter Admin Password to save changes"),
                TextField(
                  controller: adminPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Admin Password"),
                ),
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
                if (adminPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Admin password is required")),
                  );
                  return;
                }

                UserDetailChangeReq userDetails = UserDetailChangeReq(
                  universityId: universityId,
                  firstName: firstName,
                  lastName: lastName,
                  email: email,
                  phone: int.tryParse(phone),
                  adminPassword: adminPasswordController.text,
                );

                try {
                  Map<String, dynamic> response =
                  await ApiService.changeUserDetails(userDetails);
                  print("API Response: $response");

                  Navigator.pop(context); // Close dialog

                  // Show actual response message
                  String message = response['message'] ?? response.toString();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );

                  _loadUserData(); // Refresh profile
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("An error occurred: $e")),
                  );
                }
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  void _editProfile() {
    TextEditingController firstNameController = TextEditingController(text: firstName);
    TextEditingController lastNameController = TextEditingController(text: lastName);
    TextEditingController emailController = TextEditingController(text: email);
    TextEditingController phoneController = TextEditingController(text: phone);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Profile"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField("First Name", firstNameController),
                _buildTextField("Last Name", lastNameController),
                _buildTextField("Email", emailController),
                _buildTextField("Phone", phoneController),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  firstName = firstNameController.text;
                  lastName = lastNameController.text;
                  email = emailController.text;
                  phone = phoneController.text;
                });
                Navigator.pop(context);
                _saveUpdatedUserData();
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(
            text: "$label: ",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            children: [
              TextSpan(
                text: value,
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            SizedBox(height: 20),
            _buildProfileRow("First Name", firstName),
            _buildProfileRow("Last Name", lastName),
            _buildProfileRow("Email", email),
            _buildProfileRow("Phone", phone),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _editProfile,
              icon: Icon(Icons.edit),
              label: Text("Edit Profile"),
            ),
          ],
        ),
      ),
    );
  }
}








