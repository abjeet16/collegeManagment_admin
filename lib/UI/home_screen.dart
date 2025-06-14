import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/api_service.dart';
import '../modules/user_profile.dart';
import 'ProfileScreen.dart';
import 'login_screen.dart';
import 'UsersScreen.dart';
import 'CoursesScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = "User";
  String email = "user@example.com";
  String phone = "9353266834";
  int _selectedIndex = 0;
  final List<String> _titles = ["Home", "Profile", "Settings"];

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
          username = profile.firstName + " " + profile.lastName;
          email = profile.email;
          phone = profile.phone.toString();
        });
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Navigator.pop(context);
    });
  }

  Future<void> _promoteAllStudents() async {
    final pwdController = TextEditingController();

    final bool confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promote All Students'),
        content: TextField(
          controller: pwdController,
          decoration: const InputDecoration(
            labelText: 'Enter your password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Promote', style: TextStyle(color: Colors.green)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final String? result = await ApiService.promoteStudentsWithPassword(
        pwdController.text.trim(), token);

    final bool success = result != null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? result! : 'Promotion failed'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _demoteAllStudents() async {
    final pwdController = TextEditingController();

    final bool confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demote All Students'),
        content: TextField(
          controller: pwdController,
          decoration: const InputDecoration(
            labelText: 'Enter your password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Demote', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final String? result = await ApiService.demoteStudentsWithPassword(
        pwdController.text.trim(), token);

    final bool success = result != null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? result! : 'Demotion failed'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') _showLogoutConfirmationDialog();
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'logout',
                  child: Text("Logout"),
                ),
              ];
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(username),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                child: Icon(Icons.person, size: 40),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile"),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () => _onItemTapped(2),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: _showLogoutConfirmationDialog,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background Logo
          Opacity(
            opacity: 0.2, // you can adjust this
            child: Center(
              child: Image.asset(
                'assets/images/nieLogo.png',
                width: 400, // adjust size as needed
                height: 500,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Main Content
          IndexedStack(
            index: _selectedIndex,
            children: [
              // Home Screen
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UsersScreen()),
                        );
                      },
                      child: Text("Users"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(150, 50),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CoursesScreen(
                              fromAssignTeacher: false,
                              teacherId: null,
                            ),
                          ),
                        );
                      },
                      child: Text("Courses"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(150, 50),
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Screen
              ProfileScreen(),

              // Settings Screen
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _promoteAllStudents,
                      child: Text("Promote All Students"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(200, 50),
                        backgroundColor: Colors.green,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _demoteAllStudents,
                      child: Text("Demote All Students"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(200, 50),
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}









