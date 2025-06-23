import 'package:final_lab/data/media_repository.dart';
import 'package:final_lab/model/Internship.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/AuthRepository.dart';
import '../../../data/internships_repository.dart';

class AddInternshipViewModel extends GetxController {
  AuthRepository authRepository = Get.find();
  InternshipsRepository internshipsRepository = Get.find();
  MediaRepository mediaRepository = Get.find();
  var isSaving = false.obs;

  Rxn<XFile> image = Rxn<XFile>();

  Future<void> addInternship(
      String title,
      String companyName,
      String location,
      String stipend,
      String description,
      String duration,
      ) async {
    if (title.isEmpty) {
      Get.snackbar("Error", "Internship Title cannot be empty");
      return;
    }

    if (companyName.isEmpty) {
      Get.snackbar("Error", "Company Name cannot be empty");
      return;
    }

    if (location.isEmpty) {
      Get.snackbar("Error", "Location cannot be empty");
      return;
    }

    if (stipend.isEmpty) {
      Get.snackbar("Error", "Stipend cannot be empty");
      return;
    }
    if (int.tryParse(stipend) == null || int.parse(stipend) <= 0) {
      Get.snackbar("Error", "Stipend must be in digit and greater than 0"); // Updated message
      return;
    }
    if (description.isEmpty) {
      Get.snackbar("Error", "Description cannot be empty");
      return;
    }
    if (duration.isEmpty) { // New validation for duration
      Get.snackbar("Error", "Duration cannot be empty");
      return;
    }

    isSaving.value = true;

    Internship internship = Internship(
      '',
      title,
      companyName,
      location,
      description,
      stipend,
      duration,
    );

    if (image.value != null) {
      var imageResult = await mediaRepository.uploadImage(image.value!.path);
      if (imageResult.isSuccessful) {
        internship.image = imageResult.url;
      } else {
        Get.snackbar(
          "Error uploading image",
          imageResult.error ?? "An error occurred while uploading image",
        );
        isSaving.value = false;
        return;
      }
    }
    try {
      await internshipsRepository.addInternship(internship);
      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred while adding internship: ${e.toString()}",
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    image.value = await picker.pickImage(source: ImageSource.gallery);
  }
}