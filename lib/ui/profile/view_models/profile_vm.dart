import 'package:file_picker/file_picker.dart';
import 'package:final_lab/ui/user_home/user_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../../../data/AuthRepository.dart';
import '../../../data/ProfileRepository.dart'; // Assuming this is UserRepository
import '../../../data/media_repository.dart';
import '../../../model/profile.dart'; // Corrected import for NewUser model

class ProfileViewModel extends GetxController{
  AuthRepository authRepository = Get.find();
  UserRepository userRepository = Get.find(); // Assuming ProfileRepository is now UserRepository
  MediaRepository mediaRepository = Get.find();

  var isAdding = false.obs;
  var isDeleting = false.obs;

  Rxn<XFile> image = Rxn<XFile>();
  Rxn<XFile> resumeFile = Rxn<XFile>();

  @override
  void onInit() {
    super.onInit();
    final userId = authRepository.getLoggedInUser()?.uid;
    // --- FIX 1: Add .isNotEmpty check ---
    if (userId != null && userId.isNotEmpty) {
      getUser(userId, showNotFoundMessage: false); // Silent load
    } else {
      print('ProfileViewModel: No logged in user or UID is empty on init.');
      // Optionally handle this state, e.g., by clearing current user data
      currentUser.value = null;
    }
  }

  Future<void> addUser(
      String firstName,
      String lastName,
      String email,
      String phoneNumber,
      ) async {
    if (firstName.isEmpty) {
      Get.snackbar("Error", "Enter proper first name");
      return;
    }
    if (lastName.isEmpty) {
      Get.snackbar("Error", "Enter proper last name");
      return;
    }
    if (!email.contains("@")) {
      Get.snackbar("Error", "Enter proper email");
      return;
    }
    if (phoneNumber.isEmpty || phoneNumber.length < 11) {
      Get.snackbar("Error", "Enter proper phone number");
      return;
    }

    isAdding.value = true;

    final currentFirebaseUser = authRepository.getLoggedInUser();
    // --- FIX 2: Ensure currentFirebaseUser and its UID are valid BEFORE creating NewUser
    if (currentFirebaseUser == null || currentFirebaseUser.uid.isEmpty) {
      Get.snackbar("Error", "Authentication error: User not logged in or UID is empty.");
      isAdding.value = false;
      return;
    }

    NewUser newUser = NewUser(
      "", // docId is initially empty, will be set by userRepository.addUser
      currentFirebaseUser.uid, // Use the directly checked UID (Firebase Auth UID)
      firstName,
      lastName,
      email,
      phoneNumber,
    );

    // Image Upload Logic (existing)
    if (image.value != null) {
      var imageResult = await mediaRepository.uploadImage(image.value!.path);
      if (imageResult.isSuccessful) {
        newUser.image = imageResult.url;
      } else {
        Get.snackbar('Error uploading image', imageResult.error ?? "Could not upload image due to error");
        isAdding.value = false; // Reset loading state on error
        return;
      }
    }

    // Resume PDF Upload Logic
    if (resumeFile.value != null) {
      var resumeResult = await mediaRepository.uploadPdf(resumeFile.value!.path);
      if (resumeResult.isSuccessful) {
        newUser.resume = resumeResult.url;
      } else {
        Get.snackbar('Error uploading resume', resumeResult.error ?? "Could not upload resume due to error");
        isAdding.value = false;
        return;
      }
    }

    try {
      // --- CRITICAL FIX 3: Capture the generated Firestore document ID ---
      // This line now correctly calls userRepository.addUser and expects a String return
      final generatedFirestoreDocId = await userRepository.addUser(newUser);
      // Update the newUser object's docId with the ID returned by Firestore
      newUser.docId = generatedFirestoreDocId;

      // Now fetch the user, using newUser.userId (the Firebase Auth UID)
      // This will correctly use the .where() query in UserRepository
      await getUser(newUser.userId);
      Get.offAll(() => UserHomePage(), arguments: 4);
      Get.snackbar('Profile saved', 'Profile saved successfully');
    } catch (e) {
      Get.snackbar('Error', 'An error occurred ${e.toString()}');
      print(e);
    } finally {
      isAdding.value = false;
    }
  }

  final Rxn<NewUser> currentUser = Rxn<NewUser>(); // Reactive user object

