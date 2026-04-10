import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; 

void main() {
  runApp(const PetRescueApp());
}

class PetRescueApp extends StatelessWidget {
  const PetRescueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Rescue',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const LoginScreen(), 
    );
  }
}