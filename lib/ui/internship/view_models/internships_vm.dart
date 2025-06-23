import 'package:get/get.dart';
import '../../../data/AuthRepository.dart';
import '../../../data/internships_repository.dart';
import '../../../model/Internship.dart';

class InternshipsViewModel extends GetxController {
  AuthRepository authRepository = Get.find();
  InternshipsRepository internshipsRepository = Get.find();

  var isLoading = false.obs;
  var internships = <Internship>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAllInternships();
  }

  void loadAllInternships() {
    internshipsRepository.loadAllInternships().listen((data) {
      internships.value = data;
    });
  }

  Future<void> deleteInternship(Internship internship) async {
    // Use deleteInternship from InternshipsRepository
    await internshipsRepository.deleteInternship(internship);
  }
}