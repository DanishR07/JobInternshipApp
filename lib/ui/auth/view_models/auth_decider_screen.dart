import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/AuthRepository.dart';
import '../../../services/fcm_service.dart'; // Correct path to your AuthRepository

class AuthDeciderScreen extends StatefulWidget {
  const AuthDeciderScreen({Key? key}) : super(key: key);

  @override
  State<AuthDeciderScreen> createState() => _AuthDeciderScreenState();
}

class _AuthDeciderScreenState extends State<AuthDeciderScreen> {
  @override
  void initState() {
    super.initState();
    // No need for _isLoading state in AuthDeciderScreen.
    // The splash screen has already handled the initial loading visual.
    // This screen's job is just to decide and navigate.
    _decideRoute();
  }

  void _decideRoute() async {
    await Future.delayed(Duration.zero);
    final AuthRepository authRepository = Get.find<AuthRepository>();
    User? user = authRepository.getLoggedInUser();

    if (user != null) {
      // 🔐 Save FCM token
      await FCMService.saveDeviceToken(user.uid);
      FCMService.listenTokenRefresh(user.uid);

      // 👤 Route based on role
      if (user.email == 'danishriasat792@gmail.com') {
        Get.offAllNamed('/admin');
      } else {
        Get.offAllNamed('/user_home');
      }
    } else {
      Get.offAllNamed('/welcome');
    }
  }
  @override
  Widget build(BuildContext context) {
    // AuthDeciderScreen should show minimal UI, as it's just a quick redirector.
    // A simple progress indicator is sufficient here, if anything is shown at all,
    // as the logo was already shown on the SplashScreen.
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(), // Shows that a decision is being made
          ],
        ),
      ),
    );
  }
}