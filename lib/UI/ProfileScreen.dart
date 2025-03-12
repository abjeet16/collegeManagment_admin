import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/api_service.dart';
import '../modules/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String firstName = "Abjeet";
  String lastName = "Yadav";
  String email = "user@example.com";
  String phone = "9353266834";

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
          firstName = profile.firstName;
          lastName = profile.lastName;
          email = profile.email;
          phone = profile.phone.toString();
        });
      }
    }
  }

  Future<void> _saveUpdatedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("first_name", firstName);
    prefs.setString("last_name", lastName);
    prefs.setString("email", email);
    prefs.setString("phone", phone);
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
                TextField(controller: firstNameController, decoration: InputDecoration(labelText: "First Name")),
                TextField(controller: lastNameController, decoration: InputDecoration(labelText: "Last Name")),
                TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
                TextField(controller: phoneController, decoration: InputDecoration(labelText: "Phone")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
              onPressed: () {
                setState(() {
                  firstName = firstNameController.text;
                  lastName = lastNameController.text;
                  email = emailController.text;
                  phone = phoneController.text;
                });
                _saveUpdatedUserData();
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
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