  Future<void> getUser(String userId, {bool showNotFoundMessage = false}) async {
    // --- FIX 4: Critical check before calling repository ---
    if (userId.isEmpty) {
      print('ProfileViewModel Error: Attempted to get user with empty userId.');
      currentUser.value = null; // Clear existing user if ID is invalid
      if (showNotFoundMessage) {
        Get.snackbar('Error', 'Invalid user ID. Cannot fetch profile.');
      }
      isAdding.value = false; // Ensure loading state is reset
      return;
    }
    // --- END FIX 4 ---

    try {
      if (showNotFoundMessage) {
        isAdding.value = true; // Show loading only if explicitly requested
      }
      final user = await userRepository.getUser(userId); // This userId is now guaranteed to be non-empty
      if (user != null) {
        currentUser.value = user;
      } else if (showNotFoundMessage) {
        Get.snackbar('Info', 'Empty Profile Detected! Please take a moment to build it.');
      }
    } catch (e, stackTrace) {
      Get.snackbar('Error', 'Failed to fetch user: ${e.toString()}');
      print('Error fetching user: $e');
      print('Stack trace: $stackTrace');
    } finally {
      isAdding.value = false;
    }
  }

  Future<void> updateUser(
      String firstName,
      String lastName,
      String email,
      String phoneNumber,
      ) async {
    if (currentUser.value == null) {
      Get.snackbar('Error', 'No profile loaded to update.'); // Prevent updating null profile
      return;
    }

    // --- FIX 5: Ensure currentUser.value!.docId is not empty before proceeding ---
    // (Note: This was userId in previous fix, but for updateUser, docId is crucial)
    if (currentUser.value!.docId.isEmpty) { // Use docId here for update operation
      Get.snackbar('Error', 'Profile Document ID is invalid. Cannot update.');
      return;
    }

    isAdding.value = true;
    try {
      // Create a copy to update
      final updatedUser = NewUser(
        currentUser.value!.docId, // Use the actual Firestore Document ID for update
        currentUser.value!.userId, // This is the Firebase Auth UID
        firstName,
        lastName,
        email,
        phoneNumber,
      )
        ..image = currentUser.value!.image
        ..resume = currentUser.value!.resume;

      // Image Upload Logic (existing)
      if (image.value != null) {
        final result = await mediaRepository.uploadImage(image.value!.path);
        if (result.isSuccessful) {
          updatedUser.image = result.url;
        } else {
          Get.snackbar('Error uploading image', result.error ?? "Could not upload image due to error");
          isAdding.value = false;
          return;
        }
      }

      // Resume PDF Upload Logic for Update
      if (resumeFile.value != null) {
        final result = await mediaRepository.uploadPdf(resumeFile.value!.path);
        if (result.isSuccessful) {
          updatedUser.resume = result.url;
        } else {
          Get.snackbar('Error uploading resume', result.error ?? "Could not upload resume due to error");
          isAdding.value = false;
          return;
        }
      }

      // userRepository.updateUser will use updatedUser.docId
      await userRepository.updateUser(updatedUser);
      currentUser.value = updatedUser; // Update reactive user object
      Get.offAll(() => UserHomePage(), arguments: 4);
      Get.snackbar('Success', 'Profile updated');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isAdding.value = false;
    }
  }

  Future<void> deleteUser(NewUser user) async {
    try {
      isDeleting.value = true;
      await userRepository.deleteUser(user);
      final currentUser = authRepository.getLoggedInUser();
      if (currentUser != null) {
        await currentUser.delete(); // Deletes Firebase Auth user
      }
      this.currentUser.value = null; // Clear local reactive user
      Get.back();
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase Auth
      Get.offAllNamed('/login'); // Navigate to login
      Get.snackbar('Account deleted', 'Your account has been deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete profile/account: ${e.toString()}');
    } finally {
      isDeleting.value = false;
    }
  }
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    image.value = await picker.pickImage(source: ImageSource.gallery);
  }

  Future<void> pickResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        resumeFile.value = XFile(result.files.single.path!);
      } else {
        Get.snackbar('Info', 'No resume file selected.');
      }
    } catch (e) {
      Get.snackbar('Error picking resume', e.toString());
      print('Error picking resume: $e');
    }
  }
}