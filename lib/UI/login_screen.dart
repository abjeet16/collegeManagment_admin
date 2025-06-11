import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/api_service.dart';
import '../modules/UserLoginRequest.dart';
import '../modules/UserLoginResponse.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _uucmsIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _loginUser() async {
    setState(() => _isLoading = true);

    UserLoginRequest loginRequest = UserLoginRequest(
      uucmsId: _uucmsIdController.text.trim(),
      password: _passwordController.text,
    );

    UserLoginResponse? userData = await ApiService.loginUser(loginRequest);

    if (userData != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("auth_token", userData.token);
      await prefs.setString("username", userData.username);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      print("Login failed!");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/login_main_image.png", height: 150),
            Text(
              "Sign In",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _uucmsIdController,
              decoration: InputDecoration(labelText: "UUCMS ID"),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _loginUser,
              child: Text("Sign In"),
            ),
          ],
        ),
      ),
    );
  }
}

