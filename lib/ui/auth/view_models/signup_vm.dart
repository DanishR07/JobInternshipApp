import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../data/AuthRepository.dart';
import '../../../services/fcm_service.dart';

class SignUpViewModel extends GetxController{
  AuthRepository authRepository = Get.find();
  // User? user; // This can be removed or kept, but it's not directly assigned here.
  var isLoading = false.obs;

  Future<void> signup(String email, String password, String confirmPassword) async {
    if(!email.contains("@")){
      Get.snackbar("Error", "Enter proper email");
      return;
    }
    if(password.length<6){
      Get.snackbar("Error", "Password must be 6 characters atleast");
      return;
    }
    if(password!=confirmPassword){
      Get.snackbar("Error", "Password and confirm password must match");
      return;
    }
    isLoading.value = true;
    try {
      await authRepository.signup(email, password);

      // ✨ FIX: Get the currently logged-in user AFTER signup ✨
      User? currentUser = FirebaseAuth.instance.currentUser; // Or authRepository.getLoggedInUser()
      if (currentUser != null) {
        await FCMService.saveDeviceToken(currentUser.uid);
        FCMService.listenTokenRefresh(currentUser.uid);
      } else {
        // Handle case where user is unexpectedly null after signup
        print("Error: User is null after signup. Cannot save FCM token.");
        Get.snackbar("Error", "Signup successful, but failed to get user details for notifications.");
      }
      Get.offAllNamed('/user_home');
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Signup failed");
    }
    isLoading.value = false;
  }

// bool isUserLoggedIn(){
//   return authRepository.getLoggedInUser()!=null;
// }
}