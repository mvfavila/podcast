import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:podcast/login_screen.dart';
import 'package:podcast/home_screen.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current logged-in user
    User? currentUser = FirebaseAuth.instance.currentUser;

    // If user is already logged in, go to HomeScreen, otherwise show LoginScreen
    if (currentUser != null) {
      return HomeScreen(currentUser);
    } else {
      return const LoginScreen();
    }
  }
}