import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'UI/splash_screen.dart'; // ✅ Use SplashScreen from separate file

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    OKToast(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // 👈 Only call it here
    );
  }
}


