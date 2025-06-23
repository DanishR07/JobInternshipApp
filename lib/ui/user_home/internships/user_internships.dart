import 'package:final_lab/data/applied_positions_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/AuthRepository.dart';
import '../../../data/internships_repository.dart';
import '../../../model/Internship.dart';
import '../../internship/view_models/internships_vm.dart';
import '../../profile/view_models/profile_vm.dart';
import '../custom_app_bar.dart';
import '../custom_drawer.dart';

class UserInternshipsPage extends StatefulWidget {
  const UserInternshipsPage({super.key});

  @override
  State<UserInternshipsPage> createState() => _UserInternshipsPageState();
}

class _UserInternshipsPageState extends State<UserInternshipsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late InternshipsViewModel internshipsViewModel;
  late ProfileViewModel profileViewModel;
  final AuthRepository authRepository = Get.find();

  @override
  void initState() {
    super.initState();
    internshipsViewModel = Get.find<InternshipsViewModel>();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        title: 'Internships', // or any screen name

      ),
      drawer: const CustomDrawer(),
      body: Obx(() {
        if (internshipsViewModel.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (internshipsViewModel.internships.isEmpty) { // Access the internships list
          return const Center(
            child: Text('No internships available.'),
          );
        } else {
          return ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: internshipsViewModel.internships.length, // Access the internships list
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              Internship internship = internshipsViewModel.internships[index]; // Use Internship model

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  onTap: () {
                    Get.toNamed('/internship_details', arguments: internship);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image/Logo
                        internship.image == null // Use internship.image
                            ? const Icon(Icons.business, size: 80, color: Colors.grey) // Default icon if no image
                            : ClipOval(
                          child: Image.network(
                            internship.image!, // Use internship.image!
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.business, size: 80, color: Colors.grey), // Fallback for image loading error
                          ),
                        ),
                        const SizedBox(height: 10), // Added some space for clarity
                        // Internship Title
                        Text(
                          internship.title, // Use internship.title
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Company Name
                        Row(
                          children: [
                            const Icon(
                              Icons.business,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              internship.companyName, // Use internship.companyName
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Location
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              internship.location, // Use internship.location
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Stipend
                        Row(
                          children: [
                            const Icon(
                              Icons.money, // Changed icon for stipend
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              internship.stipend, // Use internship.stipend
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Duration
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time, // Icon for duration
                              color: Colors.blueGrey,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              internship.duration, // Use internship.duration
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      }),
    );
  }
}

class UserInternshipsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(InternshipsRepository());
    Get.put(ProfileViewModel());
    Get.put(InternshipsViewModel());
  }
}