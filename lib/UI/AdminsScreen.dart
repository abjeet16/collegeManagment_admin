import 'package:flutter/material.dart';

class AdminsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admins")),
      body: Center(
        child: Text(
          "Admins List Goes Here",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
