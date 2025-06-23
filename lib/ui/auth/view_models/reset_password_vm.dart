import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../data/AuthRepository.dart';

class ResetPasswordViewModel extends GetxController{
  AuthRepository authRepository = Get.find();
  var isLoading = false.obs;

  Future<void> reset(String email) async {
    if(!email.contains("@")){
      Get.snackbar("Error", "Enter proper email");
      return;
    }
    isLoading.value = true;
    try {
      await authRepository.resetPassword(email);
      Get.offAllNamed('link_send');
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Failed to send reset password email");
    }
    isLoading.value = false;
  }
}
