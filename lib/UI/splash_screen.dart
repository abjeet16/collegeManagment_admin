import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/api_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(Duration(seconds: 3)); // Wait for 3 seconds

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("auth_token");

    if (token != null) {
      bool? isExpired = await ApiService.checkTokenExpired(token);

      if (isExpired == false) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
        return;
      }else{
        prefs.remove("auth_token");
      }
    }
    // If token is null or expired
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/nieLogo.png',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 16),
            Text(
              'NIE First Grade College',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple, // You can change to any color you like
              ),
            ),
          ],
        ),
      ),
    );
  }
}
