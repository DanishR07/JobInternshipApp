// lib/ui/splash_screen/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_lab/data/AuthRepository.dart'; // Corrected import

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // This is where you actually check auth status and navigate
    _checkAuthStatusAndNavigate();
  }

  void _checkAuthStatusAndNavigate() async {
    // Optional: minimum display duration for your logo
    await Future.delayed(const Duration(seconds: 2));

    // Initialize AuthRepository if not already done globally
    // If you used Get.put(AuthRepository()) in main, then Get.find() is fine here.
    final AuthRepository authRepository = Get.find<AuthRepository>();

    User? user = authRepository.getLoggedInUser(); // Get the current user

    if (user != null) {
      // User is logged in, navigate to AuthDeciderScreen to determine role
      Get.offAllNamed('/auth_decider');
    } else {
      // If no user is logged in, navigate to WelcomeScreen
      Get.offAllNamed('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Or your app's primary background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png', // YOUR LOGO PATH HERE
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.3,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            // You can add a subtle loading indicator here if desired
            // const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}