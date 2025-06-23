import 'package:final_lab/model/Internship.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/AuthRepository.dart';
import '../../../data/internships_repository.dart';
import '../../../data/media_repository.dart';

class EditInternshipViewModel extends GetxController {
  AuthRepository authRepository = Get.find();
  InternshipsRepository internshipsRepository = Get.find();
  MediaRepository mediaRepository = Get.find();

  var isUpdating = false.obs;

  Rxn<XFile> image = Rxn<XFile>();

  Future<void> updateInternship(
      Internship internship,
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
      Get.snackbar("Error", "Stipend must be in digit and greater than 0");
      return;
    }
    if (description.isEmpty) {
      Get.snackbar("Error", "Description cannot be empty");
      return;
    }
    if (duration.isEmpty) {
      Get.snackbar("Error", "Duration cannot be empty");
      return;
    }

    isUpdating.value = true;

    if (image.value != null) {
      var imageResult = await mediaRepository.uploadImage(image.value!.path);
      if (imageResult.isSuccessful) {
        internship.image = imageResult.url;
      } else {
        Get.snackbar(
          "Error uploading image",
          imageResult.error ?? "An error occurred while uploading image",
        );
        isUpdating.value = false;
        return;
      }
    }

    internship.title = title;
    internship.companyName = companyName;
    internship.stipend = stipend;
    internship.location = location;
    internship.description = description;
    internship.duration = duration;

    try {
      await internshipsRepository.updateInternship(
        internship,
      );
      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred while updating internship: ${e.toString()}",
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    image.value = await picker.pickImage(source: ImageSource.gallery);
  }
}